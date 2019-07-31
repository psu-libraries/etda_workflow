FROM node:10 as nodejs

FROM ruby:2.4.6 as ruby

# etda_utils is a private repo, this is a work around for getting it installed in the container
RUN mkdir /etda_workflow && \
    mkdir -p /root/.ssh
COPY Gemfile Gemfile.lock  /etda_workflow/
WORKDIR /etda_workflow

ARG SSH_PRIVATE_KEY
ARG RAILS_ENV
ENV RAILS_ENV=$RAILS_ENV
ENV SSH_PRIVATE_KEY_ENV=$SSH_PRIVATE_KEY
ENV GEM_HOME=/etda_workflow/vendor/bundle
ENV GEM_PATH=/etda_workflow/vendor/bundle
ENV BUNDLE_PATH=/etda_workflow/vendor/bundle

RUN echo  "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config && \
    echo "${SSH_PRIVATE_KEY_ENV}" | base64 -d  > /root/.ssh/id_rsa && \
    chmod 400 /root/.ssh/id_rsa && \
    gem install bundler

RUN bundle package --all
RUN bundle install

FROM ruby:2.4.6

ARG RAILS_ENV
ENV RAILS_ENV=$RAILS_ENV
ENV GEM_HOME=/etda_workflow/vendor/bundle
ENV GEM_PATH=/etda_workflow/vendor/bundle
ENV BUNDLE_PATH=/etda_workflow/vendor/bundle
ENV PATH="/etda_workflow/vendor/bundle/bin:${PATH}"
WORKDIR /etda_workflow

ENV TZ=America/New_York

## Install Node from the node container.
COPY --from=nodejs /usr/local/bin/node /usr/local/bin/
COPY --from=nodejs /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=nodejs /opt/ /opt/

RUN ln -sf /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && ln -sf /opt/yarn*/bin/yarn /usr/local/bin/yarn \
  && ln -sf /opt/yarn*/bin/yarnpkg /usr/local/bin/yarnpkg

# System Dependencies
RUN apt-get update && \ 
  apt-get install mariadb-client clamav clamdscan clamav-daemon wget libpng-dev make -y && \
  rm -rf /var/lib/apt/lists/*

# Configure ClamAV
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

RUN touch  /etc/clamav/clamd.conf

# Seed cve database. this get cached, so we also run freshclam as part of entrypoint
RUN wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
    wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
    wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
    chown clamav:clamav /var/lib/clamav/*.cvd
  
RUN sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf && \
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf

RUN useradd -u 10000 etda -d /etda_workflow
RUN usermod -G clamav etda

RUN chown etda /etda_workflow

USER etda

# COPY --from=ruby /usr/local/bundle /usr/local/bundle
COPY --from=ruby /etda_workflow /etda_workflow

# Install javascript Dependencies before copying up source code
COPY yarn.lock /etda_workflow
COPY package.json /etda_workflow
RUN yarn


COPY --chown=etda . /etda_workflow

# Needed for phantomjs to work
ENV OPENSSL_CONF=/etc/ssl/

RUN mkdir -p tmp && chown etda tmp

USER etda

# ensure tmp directory exists

# Precompile assets as part of build to speed up runtime startup, and identify any problems before runtime
# RUN RAILS_ENV=production DEVISE_SECRET_KEY=$(bundle exec rails secret) bundle exec rails assets:precompile
RUN if [ "$RAILS_ENV" = "development" ]; then echo "skipping assets:precompile"; else RAILS_ENV=production DEVISE_SECRET_KEY=$(bundle exec rails secret) bundle exec rails assets:precompile; fi

CMD ["./entrypoint.sh"]

FROM node:12.7.0 as nodejs

FROM ruby:2.4.6 as ruby

RUN mkdir /etda_workflow && \
    mkdir -p /root/.ssh
COPY Gemfile Gemfile.lock vendor/cache* /etda_workflow/
WORKDIR /etda_workflow

ARG SSH_PRIVATE_KEY
ARG RAILS_ENV
ENV RAILS_ENV=$RAILS_ENV
ENV SSH_PRIVATE_KEY_ENV=$SSH_PRIVATE_KEY

RUN echo  "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config && \
    echo "${SSH_PRIVATE_KEY_ENV}" | base64 -d  > /root/.ssh/id_rsa && \
    chmod 400 /root/.ssh/id_rsa && \
    gem install bundler

RUN bundle package --all

RUN bundle install --path vendor/gems

FROM ruby:2.4.6
WORKDIR /etda_workflow

ENV TZ=America/New_York

COPY --from=nodejs /usr/local/bin/node /usr/local/bin/
COPY --from=nodejs /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=nodejs /opt/ /opt/

RUN ln -sf /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && ln -sf /opt/yarn*/bin/yarn /usr/local/bin/yarn \
  && ln -sf /opt/yarn*/bin/yarnpkg /usr/local/bin/yarnpkg

# Clam AV 
RUN apt-get update && \ 
  apt-get install mariadb-client clamav clamdscan clamav-daemon wget libpng-dev make -y && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

RUN touch  /etc/clamav/clamd.conf

RUN wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
    wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
    wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
    chown clamav:clamav /var/lib/clamav/*.cvd
  
RUN sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf && \
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf


COPY --from=ruby /usr/local/bundle /usr/local/bundle
COPY --from=ruby /etda_workflow /etda_workflow

COPY yarn.lock /etda_workflow
COPY package.json /etda_workflow
RUN yarn


RUN useradd -u 10000 etda
RUN usermod -G clamav etda

COPY --chown=etda . /etda_workflow

# Needed for phantomjs to work
ENV OPENSSL_CONF=/etc/ssl/

RUN if [ "$RAILS_ENV" = "development" ]; then echo "skipping assets:precompile"; else RAILS_ENV=production DEVISE_SECRET_KEY=$(bundle exec rails secret) bundle exec rails assets:precompile; fi

# USER etda


CMD ["./entrypoint.sh"]

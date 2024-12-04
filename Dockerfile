# syntax=docker/dockerfile:experimental
FROM harbor.k8s.libraries.psu.edu/library/ruby-3.1.6-node-21:20241204 as base


# Add these to see if it builds
# RUN apt --fix-broken install -y # Didnt work

# Else add the correct gcc-12-base 
# RUN apt-get install -y gcc-12-base=12.2.0-14
# Install GCC 12 and dependencies
# Ensure necessary tools are installed
RUN apt-get update && apt-get install -y wget dpkg

# Download gcc-12-base and libgcc-s1
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-12/gcc-12-base_12.2.0-14_amd64.deb \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-12/libgcc-s1_12.2.0-14_amd64.deb

# Install the base packages
RUN dpkg -i gcc-12-base_12.2.0-14_amd64.deb libgcc-s1_12.2.0-14_amd64.deb

# Download and install gcc-12 and g++-12
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-12/gcc-12_12.2.0-14_amd64.deb \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-12/g++-12_12.2.0-14_amd64.deb \
    && dpkg -i gcc-12_12.2.0-14_amd64.deb g++-12_12.2.0-14_amd64.deb

# Optionally, clean up downloaded files
RUN rm -f gcc-12-base_12.2.0-14_amd64.deb libgcc-s1_12.2.0-14_amd64.deb gcc-12_12.2.0-14_amd64.deb g++-12_12.2.0-14_amd64.deb




# hadolint ignore=DL3008
RUN apt-get update && \
  apt-get install --no-install-recommends libmariadb-dev mariadb-client clamav clamdscan wget libpng-dev make -y && \
  rm -rf /var/lib/apt/lists/*

ENV TZ=America/New_York

WORKDIR /etda_workflow

COPY Gemfile Gemfile.lock /etda_workflow/

RUN useradd -u 10000 etda -d /etda_workflow && \
  usermod -G clamav etda && \
  chown -R etda /etda_workflow && \
  chmod 777 /etc/clamav

USER etda
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
COPY --chown=etda vendor/ vendor/
RUN bundle install --path vendor/bundle

COPY yarn.lock /etda_workflow
COPY package.json /etda_workflow
RUN yarn

COPY --chown=etda . /etda_workflow
COPY --chown=etda config/clamd.conf /etc/clamav

RUN mkdir -p tmp/cache

CMD ["/etda_workflow/bin/startup"]

FROM base as rspec
CMD ["/etda_workflow/bin/ci-rspec"]

FROM base as production

RUN bundle install --without development test

RUN PARTNER=graduate RAILS_ENV=production DEVISE_SECRET_KEY=$(bundle exec rails secret) bundle exec rails assets:precompile

CMD ["/etda_workflow/bin/startup"]

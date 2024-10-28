# syntax=docker/dockerfile:experimental
FROM harbor.k8s.libraries.psu.edu/library/ruby-3.1.6-node-20:20241028 AS base

# hadolint ignore=DL3008
RUN apt-get update && apt --fix-broken install -y && \
  apt-get install --no-install-recommends clamav clamdscan libpng-dev libmariadb-dev mariadb-client -y  && \
  rm -rf /var/lib/apt/lists/*

ENV TZ=America/New_York

WORKDIR /etda_workflow

COPY Gemfile Gemfile.lock /etda_workflow/

RUN useradd -u 1000 etda -d /etda_workflow && \
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
USER root
RUN ln -s /usr/lib/x86_64-linux-gnu/libffi.so.7 /usr/lib/x86_64-linux-gnu/libffi.so.6
USER etda
CMD ["/etda_workflow/bin/startup"]

FROM base as rspec
CMD ["/etda_workflow/bin/ci-rspec"]

FROM base as production
RUN bundle config build.ffi --disable-system-libffi
RUN bundle install --without development test

RUN PARTNER=graduate RAILS_ENV=production DEVISE_SECRET_KEY=$(bundle exec rails secret) bundle exec rails assets:precompile

USER root
RUN chown -R etda /etda_workflow

USER etda
CMD ["/etda_workflow/bin/startup"]

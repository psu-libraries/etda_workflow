# syntax=docker/dockerfile:experimental
FROM harbor.k8s.libraries.psu.edu/library/ruby-3.1.2-node-16:20240115 as base

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

# syntax=docker/dockerfile:experimental
FROM harbor.libraries.psu.edu/library/ruby-3.4.11-node-22-yarn-4.18.1 AS base

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

ENV GEM_HOME=/etda_workflow/.gem
ENV PATH=/etda_workflow/.gem/bin:$PATH

RUN mkdir -p "$GEM_HOME" && \
  gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1 | xargs)"

COPY --chown=etda vendor/ vendor/
RUN bundle config set --local path 'vendor/bundle'
RUN bundle install

COPY --chown=etda yarn.lock package.json /etda_workflow/
RUN yarn

COPY --chown=etda . /etda_workflow
COPY --chown=etda config/clamd.conf /etc/clamav

RUN mkdir -p tmp/cache

CMD ["/etda_workflow/bin/startup"]

FROM base AS rspec
CMD ["/etda_workflow/bin/ci-rspec"]


FROM base AS production

RUN bundle config set without 'development test' \
  && bundle install

RUN PARTNER=graduate RAILS_ENV=production SECRET_KEY_BASE=$(bundle exec rails secret) bundle exec rails assets:precompile

CMD ["/etda_workflow/bin/startup"]

#!/bin/bash

yarn install &&
if [ -f tmp/pids/server.pid ]; then rm tmp/pids/server.pid; fi &&
echo starting database migrations &&
yarn global add phantomjs-prebuilt &&
rails db:create &&
rails db:migrate &&
echo starting rails &&
bundle exec puma
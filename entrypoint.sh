#!/bin/bash

if [ -f /secrets/env.env ]; then 
set -a
source /secrets/env.env
set +a
fi 

freshclam -d & 
clamd & 

rails db:create
rails db:migrate
rails db:seed:essential

bundle exec puma
#!/bin/bash

freshclam -d & 
clamd & 

rails db:create
rails db:migrate
rails db:seed:essential

rails s


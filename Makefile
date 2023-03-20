.PHONY: help

PWD="$(pwd)"

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

exec: ## pop a shell in this thing
	docker-compose exec web /bin/bash

exec_redis: ## pop a shell in redis container
	docker-compose exec redis /bin/bash

bundle: ## run bundle install in container
	docker-compose exec web bundle install

run: ## run bash in a fresh container without startup scripts
	docker-compose run web /bin/bash

down: ## turn this thing off
	docker-compose down

up: ## run this thing
	docker-compose up redis db seleniarm web -d

up_milsch: ## run this thing
	PARTNER=milsch docker-compose up redis db seleniarm web -d

up_honors: ## run this thing
	PARTNER=honors docker-compose up redis db seleniarm web -d

up_sset: ## run this thing
	PARTNER=sset docker-compose up redis db seleniarm web -d

rebuild: build up ## run build and then up

dev: ## build and run locally 
	docker-compose up redis db seleniarm web --build

build: ## run development environment
	docker-compose build

yarn: ## Run Yarn
	docker run -v $$PWD:/code -w=/code node:10 'yarn'

attach: ## Attach to the web container
	docker attach etda_workflow_web_1

logs: ## watch logs
	docker-compose logs -f

rspec: ## test
	docker-compose exec -e RAILS_ENV=test web rspec

restart: ## restart rails server
	docker-compose exec web bundle exec rails restart

console: ## boot-up rails console
	docker-compose exec web bundle exec rails c


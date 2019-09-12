.PHONY: help

PWD="$(pwd)"
SSH_PRIVATE_KEY=$(shell cat ~/.ssh/id_rsa|base64)

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

exec: ## pop a shell in this thing
	docker-compose exec web /bin/bash

bundle: ## run bundle install in container
	docker-compose exec web bundle install

down: ## turn this thing off
	docker-compose down
	mutagen terminate --label-selector app=etda-workflow

up: ## run this thing
	docker-compose up -d
	mutagen create --ignore .git --ignore vendor/cache --ignore tmp --ignore public -m two-way-resolved --label app=etda-workflow . docker://etda_workflow_web_1/etda_workflow 

up_milch: ## run this thing
	docker-compose up -d
	docker-compose run -e PARTNER=milsch web
	mutagen create --ignore .git --ignore vendor/cache --ignore tmp --ignore public -m two-way-resolved --label app=etda-workflow . docker://etda_workflow_web_1/etda_workflow

rebuild: build up ## run build and then up

dev: ## build and run locally 
	docker-compose up --build

build: ## run development environment
	SSH_PRIVATE_KEY=$(SSH_PRIVATE_KEY); \
	docker-compose build --build-arg SSH_PRIVATE_KEY=$$SSH_PRIVATE_KEY;

yarn: ## Run Yarn
	docker run -v $$PWD:/code -w=/code node:10 'yarn'

attach: ## Attach to the web container
	docker attach etda_workflow_web_1

logs: ## watch logs
	docker-compose logs -f

rspec: ## test
	docker-compose exec -e RAILS_ENV=test web rspec



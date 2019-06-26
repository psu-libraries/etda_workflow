# Install Docker
https://download.docker.com/mac/stable/Docker.dmg

- Drag to Applications
- Open


# Build 
Builds the docker image from your Dockerfile. You'll need to build anytime anything *outside* of `./app` changes. changes from within `./app` are automaticaly persisted to the docker container via volume bind mount

`docker-compose build --build-arg SSH_PRIVATE_KEY=$(cat ~/.ssh/id_rsa|base64)`


# Run
All the defaults should be sane enough to "just work" Running


`docker-compose up -d` # fire up the stack, and daemonize
`docker-compose up` # fire up the stack 


# Build vs Run
You need to run build the first time you deploy on a new computer, or when you change anything outside of the `./app` folder. changes inside of the `./app` folder will be picked up by just doing run

# Exposed Services

localhost:8080 - adminer
localhost:3000 - rails app
localhost:3306 - postgres


# Rake Tasks
To run rake tasks you run them like you normally would, but preface the command with `docker-compose exec web`
Example

`docker-compose exec web bundle exec rake db:seed`


# Cleanup 
```
docker-compose down
```

# Remove all state
# TODO
```

```
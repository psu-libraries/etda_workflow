if [ $RAILS_ENV = "development" ]; then
    yarn install 
    yarn add phantomjs-prebuilt
    bundle check || bundle install --path=vendor/bundle
fi

freshclam -d & 
clamd & 

bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed:essential

bundle exec rails s -b 0.0.0.0

# require File.join(File.dirname(__FILE__))

RSpec.configure do |config|
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
    # #Capybara.page.driver.browser.url_blacklist = ["www.google-analytics.com"]
  end

  config.before(:each) do
    DatabaseCleaner.start
    load Rails.root.join('db/seeds/essential.seeds.rb')
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each, js: true) do
    # Use truncation so that other processes (e.g. phantomjs) see the same thing
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    # Begin transaction
    DatabaseCleaner.start
    # Seed with essential data
    load Rails.root.join('db/seeds/essential.seeds.rb')
  end

  config.append_after(:each) do
    # Roll back transaction
    DatabaseCleaner.clean
  end
end

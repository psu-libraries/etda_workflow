# frozen_string_literal: true

# require File.join(File.dirname(__FILE__))

RSpec.configure do |config|
  config.before do
    DatabaseCleaner.strategy = :transaction
  end
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
    # #Capybara.page.driver.browser.url_blacklist = ["www.google-analytics.com"]
  end

  config.before do
    DatabaseCleaner.start
    load Rails.root.join('db/seeds/essential.seeds.rb')
  end
  config.after do
    DatabaseCleaner.clean
  end

  config.before(:each, js: true) do
    # Use truncation so that other processes (e.g. phantomjs) see the same thing
    DatabaseCleaner.strategy = :truncation
  end

  config.before do
    # Begin transaction
    DatabaseCleaner.start
    # Seed with essential data
    load Rails.root.join('db/seeds/essential.seeds.rb')
  end

  config.append_after do
    # Roll back transaction
    DatabaseCleaner.clean
  end
end

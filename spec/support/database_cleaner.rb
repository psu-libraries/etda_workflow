# frozen_string_literal: true

# require File.join(File.dirname(__FILE__))

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion)
    DegreeType.seed
    CommitteeRole.seed
  end

  config.after(:suite) do
    DatabaseCleaner.clean_with(:deletion)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
  end
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :deletion
    # #Capybara.page.driver.browser.url_blacklist = ["www.google-analytics.com"]
  end

  config.before do
    DatabaseCleaner.start
    DegreeType.seed
    CommitteeRole.seed
    # load Rails.root.join('db/seeds/essential.seeds.rb')
  end
  config.after do
    DatabaseCleaner.clean
  end

  # config.before do
  #   # Begin transaction
  #   DatabaseCleaner.start
  #   # Seed with essential data
  #   load Rails.root.join('db/seeds/essential.seeds.rb')
  # end
  #
  # config.append_after do
  #   # Roll back transaction
  #   DatabaseCleaner.clean
  # end
end

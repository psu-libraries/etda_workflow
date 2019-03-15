# frozen_string_literal: true

# require File.join(File.dirname(__FILE__))

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion, { except: %w[student_submissions] }
    DatabaseCleaner.clean
    DegreeType.seed
    CommitteeRole.seed
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :deletion, { except: %w[student_submissions] }
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
end

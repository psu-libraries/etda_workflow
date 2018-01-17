# frozen_string_literal: true

module Capybara
  module SaveAndOpenScreenshot
    def save_and_open_screenshot(filename = nil)
      filename ||= "poltergeist-#{Time.new.strftime('%Y%m%d%H%M%S')}#{rand(10**10)}.png"
      path = File.expand_path(filename, ROOT.join('tmp/capybara'))

      page.save_screenshot(path, full: true)

      begin
        require "launchy"
        Launchy.open(path)
      rescue LoadError
        warn "Page saved to #{path} with save_and_open_page."
        warn "Please install the launchy gem to open page automatically."
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::SaveAndOpenScreenshot
end

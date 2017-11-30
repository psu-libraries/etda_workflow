# Stub out authentication for tests.

# This authentication strategy will automatically succeed for the user that was
# assigned to the `user` class variable.
class StubbedAuthenticationStrategy < ::Devise::Strategies::Base
  # Use this method to set the user that should be authenticated.
  class << self
    attr_writer :author
  end

  # We're a fake authentication strategy; we always succeed.
  def authenticate!
    success! @@author
  end

  # Called if the user doesn't already have a rails session cookie
  def valid?
    true
  end
end

module StubbedAuthenticationHelper
  def webaccess_auth_and_visit(path)
    webaccess_auth
    visit path
  end

  def webaccess_auth
    sign_in_as current_author
  end

  def current_author
    @current_author ||= create(:author, access_id: 'authorflow')
    Author.current = @current_author
  end

  # Call this method in your "before" block to be signed in as the given user
  # (pass in the entire user object, not just a username).
  def sign_in_as(author)
    # Remove the session cookie for the original_owner
    # to ensure we visit pages that belong to the new_owner
    #    page.driver.browser.remove_cookie '_etdflow_session'

    StubbedAuthenticationStrategy.author = author
    Warden::Strategies.add :webaccess_authenticatable,
                           StubbedAuthenticationStrategy
  end
end

RSpec.configure do |config|
  config.after(:each) do
    Warden::Strategies.add :webaccess_authenticatable,
                           Devise::Strategies::WebaccessAuthenticatable
    StubbedAuthenticationStrategy.author = nil
  end

  config.include StubbedAuthenticationHelper
end

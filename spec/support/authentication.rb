# frozen_string_literal: true

# Stub out authentication for tests.

# This authentication strategy will automatically succeed for the user that was
# assigned to the `user` class variable.
class StubbedAuthenticationStrategy < ::Devise::Strategies::Base
  # Use this method to set the user that should be authenticated.
  def self.author=(author)
    @@author = author
  end

  def self.admin=(admin)
    @@admin = admin
  end

  # We're a fake authentication strategy; we always succeed.
  def authenticate!
    person = @author.nil? ? @@admin : @@author
    success! person
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

  def webaccess_authorize_author
    sign_in_as_author current_author
  end

  def webaccess_authorize_admin
    sign_in_as_admin current_admin
  end

  def current_author
    @current_author ||= FactoryBot.create(:author, access_id: 'authorflow', psu_email_address: 'authorflow@psu.edu')
    Author.current = @current_author
  end

  def current_admin
    @current_admin ||= FactoryBot.create(:admin, access_id: 'adminflow', administrator: true, site_administrator: true)
    Admin.current = @current_admin
  end

  # Call this method in your "before" block to be signed in as the given user
  # (pass in the entire user object, not just a username).
  def sign_in_as_author(author)
    # Remove the session cookie for the original_owner
    # to ensure we visit pages that belong to the new_owner
    Capybara.page.driver.browser.remove_cookie '_etdflow_session'
    Capybara.current_session.driver.browser.set_cookie(name: '_etdflow_session', path: '/author')
    StubbedAuthenticationStrategy.author = author
    Warden::Strategies.add :webaccess_authenticatable,
                           StubbedAuthenticationStrategy
  end

  def sign_in_as_admin(admin)
    # Remove the session cookie for the original_owner
    # to ensure we visit pages that belong to the new_owner
    Capybara.page.driver.browser.remove_cookie '_etdflow_session'
    Capybara.current_session.driver.browser.set_cookie(name: '_etdflow_session', path: '/admin')
    StubbedAuthenticationStrategy.admin = admin
    Warden::Strategies.add :webaccess_authenticatable,
                           StubbedAuthenticationStrategy
  end
end

RSpec.configure do |config|
  config.after do
    Warden::Strategies.add :webaccess_authenticatable,
                           Devise::Strategies::WebaccessAuthenticatable
    StubbedAuthenticationStrategy.author = nil

    Warden::Strategies.add :webaccess_authenticatable,
                           Devise::Strategies::WebaccessAuthenticatable
    StubbedAuthenticationStrategy.admin = nil
  end

  config.include StubbedAuthenticationHelper
end

class AdminController < ApplicationController
  def valid_admin?
    true
  end

  def valid_author?
    true
  end
end

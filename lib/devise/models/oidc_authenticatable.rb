# frozen_string_literal: true

require 'devise/strategies/oidc_authenticatable.rb'

module Devise
  module Models
    module OidcAuthenticatable
      extend ActiveSupport::Concern

      def after_database_authentication; end
    end
  end
end

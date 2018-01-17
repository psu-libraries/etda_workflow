# frozen_string_literal: true

require 'devise/strategies/webaccess_authenticatable.rb'

module Devise
  module Models
    module WebaccessAuthenticatable
      extend ActiveSupport::Concern

      def after_database_authentication; end
    end
  end
end

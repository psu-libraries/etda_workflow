require 'devise/strategies/webaccess_authenticatable.rb'

module Devise
  module Models
    module WebaccessAuthenticatable
      extend ActiveSupport::Concern

      def after_database_authentication
      end

      def complete_login(access_id)
        Author.where(access_id: access_id)
        current_author = first_or_create(access_id: access_id, psu_email_address: "#{access_id}@psu.edu")
        Rails.logger "CURRENT_AUTHOR:  #{current_author.inspect}"
        current_author
      end
    end
  end
end

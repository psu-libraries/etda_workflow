# frozen_string_literal: true

require 'devise/strategies/authenticatable'
module Devise
  module Strategies
    class WebaccessAuthenticatable < Authenticatable
      def authenticate!
        access_id = remote_user(request.headers)
        Rails.logger.info "Devise Access ID ******* #{access_id}"

        if access_id.present? # webaccess successful
          this_object = authentication_type || Author.class
          a = this_object.find_by_access_id(access_id)
          if a.nil?
            obj = this_object.create(access_id: access_id, psu_email_address: "#{access_id}@psu.edu")
            obj.populate_attributes
          else
            obj = a
            obj.update_missing_attributes
          end
          success!(obj)
        else
          fail!
        end
      end

      def valid?
        this_remote_user = remote_user(request.headers)
        return true unless this_remote_user.nil?
        false
      end

      def remote_user(headers)
        if Rails.env.production?
          headers.fetch('REMOTE_USER', nil)
        else
          headers.fetch('REMOTE_USER', nil) || headers.fetch('HTTP_REMOTE_USER', nil)
        end
      end

      protected

      def authentication_type
        # controller_name = request[:controller]
        # str = controller_name.split('/')
        # str = ['author'] if str.nil? || str.empty?
        # Object.const_get(str[0].camelcase)
        uri = request.headers['REQUEST_URI']
        this_uri = uri.split('/')[1].camelcase
        Object.const_get(this_uri)
      end
    end
  end
end

Warden::Strategies.add(:webaccess_authenticatable, Devise::Strategies::WebaccessAuthenticatable)

require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class WebaccessAuthenticatable < Authenticatable
      def authenticate!
        access_id = remote_user(request.headers)
        if access_id.present? # webaccess successful
          a = Author.find_by_access_id(access_id)
          if a.nil?
            author = Author.create(access_id: access_id, psu_email_address: "#{access_id}@psu.edu")
            author.populate_attributes
          else
            author = a
            author.update_missing_attributes
          end
          success! (author)
        else
          fail!
        end
      end

      def author_valid?(headers)
        this_remote_user = remote_user(headers)
        !this_remote_user.nil?
      end

      protected

        def remote_user(headers)
          if Rails.env.production?
            headers.fetch('REMOTE_USER', nil)
          else
            headers.fetch('REMOTE_USER', nil) || headers.fetch('HTTP_REMOTE_USER', nil)
          end
        end

      # protected

      # def complete_login
      # end
    end
  end
end

Warden::Strategies.add(:webaccess_authenticatable, Devise::Strategies::WebaccessAuthenticatable)

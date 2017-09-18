require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class WebaccessAuthenticatable < Authenticatable
      def valid?
        !remote_user(headers).blank? && (Author.current.blank? || (Author.current.reload.access_id == remote_user(headers)))
      end

      def authenticate!
        access_id = remote_user(request.headers)
        if access_id.present? && valid? # webaccess successful
          author = complete_login(access_id)
          success! (author)
        else
          fail!
        end
      end

      protected

        def remote_user(headers)
          return headers['REMOTE_USER'] if headers['REMOTE_USER']
          return headers['HTTP_REMOTE_USER'] if headers['HTTP_REMOTE_USER'] && Rails.env.development?
          nil
        end

        def complete_login(access_id)
          author = Author.where(access_id: access_id).first_or_create(access_id: access_id, psu_email_address: "#{access_id}@psu.edu")
          author.save(validate: false)
          author
        end
    end
  end
end

Warden::Strategies.add(:webaccess_authenticatable, Devise::Strategies::WebaccessAuthenticatable)

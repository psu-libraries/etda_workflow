# frozen_string_literal: true

require 'devise/strategies/authenticatable'
module Devise
  module Strategies
    class OidcAuthenticatable < Authenticatable
      def authenticate!
        access_id = remote_user(request.headers)

        return fail! unless access_id.present?

        request.session[:webaccess_id] = access_id

        this_object = authentication_type || Author.class
        a = this_object.find_by_access_id(access_id)
        if a.nil?
          case this_object.name
          when 'Approver'
            obj = this_object.create(access_id: access_id)
            success(obj)
          when 'Author'
            obj = this_object.create(access_id: access_id, psu_email_address: "#{access_id}@psu.edu")
            obj.populate_attributes
            success(obj)
          when 'Admin'
            return failure unless LdapUniversityDirectory.new.in_admin_group?(access_id)

            obj = this_object.create(access_id: access_id, psu_email_address: "#{access_id}@psu.edu")
            obj.populate_attributes
            success(obj)
          else
            failure
          end
        else
          if (a.class.name == 'Admin') && (!a.administrator?)
            failure
          else
            obj = a
            if obj.class.name == 'Author'
              obj.refresh_important_attributes if obj.admin_edited_at.blank?
              ConfidentialHoldUpdateService.update(a)
            end
            success(obj)
          end
        end
      end

      def valid?
        this_remote_user = remote_user(request.headers)
        return true unless this_remote_user.nil?

        return true unless request.session[:webaccess_id].nil?

        false
      end

      def remote_user(headers)
        if request.session[:webaccess_id]
          request.session[:webaccess_id]
        else
          nil_values = ["", "(null)"]
          remote_user_header = ENV.fetch('REMOTE_USER_HEADER', 'HTTP_REMOTE_USER')
          access_id = headers.fetch(remote_user_header, nil) || headers.fetch('REMOTE_USER', nil)
          return nil if nil_values.include?(access_id)
          access_id = access_id.split('@')[0] if access_id
          access_id
        end
      end

      protected

      def failure
        redirect! '/401'
      end

      def success(obj)
        Rails.logger.info "Devise Access ID ******* #{obj.access_id}"
        success!(obj)
      end

      def authentication_type
        uri = request.headers['REQUEST_URI']
        this_uri = determine_login_type(uri)
        # this_uri = uri.split('/')[1].camelcase
        Object.const_get(this_uri)
      end

      def determine_login_type(uri)
        this_uri = uri.split('/')
        return 'Author' unless this_uri.length > 1

        this_uri = uri.split('/')[1].gsub(/\.\w+$/, '').camelcase
        this_uri = 'Author' unless ['Author', 'Admin', 'Approver'].include? this_uri
        this_uri
      end
    end
  end
end

Warden::Strategies.add(:oidc_authenticatable, Devise::Strategies::OidcAuthenticatable)

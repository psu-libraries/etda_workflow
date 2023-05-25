class ConfidentialHoldUpdateService
  class << self
    def update(author)
      ldap_result = grab_ldap_results(author)
      return if ldap_result.empty?

      update_confidential_hold(author, ldap_result[:confidential_hold], 'login_controller')
    end

    def update_all
      LdapUniversityDirectory.new.with_connection do |connection|
        Author.find_each do |author|
          ldap_result = ldap_result_connected(author, connection)
          next if ldap_result.empty?

          update_confidential_hold(author, ldap_result[:confidential_hold], 'rake_task')
        end
      end
    end

    private

      # TODO: This method is nearly identical to FacultyMemberMigrationService#retrieve
      # Refactor these methods into a single method within LdapUniversityDirectory
      def ldap_result_connected(author, connection)
        attrs = []
        attrs = connection.search(base: ldap_base,
                                  filter: Net::LDAP::Filter.eq('uid', author.access_id), attributes: attrs)
        mapped_attributes = LdapResult.new(ldap_record: attrs,
                                           attribute_map: LdapResultsMap::AUTHOR_LDAP_MAP).map_directory_info
        return {} if mapped_attributes.blank?

        mapped_attributes.first
      end

      def grab_ldap_results(author)
        LdapUniversityDirectory.new.retrieve(author.access_id, 'uid', LdapResultsMap::AUTHOR_LDAP_MAP)
      end

      def update_confidential_hold(author, conf_hold_result, location)
        if conf_hold_result == true && author.confidential_hold == false
          set_conf_hold(author, location)
          Rails.logger.info "#{author.first_name} #{author.last_name}'s confidential hold status was changed from 'false' to 'true'."
        elsif conf_hold_result != true && author.confidential_hold == true
          remove_conf_hold(author, location)
          Rails.logger.info "#{author.first_name} #{author.last_name}'s confidential hold status was changed from 'true' to 'false'."
        end
      end

      def set_conf_hold(author, location)
        author.attributes = { confidential_hold: true, confidential_hold_set_at: DateTime.now }
        ConfidentialHoldHistory.create(set_at: DateTime.now, set_by: location, author:)
        author.save(validate: false)
      end

      def remove_conf_hold(author, location)
        author.attributes = { confidential_hold: false, confidential_hold_set_at: nil }
        last_conf_hold = author.confidential_hold_histories.last
        if last_conf_hold.present?
          last_conf_hold.update!(removed_at: DateTime.now, removed_by: location)
        else
          ConfidentialHoldHistory.create(removed_at: DateTime.now, removed_by: location, author:)
        end
        author.save(validate: false)
      end

      def ldap_base
        Rails.application.config_for(:ldap)['base']
      end
  end
end

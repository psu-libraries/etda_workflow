class ConfidentialHoldUpdateService
  class InvalidActionLocality < StandardError; end
  attr_reader :updater
  attr_accessor :author

  def initialize(author, action_locality)
    @action_locality = action_locality
    @author = author
  end

  def update
    ldap_result = grab_ldap_results
    update_confidential_hold(ldap_result[:confidential_hold])
  end

  private

  def updater
    raise InvalidActionLocality, "action_locality must be 'login_controller' or 'daily_report'." unless ['login_controller', 'daily_report'].include? @action_locality.to_s

    @action_locality.to_s
  end

  def grab_ldap_results
    directory = LdapUniversityDirectory.new
    results = directory.retrieve(@author.access_id, LdapResultsMap::AUTHOR_LDAP_MAP)
    return if results == {}

    results
  end

  def update_confidential_hold(conf_hold_result)
    case
    when conf_hold_result == true && @author.confidential_hold == false
      @author.update_attributes confidential_hold: true, confidential_hold_set_at: DateTime.now
      @author.confidential_hold_histories << ConfidentialHoldHistory.create(set_at: DateTime.now, set_by: updater)
    when conf_hold_result != true && @author.confidential_hold == true
      @author.update_attributes confidential_hold: false, confidential_hold_set_at: nil
      last_conf_hold = @author.confidential_hold_histories.last
      if last_conf_hold.present?
        last_conf_hold.update_attributes(removed_at: DateTime.now, removed_by: updater)
      else
        @author.confidential_hold_histories << ConfidentialHoldHistory.create(removed_at: DateTime.now, removed_by: updater)
      end
    else
      return
    end
  end
end

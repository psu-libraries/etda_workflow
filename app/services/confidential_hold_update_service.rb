class ConfidentialHoldUpdateService
  class InvalidActionLocality < StandardError; end
  attr_accessor :author
  attr_reader :updater

  def initialize(author, action_locality)
    @updater = assign_updater(action_locality.to_s)
    @author = author
  end

  def update
    ldap_result = grab_ldap_results
    return if ldap_result.empty?

    update_confidential_hold(ldap_result[:confidential_hold])
  end

  private

  def grab_ldap_results
    directory = LdapUniversityDirectory.new
    directory.retrieve(@author.access_id, LdapResultsMap::AUTHOR_LDAP_MAP)
  end

  def update_confidential_hold(conf_hold_result)
    if conf_hold_result == true && @author.confidential_hold == false
      set_conf_hold
    elsif conf_hold_result != true && @author.confidential_hold == true
      remove_conf_hold
    end
  end

  def set_conf_hold
    @author.update_attributes confidential_hold: true, confidential_hold_set_at: DateTime.now
    @author.confidential_hold_histories << ConfidentialHoldHistory.create(set_at: DateTime.now, set_by: updater)
  end

  def remove_conf_hold
    @author.update_attributes confidential_hold: false, confidential_hold_set_at: nil
    last_conf_hold = @author.confidential_hold_histories.last
    if last_conf_hold.present?
      last_conf_hold.update_attributes(removed_at: DateTime.now, removed_by: updater)
    else
      @author.confidential_hold_histories << ConfidentialHoldHistory.create(removed_at: DateTime.now, removed_by: updater)
    end
  end

  def assign_updater(action_locality)
    localities = ['login_controller', 'rake_task']
    raise InvalidActionLocality, "The value of the action_locality parameter must be in this list: #{localities}." unless localities.include? action_locality

    action_locality
  end
end

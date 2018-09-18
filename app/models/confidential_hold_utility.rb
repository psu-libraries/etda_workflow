# frozen_string_literal: true

class ConfidentialHoldUtility
  attr_reader :original_confidential_status
  attr_accessor :new_confidential_status
  attr_reader :this_access_id

  def initialize(access_id, original_confidential_status, current_status = nil)
    # original_confidential_status is the conf. hold status currently in the author's record
    # new_confidential_status is the author's confidential status found in LDAP
    # if author is not in LDAP it uses the value of confidential hold in the author's record
    # it can also be set from a parameter (used by admin when editing)
    @this_access_id = access_id || ''
    @original_confidential_status = original_confidential_status.nil? ? false : original_confidential_status
    @new_confidential_status = current_status.nil? ? set_confidential_status : current_status
  end

  def set_confidential_status
    directory = LdapUniversityDirectory.new
    if directory.exists? @this_access_id
      current_status = directory.authors_confidential_status(@this_access_id)
    else
      author = Author.find_by(access_id: @this_access_id)
      return false if author.nil?

      current_status = author.confidential_hold || nil
    end
    current_status
  end

  def send_confidential_status_notifications(author)
    send_update_to_confidential_email(author) if changed_to_confidential?
    send_release_hold_email(author) if confidential_hold_released?
  end

  def changed?
    new_confidential_status != original_confidential_status
  end

  def currently_confidential?
    new_confidential_status
  end

  def hold_set_at(current_hold_time, confidential_hold_value_now)
    return nil unless confidential_hold_value_now
    return Time.zone.now if confidential_hold_value_now && current_hold_time.nil?

    current_hold_time
  end

  private

  def send_update_to_confidential_email(author)
    # send email
    # WorkflowMailer.confidential_hold_set_email(author).deliver_now
  end

  def send_release_hold_email(author)
    # WorkflowMailer.confidential_hold_released_email(author).deliver_now
    # send email
  end

  def changed_to_confidential?
    return true if currently_confidential? && !was_confidential?

    false
  end

  def confidential_hold_released?
    return true if !currently_confidential? && was_confidential?

    false
  end

  def was_confidential?
    original_confidential_status
  end
end

class AccessLevelUpdatedEmail
  def initialize(submission, partner = current_partner, mail_sender = WorkflowMailer)
    @partner = partner
    @submission = submission
    @mail_sender = mail_sender
  end

  def deliver
    @mail_sender.access_level_updated(to_hash).deliver_now
  end

  private

  def self.otm_email_address
    I18n.t('external_contacts.otm.email_address')
  end

  def submission
    @submission.reload
    @submission
  end

  def cc_address
    return self.class.otm_email_address if previous_level == 'restricted' && current_level.open_access?

    return self.class.otm_email_address if partner.graduate?

    nil
  end

  def graduate_degree_type
    return '' if submission.degree_type.nil?

    submission.degree_type.name
  end

  def previous_level
    submission.previous_access_level
  end

  def previous_level_label
    return '' if previous_level.blank?

    AccessLevel.new(previous_level).attributes
  end

  def current_level
    submission.access_level
  end

  def to_hash
    {
      author_psu_email_address: submission.author_psu_email_address,
      author_alternate_email_address: submission.author.alternate_email_address,
      cc_email_addresses: cc_address,
      author_full_name: submission.author_full_name,
      new_access_level_label: submission.current_access_level.label,
      old_access_level_label: previous_level_label,
      title: submission.title,
      degree_type: graduate_degree_type,
      graduation_year: submission.year
    }
  end
end

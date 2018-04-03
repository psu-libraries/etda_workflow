class AccessLevelUpdatedEmail
attr_reader :old_submission

def self.cataloging_email_address
  'ul-etd-release@lists.psu.edu'
end

def self.otm_email_address
  'otminfo@psu.edu'
end

def initialize(submission, partner = current_partner, mail_sender = AuthorMailer)
  @partner = partner
  @submission = submission
  @mail_sender = mail_sender
end

def submission
  @submission.reload
  @submission
end

def cc_addresses
  return [self.class.otm_email_address, self.class.cataloging_email_address] if previous_level == 'restricted' && current_level.open_access?

  graduate_cc_addresses
end

def graduate_degree_type
  return '' if submission.degree_type.nil?
  submission.degree_type.name
end

def graduate_cc_addresses
  result = []
  return result unless partner.graduate?

  if previous_level == 'restricted_to_institution' && current_level.open_access?
    result = [self.class.otm_email_address, self.class.cataloging_email_address]
  elsif previous_level == 'restricted' && current_level == 'restricted_to_institution'
    result = [self.class.otm_email_address]
  end
  result
end

def previous_level
  submission.previous_access_level
end

def previous_level_label
  return '' if previous_level.blank?
  previous_level.attributes
end

def current_level
  submission.access_level
end

def to_hash
  {
    author_psu_email_address: submission.author_psu_email_address,
    author_alternate_email_address: submission.author.alternate_email_address,
    cc_email_addresses: cc_addresses,
    author_full_name: submission.author_full_name,
    new_access_level_label: submission.current_access_level.label,
    old_access_level_label: previous_level_label,
    title: submission.title,
    degree_type: graduate_degree_type,
    graduation_year: submission.year
  }
end

def deliver
  @mail_sender.access_level_updated(to_hash).deliver_now
end

  private

attr_reader :partner
end

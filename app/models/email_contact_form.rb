class EmailContactForm < MailForm::Base
  attribute :full_name,      validate: true
  attribute :email,          validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :psu_id,         validate: true, allow_blank: true
  attribute :desc,           validate: true
  attribute :message,        validate: true
  attribute :issue_type,     validate: :issue_type_valid?
  attribute :nickname,       captcha: true

  def issue_type_valid?
    return true if issue_type.present? && EmailContactForm.issue_types.key?(issue_type.to_sym)

    errors.add(:issue_type, "Invalid Issue Type")
  end

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      from: from_address,
      to: to_address,
      subject: "#{current_partner.slug} Contact Form"
    }
  end

  def self.issue_types
    { general: 'General/Technical Issues', failures: 'Site Failures/500 Errors' }.freeze
  end

  def self.tooltip_message
    "<strong>General/Technical Issues:</strong>
     Your email will be directed to The #{current_partner.name} IT/administrative support staff.
     If you have questions about formatting, publication dates, timing, requirements, usage, if you
     need data to be changed by an administrator, or if you are having trouble uploading your submission,
     please select this option.<br/><br/>
     <strong>Site Failures/500 Errors:</strong>
     Your email will be directed to The Libraries engineering team.
     If you are encountering server error messages (i.e. 500 codes), or other site failures,
     please select this option.".html_safe
  end

  def self.contact_form_message(message, desc, email, psuid, full_name)
    ActionMailer::Base.mail(
      from: full_name,
      email_address: email,
      psuid: psuid,
      subject: desc,
      body: message
    ).deliver
  end

  private

    def to_address
      return I18n.t('ul_etda_support_email_address').to_s if issue_type.to_sym == :failures

      current_partner.email_address.to_s
    end

    def from_address
      return email if issue_type.to_sym == :failures

      EtdaWorkflow::Application.config.action_mailer.default_options[:from]
    end
end

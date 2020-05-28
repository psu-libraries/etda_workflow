class EmailContactForm < MailForm::Base
  attribute :full_name,      validate: true
  attribute :email,          validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :psu_id,         validate: true, allow_blank: true
  attribute :desc,           validate: true
  attribute :message,        validate: true
  attribute :issue_type,     validate: :issue_type_valid?
  attribute :nickname,       captcha: true

  def issue_type_valid?
    return true if issue_type.present? && EmailContactForm.issue_types.key?(issue_type)

    false
  end

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      from: EtdaWorkflow::Application.config.action_mailer.default_options[:from],
      to: to_address,
      subject: "#{current_partner.slug} Contact Form"
    }
  end

  def self.issue_types
    { formatting: 'General Formatting/Usage Issues', technical: 'Technical Issues' }.freeze
  end

  def self.tooltip_message
    "<strong>General Formatting/Usage Issues:</strong>
     Your email will be directed to The #{current_partner.name}.
     If you are unsure about what data to input, the next steps to take, how to use the application,
     or need data to be changed by an administrator, please select this option.<br/><br/>
     <strong>Technical Issues:</strong>
     Your email will be directed to IT support staff.
     If you are encountering error messages, having trouble accessing pages, not seeing data that should be displayed,
     or any other technical issues, please select this option.".html_safe
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
    return I18n.t('ul_etda_support_email_address').to_s if issue_type == :technical

    current_partner.email_address.to_s
  end
end

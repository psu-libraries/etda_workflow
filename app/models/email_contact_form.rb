class EmailContactForm < MailForm::Base
  attribute :full_name,      validate: true
  attribute :email,          validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :psu_id,         validate: true, allow_blank: true
  attribute :desc,           validate: true
  attribute :message,        validate: true
  attribute :issue_type,     validate: true
  attribute :nickname,       captcha: true

  def tooltip_message
    "<strong>General formatting/data issues:</strong> Your email will be directed to The #{current_partner.name}.
     If you are unsure about what data to input, the next steps to take, or need data to be changed by an administrator,
     please select this option.<br/><br/><strong>Failures to upload, access, or submit:
     </strong>  Your email will be directed to IT support staff.
     If you are encountering website issues, having trouble accessing pages, not seeing data that should be displayed,
     or any other technical issues, please select this option.".html_safe
  end

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      from: EtdaWorkflow::Application.config.action_mailer.default_options[:from],
      to: current_partner.email_address.to_s,
      subject: "#{current_partner.slug} Contact Form"
    }
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
end

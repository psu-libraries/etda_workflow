class EmailContactForm < MailForm::Base
  attribute :full_name,      validate: true
  attribute :email,          validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :psu_id,         validate: true, allow_blank: true
  attribute :desc,           validate: true
  attribute :message,        validate: true
  attribute :nickname,       captcha: true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      from:    EtdaWorkflow::Application.config.action_mailer.default_options[:from],
      to:      current_partner.email_address.to_s,
      subject: "#{current_partner.slug} Contact Form"
    }
  end

  def self.contact_form_message(message, desc, email, psuid, full_name)
    ActionMailer::Base.mail(
      from:     full_name,
      email_address: email,
      psuid: psuid,
      subject:  desc,
      body:     message
    ).deliver
  end
end

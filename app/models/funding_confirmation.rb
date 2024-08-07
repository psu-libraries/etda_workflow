class FundingConfirmation
  include ActiveModel::Model

  attr_accessor :training_funding_confirmation, :other_funding_confirmation, :admin_funding_confirmation, :is_admin

  validates :training_funding_confirmation, :other_funding_confirmation, :admin_funding_confirmation,
  acceptance: {:accept => "true", :message => I18n.t("#{current_partner.id}.federal_funding_author.error_message").html_safe}

  validates :training_funding_confirmation, :other_funding_confirmation,
    presence: {:accept => "true", :message => I18n.t("#{current_partner.id}.federal_funding_author.error_message").html_safe},
    if: Proc.new { |funding_confirmation| funding_confirmation.is_admin == false }

  validates :admin_funding_confirmation,
    presence: {:accept => "true", :message => I18n.t("#{current_partner.id}.federal_funding_admin.error_message_2").html_safe},
    if: Proc.new { |funding_confirmation| funding_confirmation.is_admin == true }

end

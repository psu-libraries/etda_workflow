# frozen_string_literal: true

class FederalFundingDetails < ApplicationRecord
  belongs_to :submission

  attr_accessor :is_admin
  ERROR_MESSAGE =I18n.t("#{current_partner.id}.federal_funding_author.error_message").html_safe

  validates :training_support_funding, :other_funding, inclusion: { in: [true, false] }

  validates :training_support_acknowledged,
    acceptance: {:accept => true, :message => ERROR_MESSAGE },
    if: Proc.new { |f| f.training_support_funding }

  validates :other_funding_acknowledged,
    acceptance: {:accept => true, :message => ERROR_MESSAGE},
    if: Proc.new { |f| f.other_funding }
end

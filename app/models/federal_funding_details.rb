# frozen_string_literal: true

class FederalFundingDetails < ApplicationRecord
  belongs_to :submission

  ERROR_MESSAGE = I18n.t("#{current_partner.id}.federal_funding_author.error_message").html_safe

  validates :training_support_funding, :other_funding, inclusion: { in: [true, false], message: ERROR_MESSAGE }

  validates :training_support_acknowledged,
            acceptance: { accept: true, message: ERROR_MESSAGE },
            presence: { accept: true, message: ERROR_MESSAGE },
            if: proc { |f| f.training_support_funding }

  validates :other_funding_acknowledged,
            acceptance: { accept: true, message: ERROR_MESSAGE },
            presence: { accept: true, message: ERROR_MESSAGE },
            if: proc { |f| f.other_funding }

  def uses_federal_funding?
    training_support_funding || other_funding
  end
end

# frozen_string_literal: true

class FederalFundingDetails < ApplicationRecord
  belongs_to :submission
  before_save :update_federal_funding

  attr_accessor :author_edit

  ERROR_MESSAGE = I18n.t("#{current_partner.id}.federal_funding_author.error_message").html_safe

  validates :training_support_funding, :other_funding,
            inclusion: { in: [true, false], message: ERROR_MESSAGE },
            if: proc { |f| f.author_edit && submission.status_behavior.beyond_collecting_committee? && current_partner.graduate? }

  validates :training_support_acknowledged,
            presence: { presence: true, message: ERROR_MESSAGE },
            if: proc { |f| f.training_support_funding && f.author_edit && submission.status_behavior.beyond_collecting_committee? && current_partner.graduate? }

  validates :other_funding_acknowledged,
            presence: { presence: true, message: ERROR_MESSAGE },
            if: proc { |f| f.other_funding && f.author_edit && submission.status_behavior.beyond_collecting_committee? && current_partner.graduate? }

  def uses_federal_funding?
    training_support_funding || other_funding
  end

  private

    def update_federal_funding
      submission.update_federal_funding
    end
end

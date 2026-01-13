# frozen_string_literal: true

class AddRemediationFieldsToFinalSubmissionFiles < ActiveRecord::Migration[7.2]
  def change
    add_column :final_submission_files, :remediation_started_at, :datetime
    add_column :final_submission_files, :remediation_job_uuid, :string
  end
end

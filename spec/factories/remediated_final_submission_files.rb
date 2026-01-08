# frozen_string_literal: true

FactoryBot.define do
  factory :remediated_final_submission_file, class: 'RemediatedFinalSubmissionFile' do |_f|
    submission
    final_submission_file
    asset { File.open(fixture('files/final_submission_file_01.pdf')) }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :final_submission_file, class: 'FinalSubmissionFile' do |_f|
    submission
    asset { File.open(fixture('files/final_submission_file_01.pdf')) }

    trait :pdf do
      asset { File.open(fixture('files/final_submission_file_01.pdf')) }
    end

    trait :docx do
      asset { File.open(fixture('files/final_submission_file_02.docx')) }
    end

    trait :released_open do
      association :submission,  :released_for_publication
    end

    trait :released_institution do
      association :submission,  :final_is_restricted_to_institution
    end
  end
end

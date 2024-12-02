# frozen_string_literal: true

FactoryBot.define do
  factory :format_review_file, class: 'FormatReviewFile' do |_f|
    submission
    asset { File.open(fixture('files/format_review_file_01.pdf')) }

    trait :pdf do
      asset { File.open(fixture('files/format_review_file_02.pdf')) }
    end

    trait :docx do
      asset { File.open(fixture('files/format_review_file_03.docx')) }
    end
  end
end

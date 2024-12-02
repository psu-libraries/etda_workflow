# # frozen_string_literal: true

FactoryBot.define do
  factory :admin_feedback_file, class: 'AdminFeedbackFile' do |_f|
    submission
    asset { File.open(fixture('files/admin_feedback_01.pdf')) }
  end
end

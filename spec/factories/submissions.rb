# frozen_string_literal: true

FactoryBot.define do
  factory :submission, class: Submission do |_s|
    sequence(:title) { |n| "A Title t#{n}" }
    author
    program
    degree
    semester { "Spring" }
    year { Time.zone.today.next_year.year }
    access_level { 'open_access' }
    defended_at { Time.zone.tomorrow if current_partner.graduate? }
    federal_funding { false }
    #    lion_path_degree_code { LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN].first[LionPath::LpKeys::DEGREE_CODE] }

    trait :collecting_program_information do
      committee_provided_at { nil }
      status { "collecting program information" }
    end

    trait :collecting_committee do
      committee_provided_at { nil }
      status { "collecting committee" }
    end

    trait :collecting_format_review_files do
      committee_provided_at { 4.days.ago }
      status { "collecting format review files" }
    end

    trait :collecting_format_review_files_rejected do
      format_review_rejected_at { Time.zone.now }
      status { 'collecting format review files rejected' }
    end

    trait :waiting_for_format_review_response do
      format_review_files_uploaded_at { 3.days.ago }
      status { "waiting for format review response" }
    end

    trait :collecting_final_submission_files do
      status { "collecting final submission files" }
      final_submission_traits
    end

    trait :collecting_final_submission_files_rejected do
      status { "collecting final submission files rejected" }
      final_submission_rejected_at { Time.zone.now }
    end

    trait :final_submission_traits do
      format_review_notes { "Format review notes" }
      abstract { 'my abstract' }
      access_level { 'open_access' }
      has_agreed_to_terms { 1 }
      has_agreed_to_publication_release { 1 }
      final_submission_notes { "Final submission notes" }
      defended_at { Time.zone.yesterday if current_partner.graduate? }
      year { Time.zone.today.year }
      semester { Semester.current.split.last }
      format_review_files_uploaded_at { 3.days.ago }
      format_review_approved_at { 2.days.ago }
      final_submission_approved_at { Time.zone.yesterday }
      publication_release_terms_agreed_to_at { Time.zone.now }
    end

    trait :waiting_for_committee_review do
      status { "waiting for committee review" }
    end

    trait :waiting_for_head_of_program_review do
      status { "waiting for head of program review" }
    end

    trait :waiting_for_committee_review_rejected do
      status { "waiting for committee review rejected" }
    end

    trait :waiting_for_final_submission_response do
      status { "waiting for final submission response" }
      final_submission_traits
    end

    trait :waiting_for_publication_release do
      status { "waiting for publication release" }
      final_submission_traits
    end

    trait :waiting_in_final_submission_on_hold do
      status { "waiting in final submission on hold" }
      final_submission_traits
    end

    trait :released_for_publication do
      status { "released for publication" }
      released_for_publication_at { Time.zone.yesterday }
      final_submission_traits
    end

    trait :final_is_restricted do
      status { "released for publication metadata only" }
      access_level { 'restricted' }
      format_review_notes { "Format review notes" }
      released_for_publication_at { Time.zone.yesterday + 2.years }
      released_metadata_at { Time.zone.yesterday }
      invention_disclosures { [InventionDisclosure.create(id_number: '2018-1234', id: id)] }
      final_submission_traits
    end

    trait :final_is_restricted_to_institution do
      status { "released for publication" }
      access_level { 'restricted_to_institution' }
      released_metadata_at { Time.zone.yesterday }
      released_for_publication_at { Time.zone.yesterday + 2.years }
      final_submission_traits
    end

    trait :legacy do
      final_submission_legacy_id { 999 }
      released_for_publication_at { nil }
      released_metadata_at { Time.zone.yesterday }
      final_submission_traits
    end

    trait :released_for_publication_legacy do
      status { "released for publication" }
      legacy_id { 888 }
      released_for_publication_at { nil }
      released_metadata_at { Time.zone.yesterday }
      final_submission_traits
    end

    after(:create) do |submission|
      create_list(:keyword, 2, submission: submission)
    end
  end
end

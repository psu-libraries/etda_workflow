# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe SolrSubmission, type: :model do
  let(:solr_submission) { described_class.new(submission) }

  describe '#to_solr' do
    let(:submission) do
      create :submission, :released_for_publication,
             legacy_id: 123,
             final_submission_legacy_old_id: 321,
             public_id: '1234abc32',
             released_metadata_at: DateTime.now,
             final_submission_files_uploaded_at: DateTime.now
    end
    let(:final_submission_file_1) { create :final_submission_file }
    let(:final_submission_file_2) { create :final_submission_file }
    let(:format_review_file) { create :format_review_file }
    let(:committee_member_1) { create :committee_member }
    let(:committee_member_2) { create :committee_member }

    it 'generates solr doc from submission attributes' do
      submission.committee_members << committee_member_1
      submission.committee_members << committee_member_2
      submission.final_submission_files << final_submission_file_1
      submission.final_submission_files << final_submission_file_2
      submission.format_review_files << format_review_file
      submission.save
      expect(solr_submission.to_solr).to eq({
                                              "abstract_tesi" => submission.abstract,
                                              "access_level_ss" => submission.access_level,
                                              "author_name_tesi" => "#{submission.author_last_name}, #{submission.author_first_name} #{submission.author_middle_name}",
                                              "committee_member_and_role_tesim" => ["#{committee_member_1.name}, #{committee_member_1.committee_role.name}",
                                                                                    "#{committee_member_2.name}, #{committee_member_2.committee_role.name}"],
                                              "committee_member_email_ssim" => [committee_member_1.email.to_s, committee_member_2.email.to_s],
                                              "committee_member_name_ssim" => [committee_member_1.name.to_s, committee_member_2.name.to_s],
                                              "committee_member_name_tesim" => [committee_member_1.name.to_s, committee_member_2.name.to_s],
                                              "committee_member_role_ssim" => ["#{committee_member_1.name}, #{committee_member_1.committee_role.name}",
                                                                               "#{committee_member_2.name}, #{committee_member_2.committee_role.name}"],
                                              "db_id" => submission.id,
                                              "db_legacy_id" => submission.legacy_id,
                                              "db_legacy_old_id" => submission.final_submission_legacy_old_id,
                                              "defended_at_dtsi" => submission.defended_at,
                                              "degree_description_ssi" => submission.degree_description,
                                              "degree_name_ssi" => submission.degree_name,
                                              "degree_type_slug_ssi" => submission.degree_type_slug,
                                              "degree_type_ssi" => submission.degree_type_name,
                                              "file_name_ssim" => [submission.final_submission_files.first.asset_identifier,
                                                                   submission.final_submission_files.second.asset_identifier],
                                              "final_submission_file_isim" => [submission.final_submission_files.first.id,
                                                                               submission.final_submission_files.second.id],
                                              "final_submission_files_uploaded_at_dtsi" => submission.final_submission_files_uploaded_at,
                                              "first_name_ssi" => submission.author_first_name,
                                              "id" => submission.public_id,
                                              "keyword_ssim" => submission.keywords.collect(&:word),
                                              "keyword_tesim" => submission.keywords.collect(&:word),
                                              "last_name_ssi" => submission.author_last_name,
                                              "last_name_tesi" => submission.author_last_name,
                                              "middle_name_ssi" => submission.author_middle_name,
                                              "program_name_ssi" => submission.program_name,
                                              "program_name_tesi" => submission.program_name,
                                              "released_metadata_at_dtsi" => submission.released_metadata_at,
                                              "semester_ssi" => submission.semester,
                                              "title_ssi" => submission.title,
                                              "title_tesi" => submission.title,
                                              "year_isi" => submission.year
                                            })
    end
  end
end
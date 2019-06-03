# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe Legacy::FileImporter do
  xit 'imports final submission files' do
    FileUtils.rm_rf Dir.glob(Rails.root.join('tmp', 'workflow', '*'))
    FileUtils.rm_rf Dir.glob(Rails.root.join('tmp', 'explore', '*'))
    file_importer = described_class.new
    base_path = Rails.root.join('spec/fixtures/legacy/').to_s
    submission1 = FactoryBot.create :submission, :released_for_publication, access_level: 'open_access'
    submission2 = FactoryBot.create :submission, :waiting_for_final_submission_response
    submission3 = FactoryBot.create :submission, :released_for_publication, access_level: 'restricted_to_institution'
    restricted = FactoryBot.create :submission, :final_is_restricted, status: 'released for publication metadata only'

    FinalSubmissionFile.create(asset: File.open(Rails.root.join('spec', 'fixtures', 'legacy', 'final_submission_files', '01', '1', 'FinalSubmissionFile_1.pdf')), submission_id: submission1.id)
    FinalSubmissionFile.create(asset: File.open(Rails.root.join('spec', 'fixtures', 'legacy', 'final_submission_files', '02', '2', 'FinalSubmissionFile_2.pdf')), submission_id: submission2.id)
    FinalSubmissionFile.create(asset: File.open(Rails.root.join('spec', 'fixtures', 'legacy', 'final_submission_files', '03', '3', 'FinalSubmissionFile_3.pdf')), submission_id: submission3.id)
    FinalSubmissionFile.create(asset: File.open(Rails.root.join('spec', 'fixtures', 'legacy', 'final_submission_files', '03', '3', 'RestrictedInstitutionThesis.pdf')), submission_id: restricted.id)
    file_importer.copy_final_submission_files(Rails.root.join(base_path).to_s, true)
  end

  xit 'imports format review files' do
    FileUtils.rm_rf Dir.glob(Rails.root.join('tmp', 'workflow', '*'))
    file_importer = described_class.new
    base_path = Rails.root.join('spec/fixtures/legacy/').to_s
    file_importer.copy_format_review_files(Rails.root.join(base_path).to_s, true)
  end
end

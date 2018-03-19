# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe "Rake::Task['legacy:import']", type: :task do
  before do
    Rails.application.load_tasks
    CommitteeRole.all.each(&:destroy)
    DegreeType.all.each(&:destroy)
  end

  xit 'imports legacy  data' do
    expect(Author.all.count).to be(0)
    expect(DegreeType.all.count).to be(0)
    expect(CommitteeRole.all.count).to be(0)
    expect(Degree.all.count).to be(0)
    expect(Program.all.count).to be(0)
    expect(Submission.all.count).to be(0)
    expect(FormatReviewFile.all.count).to be(0)
    expect(FinalSubmissionFile.all.count).to be(0)
    expect(Keyword.all.count).to be(0)
    expect(CommitteeMember.all.count).to be(0)
    expect(InventionDisclosure.all.count).to be(0)
    Rake::Task['legacy:import:all_data'].invoke
    expect(Author.all.count).to be(3)
    expect(Author.where(address_1: '888 Eight Drive apt#201').count).to be(1)
    expect(DegreeType.all.count).to be(2)
    expect(DegreeType.where(slug: 'dissertation').count).to be(1)
    expect(CommitteeRole.all.count).to be(3)
    expect(CommitteeRole.where(name: 'Committee Member').count).to be(1)
    expect(Degree.all.count).to be(2)
    expect(Degree.where(name: 'Electrical Engineering').count).to be(1)
    expect(Program.all.count).to be(3)
    expect(Program.where(name: 'Advertising').count).to be(1)
    # expect(Submission.all.count).to eq(start_count+4)
    expect(Submission.where(title: 'title here').count).to be(1)
    expect(FormatReviewFile.all.count).to be(3)
    # expect(FormatReviewFile.where(asset: "MathHonorsThesis3.pdf").count).to eq(1)
    expect(FinalSubmissionFile.all.count).to be(3)
    # expect(FinalSubmissionFile.where(asset: 'OpenAccess.pdf').count).to be(1)
    expect(Keyword.all.count).to be(3)
    expect(Keyword.where(word: 'LEZOOMPC').count).to be(1)
    expect(CommitteeMember.all.count).to be(2)
    expect(CommitteeMember.where(name: 'Mr. Committee 1').count).to be(1)
    expect(InventionDisclosure.all.count).to be(2)
    expect(InventionDisclosure.where(id_number: '2018-abc').count).to be(1)
    # Populate asset in FinalSubmissionFile records
    legacy_data_helper = LegacyDataHelper.new
    legacy_data_helper.load_assets(Rails.root.join('spec/fixtures/legacy/final_submission_files/').to_s)
    # Empty file directories
    legacy_data_helper.empty_file_directories
    workflow_files = Rails.root.join('tmp/workflow').to_s
    explore_files = Rails.root.join('tmp/explore').to_s
    source_path = Rails.root.join('spec/fixtures/legacy').to_s
    Rake::Task["legacy:import:all_files"].invoke(source_path)
    expect(Dir).to be_exist(workflow_files)
    expect(Dir).to be_exist(explore_files)
    Rails.root.join('tmp/explore/restricted_institution/03/3/FinalSubmissionFile_3.pdf')
    format_review_file = Rails.root.join('tmp/workflow/format_review_files/FormatUnderReview.pdf')
    restricted_file = Rails.root.join('tmp/workflow/restricted/02/2/FinalSubmissionFile_2.pdf')
    Rails.root.join('tmp/explore/open_access/01/1/FinalSubmissionFile_1.pdf')
    # expect(File.exist?(restricted_institution_file)).to be_truthy
    expect(File).to be_exist(format_review_file)
    expect(File).to be_exist(restricted_file)
    # expect(File.exist?(open_file)).to be_truthy
    expect(File).not_to be_exist('tmp/explore/open_access/02/2/anyoldfile.pdf')
  end
end

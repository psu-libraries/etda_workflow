require 'rails_helper'
require 'shoulda-matchers'
require 'active_record/fixtures'

# This is xit'd out because it causes other tests to fail in the suite
# When testing locally, remove 'x' and run the test solo to test if it is working
RSpec.describe "Rake::Task['final_files:verify']", type: :task do

  let(:all_clear_message) do
    /File Verification for ETDA(.*)\nCreated report(.*)\nFinal Submission Files in database: 2\nMissing and\/or misplaced file count: 0/
  end

  let(:misplaced_message) do
    /File Verification for ETDA(.*)\nCreated report(.*)\nPossible match for file(.*)\nCannot verify correct file has been located:(.*)\nFinal Submission Files in database: 3\nMissing and\/or misplaced file count: 1/
  end

  before do
    Rails.application.load_tasks
    Rake::Task.define_task(:environment)
    root_dir = Rails.root.join('tmp')
    FileUtils.rm_rf(Dir["#{root_dir}/explore/*"])
    FileUtils.rm_rf(Dir["#{root_dir}/workflow/*"])
    submission1 = FactoryBot.create(:submission, :released_for_publication)
    submission2 = FactoryBot.create(:submission, :waiting_for_publication_release)
    FileUtils.copy(Rails.root.join('spec', 'fixtures', 'final_submission_file_01.pdf'), Rails.root.join('tmp', 'explore', 'explore_file_01.pdf'))
    FileUtils.copy(Rails.root.join('spec', 'fixtures', 'final_submission_file_01.pdf'), Rails.root.join('tmp', 'workflow', 'workflow_file_01.pdf'))
    FinalSubmissionFile.create(asset: File.open(Rails.root.join('tmp', 'explore', 'explore_file_01.pdf')), submission_id: submission1.id)
    FinalSubmissionFile.create(asset: File.open(Rails.root.join('tmp', 'workflow','workflow_file_01.pdf')), submission_id: submission2.id)
  end

  xit 'verifies location of files and does not find any misplaced files' do
    Rake::Task['final_files:verify'].reenable
    # allow_any_instance_of(EtdaFilePaths).to receive(:detailed_file_path).and_return('99/999')
    num_files = FinalSubmissionFile.all.count
    expect{ Rake::Task['final_files:verify'].invoke }.to output(all_clear_message).to_stdout
    expect(ActionMailer::Base.deliveries.last).to be nil
  end

  xit 'verifies location of files and identifies misplaced file' do
    submission3 = FactoryBot.create(:submission, :waiting_for_publication_release)
    FileUtils.copy(Rails.root.join('spec', 'fixtures', 'final_submission_file_01.pdf'), Rails.root.join('tmp', 'workflow', 'workflow_file_02.pdf'))
    final_submission = FinalSubmissionFile.create(asset: File.open(Rails.root.join('tmp', 'workflow','workflow_file_02.pdf')), submission_id: submission3.id)
    FileUtils.rm(final_submission.current_location)

    Rake::Task['final_files:verify'].reenable

    Rake::Task['final_files:verify'].invoke
    #expect{ Rake::Task['final_files:verify'].invoke }.to output(misplaced_message).to_stdout
    expect(ActionMailer::Base.deliveries.last.from).to eq ['ajk5603@psu.edu']
    expect(ActionMailer::Base.deliveries.last.to).to eq ['ajk5603@psu.edu']
    expect(ActionMailer::Base.deliveries.last.subject).to eq 'VERIFY FILES: Misplaced files found'
  end
end
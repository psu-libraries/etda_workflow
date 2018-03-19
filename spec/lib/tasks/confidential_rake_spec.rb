# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'
require 'shared/shared_examples_for_university_directory'

RSpec.describe "Rake::Task['confidential:checker']", type: :task do
  Rails.application.load_tasks

  subject(:task) { Rake::Task['confidential:checker'] }

  let(:author) { FactoryBot.create :author }
  let(:submission) { FactoryBot.create :submission, :waiting_for_publication_release }

  before { task.reenable }

  context 'updates author record when confidential hold value changes' do
    xit "becomes true when author's LDAP attribute is true" do
      author.confidential_hold = false
      expect(author.confidential_hold).to be_falsey
      expect(Author.where(confidential_hold: true).count).to eq(0)
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      allow_any_instance_of(ConfidentialHoldUtility).to receive(:new_confidential_status).and_return(true)
      expect { task.invoke }.not_to raise_error
      author.reload
      expect(author.confidential_hold).to be_truthy
      expect(Author.where(confidential_hold: true).count).to eq(1)
    end
    xit "becomes false when author's LDAP attribute is false" do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      author.confidential_hold = true
      author.save validate: false
      expect(author.confidential_hold).to be_truthy
      expect(Author.where(confidential_hold: false).count).to eq(0)
      allow_any_instance_of(ConfidentialHoldUtility).to receive(:new_confidential_status).and_return(false)
      expect { task.invoke }.not_to raise_error
      author.reload
      expect(author.confidential_hold).to be_falsey
      expect(Author.where(confidential_hold: false).count).to eq(1)
    end
  end

  context 'submission status is updated when a confidential hold is placed' do
    xit "embargoes the submission when the submission status is 'waiting for publication release'" do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      allow_any_instance_of(ConfidentialHoldUtility).to receive(:new_confidential_status).and_return(true)
      author.confidential_hold = false
      expect(author.confidential_hold).to be_falsey
      expect(Author.where(confidential_hold: true).count).to eq(0)
      expect(submission.status_behavior).to be_waiting_for_publication_release
      expect { task.invoke }.not_to raise_error
      submission.reload
      expect(submission.status_behavior).to be_embargoed
    end
    xit "does not change the submission status when status is not 'waiting for publication release'" do
      new_author = FactoryBot.create :author
      new_submission = FactoryBot.create :submission, :collecting_final_submission_files, author: new_author
      new_author.confidential_hold = false
      expect(new_author.confidential_hold).to be_falsey
      expect(Author.where(confidential_hold: true).count).to eq(0)
      expect(new_submission.status_behavior).not_to be_waiting_for_publication_release
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      allow_any_instance_of(ConfidentialHoldUtility).to receive(:new_confidential_status).and_return(true)
      expect { task.invoke }.not_to raise_error
      new_submission.reload
      new_author.reload
      expect(new_author.confidential_hold).to be_truthy
      expect(new_submission.status_behavior).not_to be_embargoed
      expect(new_submission.status_behavior).to be_collecting_final_submission_files
    end
  end

  describe 'Rake::Task::confidential:report', type: :task do
    subject(:task) { Rake::Task['confidential:report'] }

    context 'reports authors with confidential hold' do
      xit "prints message, then lists authors" do
        author = Author.new(access_id: 'conf123')
        author.save validate: false
        msg = "Reporting authors with a confidential hold\nAuthor with id: #{author.id} #{author.access_id} has a confidential hold\n"
        expect { task.invoke }.to output(msg).to_stdout
      end
    end
  end
end

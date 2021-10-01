require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe SeventhDayEvaluationWorker do
  let!(:degree1) { FactoryBot.create :degree, degree_type: DegreeType.default }
  let!(:degree2) { FactoryBot.create :degree, degree_type: DegreeType.last }
  let!(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, degree: degree1 }

  it 'queues to sidekiq via worker' do
    expect { described_class.perform_in(7.days, submission.id) }.to change { Sidekiq::Worker.jobs.size }.by(1)
  end

  context 'when worker is performed' do
    context "when submission status is not 'waiting for committee review'" do
      before do
        submission.update status: 'waiting for final submission response'
      end

      it 'does not send emails or send to SubmissionStatusUpdaterService' do
        expect_any_instance_of(SubmissionStatusUpdaterService).not_to receive(:update_status_from_committee)
        expect { described_class.perform_async(submission.id) }.to change { WorkflowMailer.deliveries.size }.by(0)
      end
    end

    context "when submission status is 'waiting for committee review'" do
      context "when submission approval status is 'pending'" do
        before do
          create_committee submission
          allow_any_instance_of(ApprovalStatus).to receive(:status).and_return 'pending'
          allow_any_instance_of(Submission).to receive(:head_of_program_is_approving?).and_return false
        end

        context "when graduate school and a dissertation submission" do
          it 'sends dissertation emails' do
            skip "graduate only" unless current_partner.graduate?

            Sidekiq::Testing.inline! do
              expect { described_class.perform_async(submission.id) }.to change { WorkflowMailer.deliveries.size }.by(2)
            end
            expect(WorkflowMailer.deliveries.first.subject).to eq "#{submission.author.first_name} #{submission.author.last_name} Committee 7-day Deadline Reached"
            expect(WorkflowMailer.deliveries.second.subject).to eq "ETD Committee Still Processing"
          end
        end

        context 'when graduate and a masters thesis submission' do
          it 'sends non dissertation emails' do
            skip "graduate only" unless current_partner.graduate?

            submission.update degree: degree2
            Sidekiq::Testing.inline! do
              expect { described_class.perform_async(submission.id) }.to change { WorkflowMailer.deliveries.size }.by(6)
            end
            expect(WorkflowMailer.deliveries.first.subject).to match(/Review Reminder/)
          end
        end

        context 'when non graduate', sset: true, honors: true, milsch: true do
          it 'sends non dissertation emails' do
            skip "non graduate only" if current_partner.graduate?

            Sidekiq::Testing.inline! do
              expect { described_class.perform_async(submission.id) }.to change { WorkflowMailer.deliveries.size }.by(2) if current_partner.honors?
              expect { described_class.perform_async(submission.id) }.to change { WorkflowMailer.deliveries.size }.by(1) if current_partner.milsch?
              expect { described_class.perform_async(submission.id) }.to change { WorkflowMailer.deliveries.size }.by(4) if current_partner.sset?
            end
            expect(WorkflowMailer.deliveries.first.subject).to match(/Review Reminder/)
          end
        end
      end

      context "when submission approval status is not 'pending'" do
        before do
          create_committee submission
          allow_any_instance_of(ApprovalStatus).to receive(:status).and_return 'approved'
          allow_any_instance_of(Submission).to receive(:head_of_program_is_approving?).and_return false
        end

        it 'runs submission status update from committee' do
          expect_any_instance_of(SubmissionStatusUpdaterService).to receive(:update_status_from_committee)
          Sidekiq::Testing.inline! do
            described_class.perform_async(submission.id)
          end
        end
      end
    end
  end
end

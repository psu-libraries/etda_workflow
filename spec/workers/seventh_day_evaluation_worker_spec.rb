require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe SeventhDayEvaluationWorker do
  let!(:degree1) { FactoryBot.create :degree, degree_type: DegreeType.default }
  let!(:degree2) { FactoryBot.create :degree, degree_type: DegreeType.last }
  let!(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, degree: degree1 }
  let!(:approval_configuration) do
    ApprovalConfiguration.create(configuration_threshold: 66,
                                 use_percentage: 1,
                                 approval_deadline_on: Time.zone.today,
                                 head_of_program_is_approving: false)
  end

  before do
    submission.degree.degree_type.approval_configuration = approval_configuration
  end

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

      context "when submission approval status is 'approved'" do
        before do
          allow_any_instance_of(Submission).to receive(:head_of_program_is_approving?).and_return false
          allow(described_class).to receive(:perform_in).with(7.days, submission.id, final_reminder_sent: true)
        end

        context "when graduate and there are nonvoting members" do
          before do
            submission.committee_members << FactoryBot.create(:committee_member, :review_started,
                                                              submission:,
                                                              status: 'approved',
                                                              is_voting: true,
                                                              approval_started_at: (DateTime.now - (7.days + 1.hour)))
            submission.committee_members << FactoryBot.create(:committee_member, :review_started,
                                                              submission:,
                                                              status: 'approved',
                                                              is_voting: true,
                                                              approval_started_at: (DateTime.now - (7.days + 1.hour)))
            submission.committee_members << FactoryBot.create(:committee_member, :review_started,
                                                              submission:,
                                                              status: 'approved',
                                                              is_voting: true,
                                                              approval_started_at: (DateTime.now - (7.days + 1.hour)))
            submission.committee_members << FactoryBot.create(:committee_member, :review_started,
                                                              submission:,
                                                              status: '',
                                                              is_voting: true,
                                                              approval_started_at: (DateTime.now - (7.days + 1.hour)))
          end

          it 'sends final reminder emails' do
            skip "graduate only" unless current_partner.graduate?

            Sidekiq::Testing.inline! do
              expect { described_class.perform_async(submission.id) }.to change { WorkflowMailer.deliveries.size }.by(1)
              expect(described_class).to have_received(:perform_in).with(7.days, submission.id, final_reminder_sent: true)
            end
            expect(WorkflowMailer.deliveries.first.subject).to match(/Final Review Reminder/)
          end
        end

        context "when all members have voted" do
          before do
            submission.committee_members << FactoryBot.create(:committee_member, :review_started,
                                                              submission:,
                                                              status: 'approved',
                                                              is_voting: true,
                                                              approval_started_at: (DateTime.now - (7.days + 1.hour)))
            submission.committee_members << FactoryBot.create(:committee_member, :review_started,
                                                              submission:,
                                                              status: 'approved',
                                                              is_voting: true,
                                                              approval_started_at: (DateTime.now - (7.days + 1.hour)))
            submission.committee_members << FactoryBot.create(:committee_member, :review_started,
                                                              submission:,
                                                              status: 'approved',
                                                              is_voting: true,
                                                              approval_started_at: (DateTime.now - (7.days + 1.hour)))
          end

          it 'runs submission status update from committee' do
            expect_any_instance_of(SubmissionStatusUpdaterService).to receive(:update_status_from_committee)
            Sidekiq::Testing.inline! do
              described_class.perform_async(submission.id)
            end
          end
        end
      end

      context "when submission status is 'rejected'" do
        before do
          create_committee submission
          allow_any_instance_of(ApprovalStatus).to receive(:status).and_return 'rejected'
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

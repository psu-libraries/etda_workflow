require 'model_spec_helper'

RSpec.describe Lionpath::LionpathAssignChairs do
  subject(:lionpath_assign_chairs) { described_class.new }

  describe '#call' do
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.first }
    let!(:program_head_role) { CommitteeRole.find_by(is_program_head: true, degree_type: degree.degree_type) }
    let!(:program) { FactoryBot.create :program }
    let!(:program_chair) { FactoryBot.create :program_chair, program: program, campus: 'UP', access_id: 'abc123' }

    context 'when submission is before current year' do
      let!(:submission) do
        FactoryBot.create :submission, year: (DateTime.now.year - 1.year), degree: degree, program: program,
                                       campus: 'UP', lionpath_updated_at: DateTime.now
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      it 'does not get a chair' do
        expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
      end
    end

    context 'when submission does not have a lionpath_updated_at timestamp' do
      let!(:submission) do
        FactoryBot.create :submission, year: (DateTime.now.year + 1.year), semester: 'Spring',
                                       degree: degree, program: program, campus: 'UP'
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      it 'does not get a chair' do
        expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
      end
    end

    context 'when submission already has a program chair' do
      let!(:program_head_member) do
        FactoryBot.create :committee_member, committee_role: program_head_role, submission: submission
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      context 'when submission is before current year' do
        let!(:submission) do
          FactoryBot.create :submission, year: (DateTime.now.year - 1.year), degree: degree, program: program,
                                         campus: 'UP', lionpath_updated_at: DateTime.now
        end

        it "does not update pre-existing program chair in submissions' committee" do
          expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
          expect(Submission.find(submission.id).committee_members.first).to eq program_head_member
        end
      end

      context 'when submission is during current year' do
        context 'when submission semester is Spring' do
          let!(:submission) do
            FactoryBot.create :submission, year: DateTime.now.year, semester: 'Spring', degree: degree,
                                           program: program, campus: 'UP', lionpath_updated_at: DateTime.now
          end

          context 'when current semester is Spring' do
            it "updates pre-existing program chair in submissions' committee" do
              allow(Semester).to receive(:current).and_return "#{DateTime.now.year} Spring"
              expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
              expect(Submission.find(submission.id).committee_members.first.access_id).to eq program_chair.access_id
            end
          end

          context 'when current semester is Summer' do
            it "does not update pre-existing program chair in submissions' committee" do
              allow(Semester).to receive(:current).and_return "#{DateTime.now.year} Summer"
              expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
              expect(Submission.find(submission.id).committee_members.first).to eq program_head_member
            end
          end

          context 'when current semester is Fall' do
            it "does not update pre-existing program chair in submissions' committee" do
              allow(Semester).to receive(:current).and_return "#{DateTime.now.year} Fall"
              expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
              expect(Submission.find(submission.id).committee_members.first).to eq program_head_member
            end
          end
        end

        context 'when submission semester is Summer' do
          let!(:submission) do
            FactoryBot.create :submission, year: DateTime.now.year, semester: 'Summer', degree: degree,
                                           program: program, campus: 'UP', lionpath_updated_at: DateTime.now
          end

          context 'when current semester is Spring' do
            it "updates pre-existing program chair in submissions' committee" do
              allow(Semester).to receive(:current).and_return "#{DateTime.now.year} Spring"
              expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
              expect(Submission.find(submission.id).committee_members.first.access_id).to eq program_chair.access_id
            end
          end

          context 'when current semester is Summer' do
            it "updates pre-existing program chair in submissions' committee" do
              allow(Semester).to receive(:current).and_return "#{DateTime.now.year} Summer"
              expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
              expect(Submission.find(submission.id).committee_members.first.access_id).to eq program_chair.access_id
            end
          end

          context 'when current semester is Fall' do
            it "does not update pre-existing program chair in submissions' committee" do
              allow(Semester).to receive(:current).and_return "#{DateTime.now.year} Fall"
              expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
              expect(Submission.find(submission.id).committee_members.first).to eq program_head_member
            end
          end
        end

        context 'when submission semester is Fall' do
          let!(:submission) do
            FactoryBot.create :submission, year: DateTime.now.year, semester: 'Fall', degree: degree,
                                           program: program, campus: 'UP', lionpath_updated_at: DateTime.now
          end

          context 'when current semester is Spring' do
            it "updates pre-existing program chair in submissions' committee" do
              allow(Semester).to receive(:current).and_return "#{DateTime.now.year} Spring"
              expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
              expect(Submission.find(submission.id).committee_members.first.access_id).to eq program_chair.access_id
            end
          end

          context 'when current semester is Summer' do
            it "updates pre-existing program chair in submissions' committee" do
              allow(Semester).to receive(:current).and_return "#{DateTime.now.year} Summer"
              expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
              expect(Submission.find(submission.id).committee_members.first.access_id).to eq program_chair.access_id
            end
          end

          context 'when current semester is Fall' do
            it "updates pre-existing program chair in submissions' committee" do
              allow(Semester).to receive(:current).and_return "#{DateTime.now.year} Fall"
              expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
              expect(Submission.find(submission.id).committee_members.first.access_id).to eq program_chair.access_id
            end
          end
        end
      end

      context 'when submission year is beyond current year' do
        let!(:submission) do
          FactoryBot.create :submission, year: (DateTime.now.year + 1.year), semester: 'Spring', degree: degree,
                                         program: program, campus: 'UP', lionpath_updated_at: DateTime.now
        end

        it "updates pre-existing program chair in submissions' committee" do
          expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
          expect(Submission.find(submission.id).committee_members.first.access_id).to eq program_chair.access_id
        end
      end
    end

    context "when submission doesn't have a program chair yet" do
      let!(:submission) do
        FactoryBot.create :submission, year: DateTime.now.year, semester: 'Summer', lionpath_updated_at: DateTime.now,
                                       degree: degree, program: program, campus: 'UP'
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      it "adds program chair to submissions' committee" do
        expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 1
        expect(Submission.find(submission.id).committee_members.second.access_id).to eq program_chair.access_id
        expect(Submission.find(submission.id).committee_members.second.is_voting).to eq false
        expect(Submission.find(submission.id).committee_members.second.is_required).to eq true
      end
    end
  end
end

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe LionpathCommitteeCheckService do
  let!(:approval_config) do
    FactoryBot.create :approval_configuration, head_of_program_is_approving: true, degree_type: DegreeType.default
  end

  describe '#check_submission' do
    context 'when submission is not from lionpath' do
      let(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
      let(:submission) { FactoryBot.create :submission, degree: degree }

      it 'returns nil' do
        expect(described_class.check_submission(submission)).to eq nil
      end
    end

    context 'when submission is not a dissertation' do
      let(:degree) { FactoryBot.create :degree, degree_type: DegreeType.second }
      let(:submission) { FactoryBot.create :submission, lionpath_updated_at: DateTime.now, degree: degree }

      it 'returns nil' do
        expect(described_class.check_submission(submission)).to eq nil
      end
    end

    context 'when submission has a voting committee' do
      let(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
      let(:submission) { FactoryBot.create :submission, lionpath_updated_at: DateTime.now, degree: degree }

      it 'returns nil' do
        create_committee(submission)
        expect(described_class.check_submission(submission)).to eq nil
      end
    end

    context 'when submission is from lionpath, is a dissertation, and does not have a voting committee' do
      let(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
      let(:submission) { FactoryBot.create :submission, lionpath_updated_at: DateTime.now, degree: degree }
      let(:chair_role) { CommitteeRole.find_by(is_program_head: true) }
      let(:committee_member) { FactoryBot.create :committee_member, committee_role: chair_role, is_voting: false }

      it 'raises error' do
        submission.committee_members << committee_member
        expect { described_class.check_submission(submission) }.to raise_error LionpathCommitteeCheckService::IncompleteLionpathCommittee
      end
    end
  end
end

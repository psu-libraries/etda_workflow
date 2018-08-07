# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe InboundLionPathRecord, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:author_id).of_type(:integer) }
  it { is_expected.to have_db_column(:current_data).of_type(:text) }
  it { is_expected.to have_db_column(:lion_path_degree_code).of_type(:string) }
  it { is_expected.to have_db_index(:author_id) }

  if current_partner.graduate?
    subject = described_class.new(current_data: LionPath::MockLionPathRecord.current_data)

    degree = FactoryBot.create :degree, name: 'PHD', is_active: true, degree_type: DegreeType.default
    another_degree = FactoryBot.create :degree, name: 'MS', is_active: false, degree_type: DegreeType.default
    last_degree = FactoryBot.create :degree, name: 'DEGREE', is_active: true, degree_type: DegreeType.default
    author = FactoryBot.create :author
    inbound_record = FactoryBot.create :inbound_lion_path_record, author: author, current_data: LionPath::MockLionPathRecord.current_data, lion_path_degree_code: 'MS'
    author.inbound_lion_path_record = inbound_record
    submission = FactoryBot.create :submission, :collecting_final_submission_files, author: author, degree_id: degree.id

    context 'record contains data returned from Lion Path' do
      it 'serializes current_data' do
        lp_record_data = subject.current_data
        subject.lion_path_degree_code = lp_record_data
        expect(lp_record_data).to be_a_kind_of(Hash)
        expect(lp_record_data).to eq(LionPath::MockLionPathRecord.current_data)
      end
    end

    context '#etd_role' do
      it 'finds or creates a committee member role' do
        expect(described_class.etd_role('Committee Member')).to eq(CommitteeRole.where(name: 'Committee Member').first.id)
        expect(CommitteeRole.where(name: 'a nonexistant role')).to eq([])
        described_class.etd_role('a nonexistant role')
        expect(CommitteeRole.where(name: 'a nonexistant role')).not_to be_empty
      end
    end

    context 'retrieve' do
      it "returns the author's record from Lion Path" do
        access_id = LionPath::MockLionPathRecord::MOCK_LP_AUTHOR_RECORD[LionPath::LpKeys::RESPONSE][LionPath::LpKeys::ACCESS_ID]
        psu_id = LionPath::MockLionPathRecord::MOCK_LP_AUTHOR_RECORD[LionPath::LpKeys::RESPONSE][LionPath::LpKeys::EMPLOYEE_ID]
        record_data = described_class.new.retrieve_lion_path_record(psu_id, access_id)
        ## record_data == LionPath::MockLionPathRecord::MOCK_LP_AUTHOR_RECORD[:PE_ETD_COMM_RSP][:PE_ETD_PLAN_COMM]
        expect(record_data[LionPath::LpKeys::EMPLOYEE_ID]).to eq(psu_id)
        expect(record_data[LionPath::LpKeys::ACCESS_ID]).to eq(access_id)
      end
    end

    context '#records_match?' do
      it "returns false when there's a mis-match between login ids" do
        expect(described_class).not_to be_records_match('999999999', 'zzz123', LionPath::MockLionPathRecord::MOCK_LP_AUTHOR_RECORD[LionPath::LpKeys::RESPONSE])
      end
      it "returns false when there's a mis-match between psu_idn numbers" do
        expect(described_class).not_to be_records_match('88888888', 'zzz123', LionPath::MockLionPathRecord::MOCK_LP_AUTHOR_RECORD[LionPath::LpKeys::RESPONSE])
      end
      it "returns false if the record data is empty" do
        expect(described_class).not_to be_records_match('999999999', 'zzz123', nil)
      end
    end

    context 'initialize lion path degree code to transition submission records created without lionpath' do
      it 'returns the lion path degree code when it is missing' do
        degree =  Degree.create(name: 'PHD', is_active: true, degree_type_id: DegreeType.default.id, description: 'phd')
        another_degree = Degree.new(name: 'MS', is_active: false, degree_type_id: DegreeType.default.id, description: 'ms')
        last_degree = Degree.new(name: 'DEGREE', is_active: true, degree_type_id: DegreeType.default.id, description: 'degree')

        submission.degree_id = degree.id
        allow(InboundLionPathRecord).to receive(:active?).and_return(true)
        lp_degree_code = described_class.new.initialize_lion_path_degree_code(submission)
        expect(lp_degree_code.last(3)).to eq('PHD')
      end

      it "returns empty string if the author's lion path record is missing" do
        allow(InboundLionPathRecord).to receive(:active?).and_return(true)
        submission.author.inbound_lion_path_record = nil
        lp_degree_code = described_class.new.initialize_lion_path_degree_code(submission)
        expect(lp_degree_code).to be_empty
      end
    end

    context 'logs error' do
      error_response = LionPath::MockLionPathRecord.error_response
      error_msg = LionPath::LionPathError.new(LionPath::MockLionPathRecord.error_response, 'xxb13').error_msg
      before { allow_any_instance_of(LionPathConnection).to receive(:retrieve_student_information).and_return(error_response) }

      it 'writes an error' do
        expect(Rails.logger).to receive(:info).with(error_response)
        expect(Rails.logger).to receive(:info).with(error_msg)
        record = described_class.new.retrieve_lion_path_record('999999999', 'xxb13')
        expect(record).to be_nil
      end
    end

    it 'transitions a standard submission record to be populated with lion path information' do
      degree = Degree.create(name: 'PHD', is_active: true, degree_type_id: DegreeType.default.id, description: 'phd')
      another_degree = Degree.new(name: 'MS', is_active: false, degree_type_id: DegreeType.default.id, description: 'ms')

      author = FactoryBot.create(:author)
      author.inbound_lion_path_record = FactoryBot.create(:inbound_lion_path_record, author: author)
      submission1 = FactoryBot.create :submission, :collecting_format_review_files, author: author, lion_path_degree_code: nil, degree_id: degree.id
      submission1.save
      roles = CommitteeRole.all
      (0..1).each do |i|
        submission1.committee_members << CommitteeMember.create(name: "Name_#{i}", email: "name_#{i}_@example.com", is_required: false, committee_role_id: roles[i].id, submission_id: submission1.id)
      end
      # submission1.author.inbound_lion_path_record.lion_path_degree_code = LionPath::MockLionPathRecord.first_degree_code
      submission1.save
      allow_any_instance_of(Submission).to receive(:using_lionpath?).and_return(true)
      allow(InboundLionPathRecord).to receive(:active?).and_return(true)
      described_class.transition_to_lionpath([submission1])
      submission1.reload
      expect(submission1.lion_path_degree_code).not_to be_nil
      expect(submission1.committee_members[0].name).not_to eq('Name_0')
    end
    context '#active?' do
      it 'returns value from lion_path.yml' do
        expect(described_class.active?).to eql(Rails.application.config_for(:lion_path)[current_partner.id.to_s][:lion_path_inbound])
      end
    end

    context '#lp_valid degrees' do
      it 'returns list of valid degrees' do
        degree = FactoryBot.create :degree, name: 'PHD', is_active: true, degree_type: DegreeType.default
        another_degree = FactoryBot.create :degree, name: 'MS', is_active: false, degree_type: DegreeType.default
        last_degree = FactoryBot.create :degree, name: 'DEGREE', is_active: true, degree_type: DegreeType.default
        expect(described_class.lp_valid_degrees).to eql(['PHD', 'DEGREE'])
      end
    end
  end
end

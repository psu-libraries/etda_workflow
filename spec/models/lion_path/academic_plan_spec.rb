require 'model_spec_helper'

RSpec.describe LionPath::AcademicPlan, type: :model do
  author = FactoryBot.create :author
  inbound_record = FactoryBot.create :inbound_lion_path_record, author: author
  submission = FactoryBot.create :submission, author: author
  code = LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN].first[LionPath::LpKeys::DEGREE_CODE]

  academic_plan = described_class.new(author.inbound_lion_path_record, code, submission)

  context 'it has an array of academic plan choices' do
    it "describes a student's academic plan" do
      academic_plan = described_class.new(author.inbound_lion_path_record, code, submission)
      # expect(academic_plan.defense_date).to be_a_kind_of(Date)
      expect(academic_plan.committee).to be_a_kind_of(Array)
      expect(academic_plan.committee_member(0)).to be_a_kind_of(Hash)
      expect(academic_plan.selected).to be_a_kind_of(Hash)
      expect(academic_plan.degrees_display_collection).to be_a_kind_of(Array)
    end
  end

  if current_partner.graduate?

    context '#plan_Information_collection' do
      it 'returns a collection of programs and creates a program record if the program does not exist' do
        Degree.create(name: 'MS', degree_type: DegreeType.first, description: 'none')
        Degree.create(name: 'PHD', degree_type: DegreeType.first, description: 'another')
        Degree.create(name: 'MA', degree_type: DegreeType.first, description: 'last')

        (0..1).each do |i|
          expect(Program.find_by(name: LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN][i][LionPath::LpKeys::DEGREE_DESC])).to be_nil
        end
        academic_plan.plan_information_collection
        (0..1).each do |i|
          expect(Program.find_by(name: LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN][i][LionPath::LpKeys::DEGREE_DESC])).not_to be_nil
        end
      end
    end

    context '#degrees_display_collection' do
      it 'returns a collection for degree dropdown' do
       expect(academic_plan.degrees_display_collection[0]).to eq([LionPath::MockLionPathRecord.first_degree_code + ' - ' + LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN].first[LionPath::LpKeys::DEGREE_DESC], LionPath::MockLionPathRecord.first_degree_code])
      end
    end

    context '#committee' do
      it 'returns the selected committee' do
        expect(academic_plan.committee).to be_a_kind_of(Array)
        expect(academic_plan.committee.count).to eql(LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN][0][LionPath::LpKeys::COMMITTEE].count)
      end
    end

    context '#committee_member' do
      it 'returns committee information' do
        expect(academic_plan.committee_member(1)).to eq(LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN][0][LionPath::LpKeys::COMMITTEE][1])
      end
    end

    context '#committee_members' do
      it 'builds committee members array to save to the database' do
        submission = FactoryBot.create :submission, :waiting_for_format_review_response
        submission.committee_members = []
        expect(submission.committee_members.count).to be(0)
        full_committee = academic_plan.committee_members
        expect(full_committee).to be_a_kind_of(Array)
        expect(full_committee.first).to be_a_kind_of(Hash)
        expect(full_committee.count).not_to eql(0)
      end
    end

    context '#full_name' do
      it "returns a committee member's full name" do
        expect(academic_plan.full_name(academic_plan.committee_member(0))).to eql("#{academic_plan.committee_member(0)[LionPath::LpKeys::FIRST_NAME]} #{academic_plan.committee_member(0)[LionPath::LpKeys::LAST_NAME]}")
      end
    end

    context '#defense_date' do
      it 'returns the selected defense date' do
        defense_date = Date.strptime(LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN][0][LionPath::LpKeys::DEFENSE_DATE], LionPath::LpFormats::DEFENSE_DATE_FORMAT)
        expect(academic_plan.defense_date).to eq(defense_date)
      end
    end
  end
end

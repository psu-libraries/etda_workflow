require 'model_spec_helper'

RSpec.describe Lionpath::LionpathSubmissionGenerator, type: :model do
  let!(:admin_author) { FactoryBot.create :author, access_id: 'adminflow' }

  context 'when degree_type param is a masters thesis' do
    it 'generates a masters thesis' do
      FactoryBot.create :degree, degree_type: DegreeType.second
      FactoryBot.create :program
      expect{ described_class.new('adminflow', DegreeType.second).create_submission }.to change(Submission, :count).by 1
      expect(admin_author.submissions.first.degree_type.slug).to eq 'master_thesis'
      expect(admin_author.submissions.first.lionpath_updated_at).to be_truthy
      expect(admin_author.submissions.first.committee_members.count).to eq 1
      expect(admin_author.submissions.first.committee_members.first.committee_role.is_program_head).to eq true
      expect(admin_author.submissions.first.committee_members.first.name).to match /Fake Person/
      expect(admin_author.submissions.first.committee_members.first.email).to match /abc.*@psu.edu/
      expect(admin_author.submissions.first.committee_members.first.access_id).to match /abc.*/
      expect(admin_author.submissions.first.committee_members.first.lionpath_updated_at).to be_truthy
    end
  end

  context 'when degree_type param is a dissertation' do
    it 'generates a dissertation' do
      FactoryBot.create :degree, degree_type: DegreeType.default
      FactoryBot.create :program
      FactoryBot.create :committee_role, degree_type: DegreeType.default, code: 'XYZ'
      expect{ described_class.new('adminflow', DegreeType.default).create_submission }.to change(Submission, :count).by 1
      expect(admin_author.submissions.first.degree_type.slug).to eq 'dissertation'
      expect(admin_author.submissions.first.lionpath_updated_at).to be_truthy
      expect(admin_author.submissions.first.committee_members.count).to eq 6
      expect(admin_author.submissions.first.committee_members.first.name).to match /Fake Person/
      expect(admin_author.submissions.first.committee_members.first.email).to match /abc.*@psu.edu/
      expect(admin_author.submissions.first.committee_members.first.access_id).to match /abc.*/
      expect(admin_author.submissions.first.committee_members.first.lionpath_updated_at).to be_truthy
      expect(admin_author.submissions.first.committee_members.first.committee_role.is_program_head).to eq true
      expect(admin_author.submissions.first.lionpath_updated_at).to be_truthy
      expect(admin_author.submissions.first.committee_members.second.committee_role.is_program_head).to eq false
      expect(admin_author.submissions.first.committee_members.second.committee_role.code).to eq 'XYZ'
      expect(admin_author.submissions.first.committee_members.second.lionpath_updated_at).to be_truthy
    end
  end
end

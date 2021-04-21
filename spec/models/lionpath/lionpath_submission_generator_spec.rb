require 'model_spec_helper'

RSpec.describe Lionpath::LionpathSubmissionGenerator, type: :model do
  let!(:admin_author) { FactoryBot.create :author, access_id: 'adminflow' }

  it 'generates a masters thesis' do
    FactoryBot.create :degree, degree_type: DegreeType.second
    FactoryBot.create :program
    expect{ described_class.new('adminflow').create_master_thesis }.to change(Submission, :count).by 1
    expect(admin_author.submissions.first.lionpath_updated_at).to be_truthy
    expect(admin_author.submissions.first.committee_members.count).to eq 1
    expect(admin_author.submissions.first.committee_members.first.name).to match /Fake Person/
    expect(admin_author.submissions.first.committee_members.first.email).to match /abc.*@psu.edu/
    expect(admin_author.submissions.first.committee_members.first.access_id).to match /abc.*/
    expect(admin_author.submissions.first.committee_members.first.lionpath_updated_at).to be_truthy
  end

  it 'generates a dissertation' do

  end
end

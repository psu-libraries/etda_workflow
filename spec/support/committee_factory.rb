module CommitteeFactory
  def create_committee(submission)
    submission.required_committee_roles.each do |role|
      submission.committee_members << FactoryBot.create(:committee_member, committee_role: role)
    end
  end
end

RSpec.configure do |config|
  config.include CommitteeFactory
end

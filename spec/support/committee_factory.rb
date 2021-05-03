module CommitteeFactory
  def create_committee(submission)
    if submission.degree_type.slug == 'dissertation'
      5.times do
        role = CommitteeRole.where('committee_roles.name != "Program Head/Chair" AND committee_roles.degree_type_id = ?',
                                   submission.degree_type.id).sample
        submission.committee_members << FactoryBot.create(:committee_member, committee_role: role)
      end
    else
      submission.required_committee_roles.each do |role|
        submission.committee_members << FactoryBot.create(:committee_member, committee_role: role)
      end
    end
  end
end

RSpec.configure do |config|
  config.include CommitteeFactory
end

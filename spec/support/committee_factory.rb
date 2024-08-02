module CommitteeFactory
  def create_committee(submission)
    if submission.degree_type.slug == 'dissertation'
      CommitteeRole.where('committee_roles.is_program_head = 0 AND committee_roles.degree_type_id = ?',
                          submission.degree_type.id).find_each do |role|
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

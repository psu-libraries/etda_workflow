class Lionpath::LionpathCommitteeFactory
  def initialize(row, submission)
    @row = row
    @submission = submission
    @sub_roles = CommitteeRole.where(degree_type: submission.degree.degree_type)
  end

  def create_member
    case row['Role']
    when 'CHMJ', 'H', 'C', 'CIMN', 'CIRA', 'CIMJ'
      variables = assign_variables('Committee Chair/Co-Chair', true)
    when 'CMMJ', 'CMMN', 'G', 'MN', 'M', 'N'
      variables = assign_variables('Committee Member', true)
    when 'MAMJ', 'MARA', 'MASP', 'MAGS', 'MAMN', 'CMRA'
      variables = assign_variables('Committee Member', false)
    when 'UF', 'GF', 'GFU', 'GU', 'F'
      variables = assign_variables('Outside Member', true)
    when 'UFN', 'UN', 'U', 'UFN', 'NF'
      variables = assign_variables('Outside Member', false)
    when 'S'
      variables = assign_variables('Special Member', false)
    when 'CISP'
      CommitteeMember.create(assign_variables('Committee Chair/Co-Chair', true).merge(defaults))
      CommitteeMember.create(assign_variables('Special Member', false).merge(defaults))
      return
    when 'HD', 'CD'
      CommitteeMember.create(assign_variables('Committee Chair/Co-Chair', true).merge(defaults))
      CommitteeMember.create(assign_variables('Dissertation Advisor/Co-Advisor', true).merge(defaults))
      return
    when 'HF', 'HU'
      CommitteeMember.create(assign_variables('Committee Chair/Co-Chair', true).merge(defaults))
      CommitteeMember.create(assign_variables('Outside Member', true).merge(defaults))
      return
    when 'HM'
      CommitteeMember.create(assign_variables('Committee Chair/Co-Chair', true).merge(defaults))
      CommitteeMember.create(assign_variables('Committee Member', true).merge(defaults))
      return
    when 'CMSP'
      CommitteeMember.create(assign_variables('Committee Member', true).merge(defaults))
      CommitteeMember.create(assign_variables('Special Member', false).merge(defaults))
      return
    when 'MD'
      CommitteeMember.create(assign_variables('Committee Member', true).merge(defaults))
      CommitteeMember.create(assign_variables('Dissertation Advisor/Co-Advisor', false).merge(defaults))
      return
    when 'SR'
      CommitteeMember.create(assign_variables('Special Member', false).merge(defaults))
      CommitteeMember.create(assign_variables('Dissertation Advisor/Co-Advisor', false).merge(defaults))
      return
    end
    CommitteeMember.create variables.merge(defaults)
  end

  private

  def assign_variables(committee_role, is_required)
    {
      committee_role: get_committee_role(committee_role),
      is_required: is_required
    }
  end

  def get_committee_role(role_name)
    sub_roles.find { |r| r.name == role_name }
  end

  def defaults
    {
      name: "#{row['First Name']} #{row['Last Name']}",
      email: "#{row['Access ID'].downcase}@psu.edu",
      access_id: row['Access ID'].downcase.to_s,
      submission: submission,
      lionpath_uploaded_at: DateTime.now,
      is_voting: true
    }
  end

  attr_accessor :submission, :row
  attr_reader :sub_roles
end

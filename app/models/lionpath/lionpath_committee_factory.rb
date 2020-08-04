class Lionpath::LionpathCommitteeFactory
  def initialize(row, submission)
    @row = row
    @submission = submission
    @sub_roles = CommitteeRole.where(degree_type: submission.degree.degree_type)
  end

  def create_member
    case row['Role']
    when 'CHMJ', 'H', 'C', 'CIMN', 'CIRA', 'CIMJ'
      variables = {
        committee_role: get_committee_role('Committee Chair/Co-Chair'),
        is_required: true,
        is_voting: true
      }
    when 'CISP'
      CommitteeMember.create({ committee_role: get_committee_role('Committee Chair/Co-Chair'),
                               is_required: true,
                               is_voting: true }.merge(defaults))
      CommitteeMember.create({ committee_role: get_committee_role('Special Member'),
                               is_required: false,
                               is_voting: true }.merge(defaults))
      return
    when 'HD'
      CommitteeMember.create({ committee_role: get_committee_role('Committee Chair/Co-Chair'),
                               is_required: true,
                               is_voting: true }.merge(defaults))
      CommitteeMember.create({ committee_role: get_committee_role('Dissertation Advisor/Co-Advisor'),
                               is_required: true,
                               is_voting: true }.merge(defaults))
      return
    when 'HF', 'HU'
      CommitteeMember.create({ committee_role: get_committee_role('Committee Chair/Co-Chair'),
                               is_required: true,
                               is_voting: true }.merge(defaults))
      CommitteeMember.create({ committee_role: get_committee_role('Outside Member'),
                               is_required: true,
                               is_voting: true }.merge(defaults))
      return
    when 'HM'
      CommitteeMember.create({ committee_role: get_committee_role('Committee Chair/Co-Chair'),
                               is_required: true,
                               is_voting: true }.merge(defaults))
      CommitteeMember.create({ committee_role: get_committee_role('Committee Member'),
                               is_required: true,
                               is_voting: true }.merge(defaults))
      return
    when 'CMMJ', 'CMMN', 'G', 'MN', 'M', 'N'
      variables = {
        committee_role: get_committee_role('Committee Member'),
        is_required: true,
        is_voting: true
      }
    when 'UF', 'GF', 'GFU', 'GU', 'F'
      variables = {
        committee_role: get_committee_role('Outside Member'),
        is_required: true,
        is_voting: true
      }
    when 'UFN', 'UN', 'U', 'UFN', 'NF'
      variables = {
        committee_role: get_committee_role('Outside Member'),
        is_required: false,
        is_voting: true
      }
    when 'MAMJ', 'MARA', 'MASP', 'MAGS', 'MAMN'
      variables = {
        committee_role: get_committee_role('Committee Member'),
        is_required: false,
        is_voting: true
      }
    when 'CMRA'
      variables = {
        committee_role: get_committee_role('Committee Member'),
        is_required: false,
        is_voting: true
      }
    when 'CMSP'
      CommitteeMember.create({ committee_role: get_committee_role('Committee Member'),
                               is_required: true,
                               is_voting: true }.merge(defaults))
      CommitteeMember.create({ committee_role: get_committee_role('Special Member'),
                               is_required: false,
                               is_voting: true }.merge(defaults))
      return
    when 'MD'
      CommitteeMember.create({ committee_role: get_committee_role('Committee Member'),
                               is_required: true,
                               is_voting: true }.merge(defaults))
      CommitteeMember.create({ committee_role: get_committee_role('Dissertation Advisor/Co-Advisor'),
                               is_required: false,
                               is_voting: true }.merge(defaults))
      return
    when 'SR'
      CommitteeMember.create({ committee_role: get_committee_role('Special Member'),
                               is_required: false,
                               is_voting: true }.merge(defaults))
      CommitteeMember.create({ committee_role: get_committee_role('Dissertation Advisor/Co-Advisor'),
                               is_required: false,
                               is_voting: true }.merge(defaults))
      return
    when 'S'
      variables = {
        committee_role: get_committee_role('Special Member'),
        is_required: false,
        is_voting: true
      }
    end
    CommitteeMember.create defaults.merge(variables)
  end

  private

  def get_committee_role(role_name)
    sub_roles.select { |r| r.name == role_name }
  end

  def defaults
    {
      name: "#{row['First Name']} #{row['Last Name']}",
      email: "#{row['Access ID'].downcase}.psu.edu",
      access_id: row['Access ID'].downcase.to_s,
      submission: submission
    }
  end

  attr_accessor :submission, :row
  attr_reader :sub_roles
end

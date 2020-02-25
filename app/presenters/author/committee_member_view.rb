class Author::CommitteeMemberView
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def required?
    model.is_required
  end

  def head_of_program?
    role == 'Program Head/Chair'
  end

  def name_label
    return "Name" unless required?

    "#{role} Name"
  end

  def email_label
    return "Email" unless required?

    "#{role} Email"
  end

  def role
    model.committee_role.present? ? model.committee_role.name.gsub(/\/Co-(.*)/, '') : nil
  end

  def author_possible_roles
    model.submission.degree_type.try(&:committee_roles).where.not(name: 'Program Head/Chair').order('name asc') || []
  end

  def admin_possible_roles
    model.submission.degree_type.try(&:committee_roles).order('name asc') || []
  end

  def committee_members_tooltip_text
    if current_partner.graduate? && model.submission.degree_type.name == "Master Thesis"
      "<p><strong>Thesis Advisor</strong> - #{I18n.t('graduate.committee.list.thesis.thesis_advisor')}</p>
       <p><strong>Committee Member</strong> - #{I18n.t('graduate.committee.list.thesis.committee_member')}</p>"
    elsif current_partner.graduate? && model.submission.degree_type.name == "Dissertation"
      "<p><strong>Dissertation Advisor</strong> - #{I18n.t('graduate.committee.list.dissertation.dissertation_advisor')}</p>
       <p><strong>Committee Chair</strong> - #{I18n.t('graduate.committee.list.dissertation.committee_chair')}</p>
       <p><strong>Committee Member</strong> - #{I18n.t('graduate.committee.list.dissertation.committee_member')}</p>
       <p><strong>Outside Member</strong> - #{I18n.t('graduate.committee.list.dissertation.outside_member')}</p>
       <p><strong>Special Signatory</strong> - #{I18n.t('graduate.committee.list.dissertation.special_signatory')}</p>
       <p><strong>Special Member</strong> - #{I18n.t('graduate.committee.list.dissertation.special_member')}</p>
       <p><strong>Program Head/Chair</strong> - #{I18n.t('graduate.committee.list.dissertation.program_head')}</p>"
    elsif current_partner.honors?
      "<p><strong>Thesis Supervisor</strong> - #{I18n.t('honors.committee.list.thesis.thesis_supervisor')}</p>
       <p><strong>Thesis Honors Adviser</strong> - #{I18n.t('honors.committee.list.thesis.thesis_honors_adviser')}</p>
       <p><strong>Faculty Reader</strong> - #{I18n.t('honors.committee.list.thesis.faculty_reader')}</p>"
    elsif current_partner.milsch?
      "<p><strong>Thesis Supervisor</strong> - #{I18n.t('milsch.committee.list.thesis.thesis_supervisor')}</p>
       <p><strong>Advisor</strong> - #{I18n.t('milsch.committee.list.thesis.advisor')}</p>
       <p><strong>Honors Advisor</strong> - #{I18n.t('milsch.committee.list.thesis.honors_advisor')}</p>"
    end
  end
end

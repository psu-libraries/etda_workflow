class Author::CommitteeMemberView
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def required?
    model.is_required
  end

  def head_of_program?
    role == 'Head/Chair of Graduate Program'
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
    model.committee_role.present? ? model.committee_role.name : nil
  end

  def possible_roles
    model.submission.degree_type.try(&:committee_roles).order('name asc') || []
  end

  def possible_additional_roles
    model.submission.degree_type.try(&:committee_roles).where.not(name: 'Head/Chair of Graduate Program').order('name asc') || []
  end

  def committee_members_tooltip_text
    if current_partner.graduate? && model.submission.degree_type.name == "Master Thesis"
      "<p><strong>Thesis Advisor</strong> - The professor responsible for supervising a MS student through the writing of their thesis.</p><p><strong>Committee Member</strong> - A professor who serves a variety of roles in the student’s thesis and is a member of the committee.</p>"
    elsif current_partner.graduate? && model.submission.degree_type.name == "Dissertation"
      "<p><strong>Dissertation Advisor</strong> - Graduate Faculty member(s) principally responsible for day-to-day guidance of the student’s dissertation research and academic/professional development.</p><p><strong>Committee Chair</strong> - The Committee Chair must be a member of the Graduate Faculty and the student’s major Graduate Program.  The Committee Chair is responsible for arranging and conducting all committee meetings and ensuring that all requirements relative to the doctoral degree are met.</p><p><strong>Committee Member</strong> - A member of the Graduate Faculty who is in position to contribute to the student’s education.</p><p><strong>Outside Member</strong> - The Outside Member must have a disciplinary expertise different from the student’s primary field of study.</p><p><strong>Special Signatory</strong> - A person outside the university with expertise in a particular field who is unable to attend the final defense.</p><p><strong>Special Member</strong> - A member of the student’s Ph.D. Committee who is not a member of the Graduate Faculty of Penn State, but whose expertise and insights would provide substantial benefit to the student’s dissertation research and the Ph.D. Committee.</p><p><strong>Program Head/Chair</strong> - Faculty member responsible for leadership in developing the department’s academic programs.</p>"
    elsif current_partner.honors?
      "<p><strong>Thesis Supervisor</strong> - A professor in the area in which the thesis is written, who the student works closely with.</p><p><strong>Thesis Honors Adviser</strong> - Faculty member who oversees the thesis work and confirms it is indeed honors work in their area of expertise.</p>"
    elsif current_partner.milsch?
      "<p><strong>Thesis Supervisor</strong> - The faculty member or researcher who is the principal investigator of the lab where the student conducted the research. The thesis supervisor also acts as a research mentor regarding the thesis project.</p><p><strong>Special Signatory</strong> - A faculty member who acts as a second reader to assess the quality of the thesis.</p>"
    end
  end
end

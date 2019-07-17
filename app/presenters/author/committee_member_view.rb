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
    model.committee_role.name
  end

  def possible_roles
    model.submission.degree_type.try(&:committee_roles).order('name asc') || []
  end

  def possible_additional_roles
    model.submission.degree_type.try(&:committee_roles).where.not(name: 'Program Head/Chair').order('name asc') || []
  end
end

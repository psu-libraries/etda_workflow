class Author::CommitteeMemberView
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def required?
    model.is_required
  end

  def outside_member?
    model.committee_role.name == 'Outside Member'
  end

  def name_label
    return "Name" unless required?

    "#{role} Name"
  end

  def email_label
    return "Email" unless required?

    "#{role} Email"
  end

  def access_id_label
    return "Access ID" unless required?

    "#{role} Access ID"
  end

  def role
    model.committee_role.name
  end

  def possible_roles
    model.submission.degree_type.try(&:committee_roles).order('name asc') || []
  end
end

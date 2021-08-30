class Author::CommitteeMemberView
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def required?
    model.is_required
  end

  def head_of_program?
    model.is_program_head
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
    model.submission.degree_type.try(&:committee_roles).where(is_program_head: false).order('name asc') || []
  end

  def admin_possible_roles
    model.submission.degree_type.try(&:committee_roles).order('name asc') || []
  end

  def dissertation_possible_roles
    model.submission.degree_type.try(&:committee_roles).where(name: 'Special Signatory', degree_type_id: model.submission.degree_type.id)
  end

  def sset_possible_roles
    model.submission.degree_type.try(&:committee_roles).where(name: 'Paper Reader', degree_type_id: model.submission.degree.degree_type.id)
  end

  def committee_members_tooltip_text
    output = ''
    I18n.t("#{current_partner.id}.committee.list.#{model.submission.degree_type.slug}.members").each do |_k, v|
      output << "<p><strong>#{v[:name]}</strong> - #{v[:description]}</p>"
    end
    output.html_safe
  end

  def program_chair_collection
    collection = []
    model.submission.collect_program_chairs.each do |pc|
      collection << ["#{pc.first_name} #{pc.last_name} (#{pc.role})",
                     "#{pc.first_name} #{pc.last_name}",
                     { member_email: pc.email.to_s, committee_role_id: committee_role_id(pc.role) }]
    end
    collection
  end

  private

    def committee_role_id(role)
      if role == 'Professor in Charge'
        model.submission.degree_type.committee_roles.where(name: 'Professor in Charge/Director of Graduate Studies').first.id
      else
        model.submission.degree_type.committee_roles.where(name: 'Program Head/Chair').first.id
      end
    end
end

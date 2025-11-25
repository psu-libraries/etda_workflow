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
    members = I18n.t("#{current_partner.id}.committee.list.#{model.submission.degree_type.slug}.members")
    if members.is_a? Hash
      members.each_value do |val|
        output << "<p><strong>#{val[:name]}</strong> - #{val[:description]}</p>"
      end
    end
    output.html_safe
  end

  def committee_members_tooltip_text_no_html
    committee_members_tooltip_text.gsub('<p><strong>', '').gsub('</strong> -','').gsub('</p>','')
  end

  def program_chair_collection
    ProgramChairCollectionService.new(model.submission).collection
  end
end

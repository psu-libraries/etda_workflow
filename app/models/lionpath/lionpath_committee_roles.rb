class Lionpath::LionpathCommitteeRoles
  attr_accessor :file_path

  def initialize(roles_file_path)
    @file_path = roles_file_path
  end

  def import
    csv_options = { headers: true, encoding: "ISO-8859-1:UTF-8", quote_char: '"', force_quotes: true }
    CSV.foreach(file_path, csv_options) do |row|
      cr = CommitteeRole.find_by(code: row['Type'])
      if cr.present?
        cr.update(committee_role_attrs(row))
        next
      end

      CommitteeRole.create!({ code: row['Type'] }.merge(committee_role_attrs(row)))
    end
  end

  private

  def committee_role_attrs(row)
    status = (row['Status'] == 'A' ? true : false)
    {
        degree_type_id: dissertation_id,
        name: row['Description'],
        is_active: status,
        num_required: 0
    }
  end

  def dissertation_id
    DegreeType.find_by(slug: 'dissertation').id
  end
end

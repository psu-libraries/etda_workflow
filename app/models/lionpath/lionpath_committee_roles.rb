class Lionpath::LionpathCommitteeRoles
  def import(row)
    cr = CommitteeRole.find_by(code: row['Type'])
    if cr.present?
      cr.update(committee_role_attrs(row))
      return
    end
    CommitteeRole.create!({ code: row['Type'] }.merge(committee_role_attrs(row)))
  end

  private

  def committee_role_attrs(row)
    status = (row['Status'] == 'A')
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

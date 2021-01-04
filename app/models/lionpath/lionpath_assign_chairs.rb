class Lionpath::LionpathAssignChairs
  def call
    submissions.each do |sub|
      degree_type = sub.degree.degree_type
      chair_role = CommitteeRole.find_by(name: 'Program Head/Chair', degree_type: degree_type)
      sub_chair = sub.committee_members.find_by(committee_role_id: chair_role.id)
      program_chair = sub.program.program_chairs.find { |n| n.campus == sub.campus }
      next if program_chair.blank?

      if sub_chair.present?
        sub_chair.update update_chair_attrs(program_chair)
        next
      end
      chair_member = CommitteeMember.create create_chair_attrs(chair_role, program_chair)
      sub.committee_members << chair_member
      sub.save!
    rescue StandardError => e
      Rails.logger.error(error_json(e, "Assigning Chairs"))
    end
  end

  def create_chair_attrs(chair_role, program_chair)
    {
      committee_role_id: chair_role.id,
      name: "#{program_chair.first_name} #{program_chair.last_name}",
      email: program_chair.email,
      access_id: program_chair.access_id,
      is_required: true,
      is_voting: false,
      lionpath_updated_at: DateTime.now
    }
  end

  def update_chair_attrs(program_chair)
    {
      name: "#{program_chair.first_name} #{program_chair.last_name}",
      email: program_chair.email,
      access_id: program_chair.access_id,
      lionpath_updated_at: DateTime.now
    }
  end

  def submissions
    Submission.where('submissions.year > ? OR (submissions.year = ? AND submissions.semester <> ?)', 2021, 2021, 'Spring')
  end
end

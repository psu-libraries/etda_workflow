class Lionpath::LionpathSubmissionGenerator
  attr_accessor :current_remote_user, :degree_type

  def initialize(current_remote_user, degree_type)
    @current_remote_user = current_remote_user
    @degree_type = degree_type
  end

  def create_submission
    submission = Submission.create(submission_attrs)
    return unless degree_type.slug == 'dissertation'

    rand_num = rand(1..994)
    seq = 1
    5.times.each do
      com_role = CommitteeRole.where('committee_roles.degree_type_id = ? and committee_roles.code IS NOT NULL',
                                     degree_type.id).sample
      CommitteeMember.create(committee_role: com_role,
                             name: "Fake Person#{rand_num + seq}",
                             email: "abc#{rand_num + seq}@psu.edu",
                             is_required: 1,
                             access_id: "abc#{rand_num + seq}",
                             is_voting: true,
                             lionpath_updated_at: DateTime.now,
                             submission: submission)
      seq += 1
    end
  end

  private

    def submission_attrs
      degree_name = degree_type.slug == 'dissertation' ? 'PHD' : 'MS'
      {
        author: Author.find_by(access_id: current_remote_user),
        program_id: Program.joins(:program_chairs)
                           .where("programs.is_active = true AND programs.name LIKE '%#{degree_name}%' AND program_chairs.campus = 'UP'")
                           .uniq.sample.id,
        degree_id: Degree.where(name: degree_name).sample.id,
        campus: 'UP',
        year: DateTime.now.year,
        semester: Semester.current.split(" ").last,
        lionpath_updated_at: DateTime.now
      }
    end
end

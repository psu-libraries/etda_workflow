class Lionpath::LionpathSubmissionGenerator
  attr_accessor :current_remote_user, :degree_type

  def initialize(current_remote_user, degree_type)
    @current_remote_user = current_remote_user
    @degree_type = degree_type
  end

  def create_submission
    submission = Submission.create(submission_attrs)
    dept_head = dept_head_role
    generate_dep_head(submission, dept_head)
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
    {
      author: Author.find_by(access_id: current_remote_user),
      program_id: Program.pluck(:id).sample,
      degree_id: Degree.joins(:degree_type).where('degree_types.id = ?',
                                                  degree_type.id).sample.id,
      year: DateTime.now.year,
      semester: Semester.current.split(" ").last,
      lionpath_updated_at: DateTime.now
    }
  end

  def generate_dep_head(submission, dept_head_role)
    rand_num = rand(1..994)
    CommitteeMember.create(committee_role: dept_head_role,
                           name: "Fake Person#{rand_num}",
                           email: "abc#{rand_num}@psu.edu",
                           is_required: 1,
                           access_id: "abc#{rand_num}",
                           is_voting: false,
                           lionpath_updated_at: DateTime.now,
                           submission: submission)
  end

  def dept_head_role
    CommitteeRole.find_by(degree_type_id: degree_type.id, is_program_head: true)
  end
end

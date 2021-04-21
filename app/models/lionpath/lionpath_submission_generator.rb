class Lionpath::LionpathSubmissionGenerator
  attr_accessor :current_remote_user

  def initialize(current_remote_user)
    @current_remote_user =  current_remote_user
  end

  def create_master_thesis
    degree_type = DegreeType.find_by(slug: 'master_thesis')
    submission = Submission.create(author: Author.find_by(access_id: current_remote_user),
                                   program_id: Program.pluck(:id).sample,
                                   degree_id: Degree.joins(:degree_type).where('degree_types.id = ?',
                                                                               degree_type.id).sample.id,
                                   year: DateTime.now.year,
                                   semester: Semester.current.split(" ").last,
                                   lionpath_updated_at: DateTime.now)

    masters_dept_head = CommitteeRole.find_by(degree_type_id: degree_type.id, is_program_head: true)
    rand_num = rand(1..999)
    CommitteeMember.create(committee_role: masters_dept_head,
                           name: "Fake Person#{rand_num}",
                           email: "abc#{rand_num}@psu.edu",
                           is_required: 1,
                           access_id: "abc#{rand_num}",
                           is_voting: false,
                           lionpath_updated_at: DateTime.now,
                           submission: submission)
  end

  def create_dissertation

  end
end

require 'delegate'

class Author::CommitteeView < SimpleDelegator
  delegate :class, to: :__getobj__

  def initialize(committee)
    @submission = Submission.find(committee.submission_id)
  end

  def role_display(cmf)
    return 'required_member_role' if cmf.object.is_required
    'optional_member_role'
  end
end

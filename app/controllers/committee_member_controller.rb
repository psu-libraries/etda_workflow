class CommitteeMemberController < ApplicationController
  layout 'home'
  def index
    @committee_member_data = CommitteeMember
                .joins(:faculty_member)
                .joins(submission: :program)
                .select('faculty_members.department, programs.name AS program, COUNT(committee_members.submission_id) AS submissions')
                .where.not('faculty_members.department' => '')
                .group('faculty_members.department, programs.name')
                .order('faculty_members.department, COUNT(committee_members.submission_id) DESC')
                .to_json
  end
end

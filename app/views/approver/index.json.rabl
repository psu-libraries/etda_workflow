object false

node(:data) do
  @committee_members.map do |member|
    [
      "<a href=#{approver_path(member)}>#{member.submission.title}</a>",
      "#{member.submission.author.first_name} #{member.submission.author.last_name}",
      member.committee_role.name,
      (current_partner.honors? ? member.submission.final_submission_files_uploaded_at.strftime('%m/%d/%Y') : member.submission.final_submission_approved_at.strftime('%m/%d/%Y')),
      member.status.titleize,
      member.submission.status.titleize
    ]
  end
end

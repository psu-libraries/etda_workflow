object false

node(:data) do
  @committee_members.map do |member|
    review_started_on = current_partner.honors? ? member.submission.final_submission_files_uploaded_at : member.submission.final_submission_approved_at
    [
      "<a href=#{approver_path(member)}>#{member.submission.title.truncate(30)}</a>",
      "#{member.submission.author.first_name} #{member.submission.author.last_name}",
      member.committee_role.name,
      "<span>#{review_started_on ? review_started_on.strftime('%Y%m%d') : ''}</span>#{review_started_on ? review_started_on.strftime('%m/%d/%Y') : ''}",
      member.status.titleize,
      member.submission.status.titleize
    ]
  end
end

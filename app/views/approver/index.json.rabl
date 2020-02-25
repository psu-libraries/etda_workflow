object false

node(:data) do
  @committee_members.map do |member|
    [
      "<a href=#{approver_path(member)}>#{member.submission.title.truncate(30)}</a>",
      "#{member.submission.author.first_name} #{member.submission.author.last_name}",
      member.committee_role.name,
      "<span>#{member.approval_started_at ? member.approval_started_at.strftime('%Y%m%d') : ''}</span>#{member.approval_started_at ? member.approval_started_at.strftime('%m/%d/%Y') : ''}",
      (member.status ? member.status.titleize : ""),
      member.submission.status.titleize
    ]
  end
end

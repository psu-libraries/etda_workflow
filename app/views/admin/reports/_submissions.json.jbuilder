json.array! [
  submission.id,
  "<input type='checkbox' class='row-checkbox' />",
  "#{submission.author.last_name}, #{submission.author.first_name}",
  submission.author.psu_idn,
  submission.cleaned_title,
  submission.degree.name,
  submission.program ? submission.program.name : nil,
  submission.current_access_level.label,
  submission.status.titleize,
  submission.federal_funding_display,
  CommitteeMember.advisor_name(submission),
  submission.author.psu_email_address,
  submission.author.alternate_email_address,
  submission.admin_notes&.truncate(30)
]

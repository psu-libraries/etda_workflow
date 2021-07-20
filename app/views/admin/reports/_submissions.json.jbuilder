json.array! [
  submission.id,
  "<input type='checkbox' class='row-checkbox' />",
  "#{submission.author.last_name}, #{submission.author.first_name}",
  submission.author.psu_idn,
  submission.degree.name,
  submission.program ? submission.program.name : nil,
  submission.current_access_level.label,
  submission.status.titleize,
]

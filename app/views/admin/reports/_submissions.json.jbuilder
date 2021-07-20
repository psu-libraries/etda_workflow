json.array! [
  submission.id,
  "<input type='checkbox' class='row-checkbox' />",
  "#{submission.author.last_name}, #{submission.author.first_name}",
  submission.degree_type.name,
  submission.program ? submission.program.name : nil,
  submission.current_access_level.label,
  submission.status.titleize,
]

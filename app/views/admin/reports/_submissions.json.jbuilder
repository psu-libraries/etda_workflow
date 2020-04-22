json.array! [
    submission.id,
    "<input type='checkbox' class='row-checkbox' />",
    submission.semester_and_year,
    submission.cleaned_title,
    "#{submission.author.last_name}, #{submission.author.first_name}",
    submission.degree_type.name,
    submission.current_access_level.label,
    submission.status.titleize,
    invention_disclosure_number(submission)
]
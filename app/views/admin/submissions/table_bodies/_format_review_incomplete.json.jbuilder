json.array! [
  submission.id,
  "<input type='checkbox' class='row-checkbox' />",
  link_to_if(submission.admin_can_edit?, submission.table_title, admin_edit_submission_path(submission)),
  submission.author.last_name,
  submission.author.first_name,
  submission.semester_and_year.presence || 'Date unknown', submission.creation_date, submission.indicator_labels + submission.most_relevant_file_links.join(' ').html_safe
]

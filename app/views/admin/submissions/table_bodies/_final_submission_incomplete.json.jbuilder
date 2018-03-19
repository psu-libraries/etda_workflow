json.array! [
  submission.id,
  "<input type='checkbox' class='row-checkbox' />",
  link_to_if(submission.admin_can_edit?, submission.author.last_name, admin_edit_submission_path(submission)),
  link_to_if(submission.admin_can_edit?, submission.author.first_name, admin_edit_submission_path(submission)),
  submission.semester_and_year.presence || 'Date unknown', submission.admin_notes, submission.creation_date, submission.indicator_labels + submission.most_relevant_file_links.join(' ').html_safe
]

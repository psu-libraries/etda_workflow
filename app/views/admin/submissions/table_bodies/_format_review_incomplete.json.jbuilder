json.array! [
  submission_view.id,
  "<input type='checkbox' class='row-checkbox' />",
  link_to_if(submission_view.admin_can_edit?, submission_view.table_title, admin_edit_submission_path(submission_view)),
  submission_view.author.last_name,
  submission_view.author.first_name,
  submission_view.semester_and_year.presence || 'Date unknown', submission_view.creation_date, submission_view.indicator_labels + submission_view.most_relevant_file_links.join(' ').html_safe
]

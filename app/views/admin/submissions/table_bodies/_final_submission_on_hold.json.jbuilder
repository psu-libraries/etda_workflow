json.array! [
  submission_view.id,
  "<input type='checkbox' class='row-checkbox' />",
  link_to_if(submission_view.admin_can_edit?, submission_view.title.presence || '[Title not available]', admin_edit_submission_path(submission_view)),
  submission_view.author.last_name,
  submission_view.author.first_name,
  "#{AccessLevel.partner_access_levels['access_level'][submission_view.access_level.to_s]} <br/>" + invention_disclosure_number(submission_view).to_s,
  submission_view.final_submission_files_uploaded_date,
  submission_view.semester_and_year.presence || 'Date unknown',
  submission_view.most_relevant_file_links.join(' ')
]

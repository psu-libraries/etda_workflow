json.array! [
  submission_view.id,
  "<input type='checkbox' class='row-checkbox' />",
  link_to_if(submission_view.admin_can_edit?, submission_view.title.presence.truncate(30) || '[Title not available]', admin_edit_submission_path(submission_view)),
  submission_view.author.last_name,
  submission_view.author.first_name,
  submission_view.semester_and_year.presence || 'Date unknown',
  submission_view.final_submission_files_uploaded_date,
  "#{AccessLevel.partner_access_levels['access_level'][submission_view.access_level.to_s]} <br/>" + (invention_disclosure_number(submission_view) || '').to_s,
  submission_view.admin_notes,
  submission_view.most_relevant_file_links.join(' ')
]

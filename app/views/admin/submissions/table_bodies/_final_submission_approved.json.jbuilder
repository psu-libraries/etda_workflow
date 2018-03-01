json.array! [
  submission.id,
  "<input type='checkbox' class='row-checkbox' />",
  link_to_if(submission.admin_can_edit?, submission.title.presence || '[Title not available]', admin_edit_submission_path(submission)),
  submission.author.last_name,
  submission.author.first_name,
  "#{AccessLevel.partner_access_levels['access_level'][submission.access_level.to_s]} <br/>" + invention_disclosure_number(submission).to_s,
  submission.final_submission_files_uploaded_date,
  submission.semester_and_year.present? ? submission.semester_and_year : 'Date unknown',
  submission.most_relevant_file_links.join(' ')
]

json.array! [
  submission.id,
  "<input type='checkbox' class='row-checkbox' />",
  link_to_if(submission.admin_can_edit?, submission.author.last_name, admin_edit_submission_path(submission)),
  link_to_if(submission.admin_can_edit?, submission.author.first_name, admin_edit_submission_path(submission)),
  submission.semester_and_year.presence || 'Date unknown',
  submission.format_review_files_uploaded_date,
  submission.most_relevant_file_links.join(' '),
  if current_partner.graduate?
    submission.is_printed? ? 'Yes' : 'No '
  end,
  if current_partner.graduate?
    link_to(' Print Page', admin_submission_print_signatory_page_path(submission), popup: 'true', class: 'btn btn-info')
  end
]

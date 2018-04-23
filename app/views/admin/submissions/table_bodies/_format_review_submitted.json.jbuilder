json.array! [
  submission_view.id,
  "<input type='checkbox' class='row-checkbox' />",
  link_to_if(submission_view.admin_can_edit?, submission_view.author.last_name, admin_edit_submission_path(submission_view.id)),
  link_to_if(submission_view.admin_can_edit?, submission_view.author.first_name, admin_edit_submission_path(submission_view.id)),
  submission_view.semester_and_year.presence || 'Date unknown',
  submission_view.format_review_files_uploaded_date,
  submission_view.most_relevant_file_links.join(' '),
  if current_partner.graduate?
    submission_view.is_printed? ? 'Yes' : 'No '
  end,
  if current_partner.graduate?
    link_to(' Print Page', admin_submission_print_signatory_page_path(submission_view.id), popup: 'true', class: 'btn btn-info')
  end
]

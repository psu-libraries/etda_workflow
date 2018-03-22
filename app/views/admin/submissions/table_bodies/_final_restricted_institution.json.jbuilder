json.array! [
  submission.id,
  "<input type='checkbox' class='row-checkbox' />",
  submission.ok_to_release?,
  link_to_if(submission.admin_can_edit?, submission.title.presence || '[Title not available]', admin_edit_submission_path(submission)),
  submission.author.last_name,
  submission.author.first_name,
  "<span class='label release-label #{submission.ok_to_release? ? 'label-primary' : 'label-none'}'>#{submission.released_for_publication_date}</span>",
  submission.semester_and_year.presence || 'Date unknown',
  submission.most_relevant_file_links.join(' ') + "<br />#{invention_disclosure_number(submission)}"
]

json.array! [
  "<a href=#{edit_admin_author_path(author_emails[:id])}>#{author_emails[:last_name]}</a>",
  author_emails[:first_name],
  author_emails[:year] || '',
  author_emails[:alternate_email_address],
  author_emails[:opt_out_user_set],
  author_emails[:confidential_alert_icon]
]

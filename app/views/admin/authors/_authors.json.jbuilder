json.array! [
  "<a href=#{edit_admin_author_path(author)}>#{author.access_id}</a>",
  author.last_name,
  author.first_name,
  author.alternate_email_address,
  author.psu_email_address,
  confidential_tag_helper(author)
]

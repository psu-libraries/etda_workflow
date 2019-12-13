object false

node(:data) do
  table = @authors.map do |author|
    row = [
      author.id,
      "<input type='checkbox' class='row-checkbox' />",
      "<a href=#{edit_admin_author_path(author)}>#{author.access_id}</a>",
      author.last_name,
      author.first_name,
      author.psu_email_address,
      author.alternate_email_address,
      author.psu_idn,
      author.confidential_hold_set_at
    ]
  end
end

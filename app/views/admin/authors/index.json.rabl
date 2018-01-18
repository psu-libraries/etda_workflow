object false

node(:data) do
  table = @authors.map do |author|
    row = [
      "<a href=#{edit_admin_author_path(author)}>#{author.access_id}</a>",
      author.last_name,
      author.first_name,
      author.alternate_email_address,
      author.psu_email_address
    ]
  end
end

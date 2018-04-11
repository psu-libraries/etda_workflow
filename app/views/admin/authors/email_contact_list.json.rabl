object false

node(:data) do
  @authors = Admin::AuthorOptOutView.new.author_email_list
  table = @authors.map do |author|
    row = [
      "<a href=#{edit_admin_author_path(author[:id])}>#{author[:last_name]}</a>",
      author[:first_name],
      author[:year] || '',
      author[:alternate_email_address],
      author[:opt_out_email],
      author[:opt_out_user_set]
    ]
  end
end

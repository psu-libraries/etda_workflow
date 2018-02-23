object false

node(:data) do
  table = @submissions.map do |submission|
    row = [
      submission.id,
      "<input type='checkbox' class='row-checkbox' />",
      submission.semester_and_year,
      submission.cleaned_title,
      "#{submission.author.last_name}, #{submission.author.first_name}",
      submission.degree_type.name,
      submission.committee_members.map do |cm|
      cm_email = cm.email || ' '
      cm_name = cm.name || ' '
      cm_role = cm.role || ' '
      "<ul class='committee-list'><li class='role'>#{cm_role.delete(',')}</li><li class='name'>#{cm_name.delete(',')}</li><li class='email'>#{cm_email.delete(',')}</li></ul>".html_safe
      end
    ]
  end
end

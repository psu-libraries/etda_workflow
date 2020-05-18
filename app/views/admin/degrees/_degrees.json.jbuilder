json.array! [
  "<a href=#{edit_admin_degree_path(degree)}>#{degree.name}</a>",
  degree.description,
  degree.degree_type.name,
  degree.active_status
]

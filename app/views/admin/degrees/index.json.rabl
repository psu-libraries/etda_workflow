# frozen_string_literal: true

object false

node(:data) do
  table = @degrees.map do |degree|
    row = [
      "<a href=#{edit_admin_degree_path(degree)}>#{degree.name}</a>",
      degree.description,
      degree.degree_type.name,
      degree.active_status
    ]
  end
end

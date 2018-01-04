object false

node(:data) do
  table = @programs.map do |program|
    row = [
        "<a href=#{edit_admin_program_path(program)}>#{program.name}</a>",
        program.active_status
    ]
  end
end

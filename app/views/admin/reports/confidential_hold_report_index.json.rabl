object false

node(:data) do
  table = @authors.map do |author|
    row = [
      author.id,
      "<input type='checkbox' class='row-checkbox' />",
      author.last_name,
      author.first_name,
      author.middle_name,
      author.access_id,
      author.psu_email_address,
      author.alternate_email_address,
      author.psu_idn,
      author.confidential_hold,
      author.confidential_hold_set_at
    ]
  end
end
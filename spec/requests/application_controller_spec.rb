require 'rails_helper'

RSpec.describe ApplicationController do
  it 'signs user in and out' do
    author = Author.create!(access_id: 'abc123', psu_email_address: 'abc123@psu.edu', last_name: 'Testor', first_name: 'Testy', address_1: 'test drive', city: 'Testburg', state: 'PA', zip: '16801', phone_number: '999-999-9999', psu_idn: '9123412344')

    sign_in author
    get root_path
    expect(controller.current_author).to eq(author)

    sign_out author
    get root_path
    expect(controller.current_author).to be_nil
  end
end

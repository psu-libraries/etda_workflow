require 'rails_helper'

RSpec.describe 'Devise Login', type: :request do
  RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
  let(:author) { FactoryBot.create(:author) }
  before do
    allow(request).to receive(:headers).and_return('REMOTE_USER' => author.access_id)
  end

  it 'signs author in and out' do
    headers = { 'REMOTE_USER' => author.access_id }
    request.headers.merge! headers
    sign_in author
    get root_path
    expect(controller.current_author).to eq(author)

    sign_out author
    get root_path
    expect(controller.current_author).to be_nil
  end

  before do
    allow(Rails.application.secrets).to receive(:webaccess).and_return(vservice: "ahost.psu.edu", vhost: 'https://myapp.psu.edu')
  end
  context 'production environment' do
    before do
      allow(Rails).to receive(:env) { "production".inquiry }
    end

    it 'author can login and logout' do
      get login_author_path
      assert_response :redirect, '<302: Found> redirect to <"#{WebAccess.new().login_url}">'

      get logout_author_path
      assert_response :redirect, '<302: Found> redirect to <"#{WebAccess.new().logout_url}">'
    end
  end
  context 'development environment' do
    before do
      allow(Rails).to receive(:env) { "development".inquiry }
    end

    it 'author can login and logout' do
      get login_author_path
      assert_response :redirect, '<302: Found> redirect to <"#{WebAccess.new().login_url}">'

      get logout_author_path
      assert_response :redirect, '<302: Found> redirect to <"#{WebAccess.new().logout_url}">'
    end
  end
end

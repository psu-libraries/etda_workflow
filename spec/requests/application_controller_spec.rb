require 'rails_helper'
require 'devise/test/controller_helpers'

RSpec.describe 'Devise Login', type: :request do
  RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
  let(:author) { FactoryBot.create(:author) }
  before do
    allow(request).to receive(:headers).and_return('REMOTE_USER' => 'saw140')
  end

  it 'signs author in and out' do
    headers = { 'REMOTE_USER' => 'saw140' }
    author = Author.find_by_access_id('saw140')
    expect(author).to be_nil
    request.headers.merge! headers
    Devise::Strategies::WebaccessAuthenticatable.new(headers).authenticate!
    get root_path
    author = Author.find_by_access_id('saw140')
    expect(author).to_not be_nil
    # expect(current_author).to eql(author)
    # sign_out(author)
    # get root_path
    # expect(current_author).to be_nil
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
      allow(Rails).to receive(:env) { "production".inquiry }
    end

    it 'author can login and logout' do
      get login_author_path
      assert_response :redirect, '<302: Found> redirect to <"#{WebAccess.new().login_url}">'

      get logout_author_path
      assert_response :redirect, '<302: Found> redirect to <"#{WebAccess.new().logout_url}">'
    end
  end
end

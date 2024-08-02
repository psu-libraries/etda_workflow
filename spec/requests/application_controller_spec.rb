# frozen_string_literal: true

require 'rails_helper'
require 'devise/test/controller_helpers'

RSpec.describe 'Devise Login', type: :request do
  RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
  let(:author) { FactoryBot.create(:author) }

  before do
    allow(request).to receive(:controller).and_return("admin/degrees")
    allow(request).to receive(:headers).and_return('HTTP_REMOTE_USER' => 'saw140')
  end

  it 'signs author in and out' do
    headers = { 'HTTP_REMOTE_USER' => 'ajk5603', 'REQUEST_URI' => '/author/submissions' }
    expect(Author.find_by(access_id: 'ajk5603')).to be_nil
    request.headers.merge! headers
    Devise::Strategies::OidcAuthenticatable.new(headers).authenticate!
    get root_path
    expect(Author.find_by(access_id: 'ajk5603')).not_to be_nil
  end

  it 'signs admin in and out' do
    headers = { 'HTTP_REMOTE_USER' => 'xxb13', 'REQUEST_URI' => '/admin/degrees' }
    expect(Admin.find_by(access_id: 'xxb13')).to be_nil
    request.headers.merge! headers
    Devise::Strategies::OidcAuthenticatable.new(headers).authenticate!
    get root_path
    expect(Admin.find_by(access_id: 'xxb13')).not_to be_nil
  end

  it 'signs approver in and out' do
    headers = { 'HTTP_REMOTE_USER' => 'ajk5603', 'REQUEST_URI' => '/approver' }
    expect(Approver.find_by(access_id: 'ajk5603')).to be_nil
    request.headers.merge! headers
    Devise::Strategies::OidcAuthenticatable.new(headers).authenticate!
    get root_path
    expect(Approver.find_by(access_id: 'ajk5603')).not_to be_nil
  end

  it 'does not authenticate an admin who is not in ldap admin group' do
    headers = { 'HTTP_REMOTE_USER' => 'saw140', 'REQUEST_URI' => '/admin/degrees' }
    expect(Admin.find_by(access_id: 'saw140')).to be_nil
    request.headers.merge! headers
    Devise::Strategies::OidcAuthenticatable.new(headers).authenticate! if LdapUniversityDirectory.new.in_admin_group? 'saw140'
    expect(Admin.find_by(access_id: 'saw140')).to be_nil
  end

  context 'production environment' do
    before do
      allow(Rails).to receive(:env) { "production".inquiry }
    end

    it 'author can login and logout' do
      get login_path
      assert_response :redirect, "<302: Found> redirect to </login>"

      get logout_path
      assert_response :redirect, "<302: Found> redirect to </>"
    end
  end

  context 'development environment' do
    before do
      allow(Rails).to receive(:env) { "production".inquiry }
    end

    it 'author can login and logout' do
      get login_path
      assert_response :redirect, "<302: Found> redirect to </login>"

      get logout_path
      assert_response :redirect, "<302: Found> redirect to </>"
    end
  end

  describe 'storing session[:return_to]' do
    it 'stores request url if valid url to return to or else it stores user root path' do
      # urls with .json appended to the end is a common occcurence (datatables) that we consider to be invalid
      get '/approver'
      expect(session[:return_to]).to eq 'http://www.example.com/approver'
      get '/approver.json'
      expect(session[:return_to]).to eq '/approver'
      get '/author'
      expect(session[:return_to]).to eq 'http://www.example.com/author'
      get '/author.json'
      expect(session[:return_to]).to eq '/author'
      get '/admin'
      expect(session[:return_to]).to eq 'http://www.example.com/admin'
      get '/admin.json'
      expect(session[:return_to]).to eq '/admin'
    end
  end
end

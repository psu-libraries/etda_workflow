# frozen_string_literal: true

require 'rails_helper'
require 'devise'

RSpec.describe RedirectToOidcFailure, type: :model do
  subject = described_class.new
  before { allow(subject).to receive(:request).and_return(request) }

  describe subject do
    let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'me123', 'REQUEST_URI' => '/' }) }

    it 'creates redirect url' do
      allow(request).to receive(:env).and_return(:headers)
      expect(subject.redirect_url).to eq('/')
    end
  end
end

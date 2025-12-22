# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Webhooks', type: :request do
  describe 'POST /webhooks/auto_remediate' do
    it 'returns no content' do
      post '/webhooks/auto_remediate', params: { example: 'data' }.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response).to have_http_status(:no_content)
    end
  end
end

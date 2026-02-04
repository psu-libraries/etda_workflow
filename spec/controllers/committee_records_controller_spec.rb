require "rails_helper"

RSpec.describe "CommitteeRecords API", type: :request do
  let(:path) { "/api/v1/committee_records/faculty_committees" }

  let!(:external_app) { ExternalApp.create!(name: "Test App") }
  let!(:api_token) { ApiToken.create!(token: "test_token", external_app: external_app) }

  let(:headers) do
    {
      "CONTENT_TYPE" => "application/json",
      "ACCEPT" => "application/json",
      "Authorization" => "Bearer #{api_token.token}"
    }
  end

  describe "authentication" do
    it "returns 401 without token" do
      post path, params: { access_id: "aab27" }.to_json

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
    end
  end

  describe "basic success response" do
    it "returns 200 and expected keys" do
      allow(CommitteeMember).to receive_messages(includes: CommitteeMember, where: [])

      post path, params: { access_id: "aab27" }.to_json, headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json).to have_key("faculty_access_id")
      expect(json).to have_key("committees")
    end
  end

  describe "internal error handling" do
    it "returns 500 when an exception occurs" do
      allow(CommitteeMember).to receive(:includes).and_raise(StandardError.new("boom"))

      post path, params: { access_id: "aab27" }.to_json, headers: headers

      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)["error"]).to eq("boom")
    end
  end
end

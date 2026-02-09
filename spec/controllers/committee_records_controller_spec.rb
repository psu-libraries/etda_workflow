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

  describe "parameter validation" do
    it "returns 400 when access_id is missing" do
      post path, params: {}.to_json, headers: headers

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["error"]).to eq("access_id is required")
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

  describe "response body structure" do
    it "returns committee payload with core fields" do
      committee_role = instance_double("CommitteeRole", name: "Advisor", code: "ADV")
      author = instance_double("Author", first_name: "Ada", last_name: "Lovelace", access_id: "apl123")

      submission = instance_double(
        "Submission",
        id: 42,
        title: "Thesis Title",
        semester: "Spring",
        year: 2026,
        degree: nil,
        program: nil,
        final_submission_approved_at: nil,
        status: "released for publication"
      )

      allow(submission).to receive(:author).and_return(author)

      membership = instance_double(
        "CommitteeMember",
        id: 7,
        committee_role: committee_role,
        submission: submission,
        approval_started_at: nil,
        status: "approved"
      )

      allow(CommitteeMember).to receive_messages(includes: CommitteeMember, where: [membership])

      post path, params: { access_id: "aab27" }.to_json, headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      committee = json["committees"].first

      expect(committee).to include(
        "committee_member_id" => 7,
        "role" => "Advisor",
        "student_access_id" => "apl123",
        "submission_id" => 42,
        "title" => "Thesis Title"
      )
    end
  end
end

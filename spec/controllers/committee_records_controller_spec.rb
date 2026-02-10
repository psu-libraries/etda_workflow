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
      allow(CommitteeMember).to receive(:joins).and_raise(StandardError.new("boom"))

      post path, params: { access_id: "aab27" }.to_json, headers: headers

      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)["error"]).to eq("boom")
    end
  end

  describe "response body structure" do
    let(:relation) { instance_double("ActiveRecord::Relation") }

    before do
      allow(CommitteeMember).to receive(:joins).with(:submission).and_return(relation)

      allow(relation).to receive_messages(
        where: relation,
        includes: relation
      )
    end

    describe "when submission is complete" do
      it "returns key submission and student fields" do
        committee_role = instance_double("CommitteeRole", name: "Advisor", code: "ADV")
        author = instance_double("Author", first_name: "Ada", last_name: "Lovelace", access_id: "apl123")

        degree = instance_double("Degree", name: "MS")
        program = instance_double("Program", name: "Computer Science")

        submission = instance_double(
          "Submission",
          id: 42,
          title: "Thesis Title",
          semester: "Spring",
          year: 2026,
          degree: degree,
          program: program,
          final_submission_approved_at: nil,
          status: "released for publication",
          author: author
        )

        membership = instance_double(
          "CommitteeMember",
          id: 7,
          committee_role: committee_role,
          submission: submission,
          approval_started_at: nil,
          status: "approved"
        )

        allow(relation).to receive(:where).with(access_id: "aab27").and_return([membership])

        post path, params: { access_id: "aab27" }.to_json, headers: headers

        expect(response).to have_http_status(:ok)

        committee = JSON.parse(response.body)["committees"].first

        expect(committee).to include(
          "committee_member_id" => 7,
          "role" => "Advisor",
          "student_access_id" => "apl123",
          "submission_id" => 42,
          "title" => "Thesis Title"
        )

        expect(committee["degree_name"]).to eq("MS")
        expect(committee["program_name"]).to eq("Computer Science")
      end
    end

    describe "when submission data is blank" do
      it "returns nils for safe fields" do
        committee_role = instance_double("CommitteeRole", name: nil, code: nil)

        submission = instance_double(
          "Submission",
          id: 42,
          title: nil,
          semester: nil,
          year: nil,
          degree: nil,
          program: nil,
          final_submission_approved_at: nil,
          status: "waiting for publication release",
          author: nil
        )

        membership = instance_double(
          "CommitteeMember",
          id: 7,
          committee_role: committee_role,
          submission: submission,
          approval_started_at: nil,
          status: nil
        )

        allow(relation).to receive(:where).with(access_id: "aab27").and_return([membership])

        post path, params: { access_id: "aab27" }.to_json, headers: headers

        expect(response).to have_http_status(:ok)

        committee = JSON.parse(response.body)["committees"].first

        expect(committee).to include(
          "committee_member_id" => 7,
          "submission_id" => 42
        )

        expect(committee["role"]).to be_nil
        expect(committee["student_access_id"]).to be_nil
        expect(committee["title"]).to be_nil
        expect(committee["degree_name"]).to be_nil
        expect(committee["program_name"]).to be_nil
      end
    end

    describe "when faculty has multiple committees" do
      it "returns all committee memberships for the faculty access_id" do
        relation = instance_double("ActiveRecord::Relation")
        allow(CommitteeMember).to receive(:joins).with(:submission).and_return(relation)
        allow(relation).to receive_messages(where: relation, includes: relation)

        role1 = instance_double("CommitteeRole", name: "Advisor", code: "ADV")
        role2 = instance_double("CommitteeRole", name: "Reader", code: "RDR")
        author = instance_double("Author", first_name: "Ada", last_name: "Lovelace", access_id: "apl123")

        submission1 = instance_double(
          "Submission",
          id: 101,
          title: "Thesis One",
          semester: "Spring",
          year: 2026,
          degree: nil,
          program: nil,
          final_submission_approved_at: nil,
          status: "released for publication",
          author: author
        )

        submission2 = instance_double(
          "Submission",
          id: 202,
          title: "Thesis Two",
          semester: "Fall",
          year: 2025,
          degree: nil,
          program: nil,
          final_submission_approved_at: nil,
          status: "waiting for publication release",
          author: author
        )

        membership1 = instance_double(
          "CommitteeMember",
          id: 1,
          committee_role: role1,
          submission: submission1,
          approval_started_at: nil,
          status: "approved"
        )

        membership2 = instance_double(
          "CommitteeMember",
          id: 2,
          committee_role: role2,
          submission: submission2,
          approval_started_at: nil,
          status: "pending"
        )

        allow(relation).to receive(:where).with(access_id: "aab27").and_return([membership1, membership2])

        post path, params: { access_id: "aab27" }.to_json, headers: headers

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        expect(body["faculty_access_id"]).to eq("aab27")
        expect(body["committees"].size).to eq(2)

        ids = body["committees"].map { |c| c["committee_member_id"] }
        expect(ids).to contain_exactly(1, 2)
      end
    end
  end
end

require "rails_helper"

RSpec.describe "CommitteeRecords API", type: :request do
  let(:external_app) { create(:external_app) }
  let(:api_token) { create(:api_token, external_app: external_app) }

  let(:role) do
    create(:committee_role, name: "Chair & Dissertation Advisor")
  end

  let(:member) do
    create(
      :committee_member,
      access_id: "mms8130",
      committee_role: role
    )
  end

  before do
    member
  end

  it "returns normalized committee role" do
    post "/api/v1/committee_records/faculty_committees",
         headers: {
           "Authorization" => api_token.token,
           "Content-Type" => "application/json"
         },
         params: { access_id: "mms8130" }

    json = JSON.parse(response.body)

    expect(response).to have_http_status(:ok)
    expect(json["committees"].first["committee_role"]).to eq("Chairperson")
  end
end

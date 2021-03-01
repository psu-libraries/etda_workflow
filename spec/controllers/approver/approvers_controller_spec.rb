# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Approver::ApproversController, type: :controller do
  let!(:approver) { FactoryBot.create :approver, access_id: 'approverflow' }

  before do
    headers = { 'REMOTE_USER' => 'approverflow', 'REQUEST_URI' => '/approver' }
    request.headers.merge! headers
    # Skip authentication
    allow_any_instance_of(ApproverController).to receive(:set_session).and_return true
    allow_any_instance_of(ApproverController).to receive(:approver_auth).and_return true
  end

  describe '#index' do
    it 'shows all committee member reviews' do
      expect(get: approver_approver_reviews_path).to route_to(controller: 'approver/approvers', action: 'index')
    end

    it 'links committee member records' do
      false_approver = FactoryBot.create :approver
      committee_member1 = FactoryBot.create :committee_member, access_id: 'approverflow'
      committee_member2 = FactoryBot.create :committee_member, access_id: 'approverflow', approver_id: false_approver.id
      expect(committee_member1.approver_id).to eq nil
      expect(committee_member2.approver_id).to eq false_approver.id
      get :index
      expect(CommitteeMember.find(committee_member1.id).approver_id).to eq approver.id
      expect(CommitteeMember.find(committee_member2.id).approver_id).to eq approver.id
    end
  end

  describe '#edit' do
    let(:committee_member) { FactoryBot.create :committee_member, access_id: 'approverflow' }

    it 'edits an existing committee member' do
      expect(get: approver_path(committee_member)).to route_to(controller: "approver/approvers", action: 'edit', id: committee_member.id.to_s)
    end
  end
end

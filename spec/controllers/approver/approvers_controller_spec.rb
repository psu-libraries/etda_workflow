# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Approver::ApproversController, type: :controller do
  describe '#index' do
    it 'shows all committee member reviews' do
      expect(get: approver_approver_reviews_path).to route_to(controller: 'approver/approvers', action: 'index')
    end
  end

  describe '#edit' do
    let(:committee_member) { FactoryBot.create :committee_member, access_id: 'approverflow' }

    it 'edits an existing committee member' do
      expect(get: approver_path(committee_member)).to route_to(controller: "approver/approvers", action: 'edit', id: committee_member.id.to_s)
    end
  end
end

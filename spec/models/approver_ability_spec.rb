# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe ApproverAbility, type: :model do
  let!(:approver_user) { FactoryBot.create :approver, access_id: 'approverflow' }

  context 'An Approver can edit their committee_member record' do
    let(:approver_ability) { described_class.new(approver_user, nil) }

    it 'allows approver to view, read, edit their committee_member record' do
      committee_member = FactoryBot.create :committee_member, access_id: approver_user.access_id, approver_id: approver_user.id
      expect(approver_ability.can?(:view, committee_member)).to be_truthy
      expect(approver_ability.can?(:read, committee_member)).to be_truthy
      expect(approver_ability.can?(:edit, committee_member)).to be_truthy
    end

    it "does not allow approver to view, read, edit someone else's committee_member record" do
      different_committee_member = FactoryBot.create :committee_member
      expect(approver_ability.can?(:view, different_committee_member)).to be_falsey
      expect(approver_ability.can?(:read, different_committee_member)).to be_falsey
      expect(approver_ability.can?(:edit, different_committee_member)).to be_falsey
    end
  end
end

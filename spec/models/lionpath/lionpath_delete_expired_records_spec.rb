require 'model_spec_helper'

RSpec.describe Lionpath::LionpathDeleteExpiredRecords do
  let!(:non_lp_sub1) { FactoryBot.create :submission }
  let!(:non_lp_sub2) { FactoryBot.create :submission }
  let!(:non_exp_lp_sub1) { FactoryBot.create :submission, lionpath_updated_at: DateTime.now }
  let!(:non_exp_lp_sub2) { FactoryBot.create :submission, lionpath_updated_at: (DateTime.now - 1.day) }
  let!(:exp_lp_sub1) { FactoryBot.create :submission, lionpath_updated_at: (DateTime.now - 2.days) }
  let!(:exp_lp_sub2) { FactoryBot.create :submission, lionpath_updated_at: (DateTime.now - 10.days) }
  let!(:non_lp_cm1) { FactoryBot.create :committee_member }
  let!(:non_lp_cm2) { FactoryBot.create :committee_member }
  let!(:non_exp_lp_cm1) { FactoryBot.create :committee_member, lionpath_updated_at: DateTime.now }
  let!(:non_exp_lp_cm2) { FactoryBot.create :committee_member, lionpath_updated_at: (DateTime.now - 1.day) }
  let!(:exp_lp_cm1) { FactoryBot.create :committee_member, lionpath_updated_at: (DateTime.now - 2.days) }
  let!(:exp_lp_cm2) { FactoryBot.create :committee_member, lionpath_updated_at: (DateTime.now - 10.days) }

  context "when #safe_to_delete returns true" do
    before do
      allow(described_class).to receive(:total_lp_sub_count).and_return 10000
      allow(described_class).to receive(:total_lp_cmtee_mmbr_count).and_return 10000
    end

    it "deletes expired lionpath submissions" do
      expect{ described_class.delete }.to change(Submission, :count).by -2
    end

    it "deletes expired lionpath committee_members" do
      expect{ described_class.delete }.to change(CommitteeMember, :count).by -2
    end
  end

  context "when #safe_to_delete returns false" do
    it "does not delete expired lionpath submissions" do
      expect{ described_class.delete }.not_to change(Submission, :count)
    end

    it "does not delete expired lionpath committee_members" do
      expect{ described_class.delete }.not_to change(CommitteeMember, :count)
    end
  end
end

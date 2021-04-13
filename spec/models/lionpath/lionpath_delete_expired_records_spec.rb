require 'model_spec_helper'

RSpec.describe Lionpath::LionpathDeleteExpiredRecords do
  let!(:non_lp_sub1) { FactoryBot.create :submission }
  let!(:non_lp_sub2) { FactoryBot.create :submission }
  let!(:non_exp_lp_sub1) { FactoryBot.create :submission, lionpath_updated_at: DateTime.now }
  let!(:non_exp_lp_sub2) { FactoryBot.create :submission, lionpath_updated_at: (DateTime.now - 1.day) }
  let!(:exp_lp_sub1) { FactoryBot.create :submission, lionpath_updated_at: (DateTime.now - 2.days) }
  let!(:exp_lp_sub2) { FactoryBot.create :submission, lionpath_updated_at: (DateTime.now - 10.days) }
  let!(:exp_lp_sub3) do
    FactoryBot.create :submission, lionpath_updated_at: (DateTime.now - 10.days), created_at: (DateTime.now - 5.years)
  end
  let!(:non_lp_cm1) { FactoryBot.create :committee_member }
  let!(:non_lp_cm2) { FactoryBot.create :committee_member }
  let!(:non_exp_lp_cm1) { FactoryBot.create :committee_member, lionpath_updated_at: DateTime.now }
  let!(:non_exp_lp_cm2) { FactoryBot.create :committee_member, lionpath_updated_at: (DateTime.now - 1.day) }
  let!(:exp_lp_cm1) { FactoryBot.create :committee_member, lionpath_updated_at: (DateTime.now - 2.days) }
  let!(:exp_lp_cm2) { FactoryBot.create :committee_member, lionpath_updated_at: (DateTime.now - 10.days) }
  let!(:exp_lp_cm3) do
    FactoryBot.create :committee_member, lionpath_updated_at: (DateTime.now - 10.days),
                      created_at: (DateTime.now - 5.years)
  end

  context "when less than 1% of the total number of records are expired" do
    it "deletes expired lionpath submissions that are less than 5 years old" do
      FactoryBot.create_list :submission, 200, lionpath_updated_at: DateTime.now
      expect { described_class.delete }.to change(Submission, :count).by(-2)
      expect { exp_lp_sub1.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { exp_lp_sub2.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(exp_lp_sub3.reload).to eq exp_lp_sub3
    end

    it "deletes expired lionpath committee_members that are less than 5 years old" do
      FactoryBot.create_list :committee_member, 200, lionpath_updated_at: DateTime.now
      expect { described_class.delete }.to change(CommitteeMember, :count).by(-2)
      expect { exp_lp_cm1.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { exp_lp_cm2.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(exp_lp_cm3.reload).to eq exp_lp_cm3
    end
  end

  context "when more than 1% of the total number of records are expired" do
    it "does not delete expired lionpath submissions" do
      expect { described_class.delete }.not_to change(Submission, :count)
    end

    it "does not delete expired lionpath committee_members" do
      expect { described_class.delete }.not_to change(CommitteeMember, :count)
    end
  end
end

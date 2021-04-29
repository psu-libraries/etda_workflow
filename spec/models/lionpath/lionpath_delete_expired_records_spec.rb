require 'model_spec_helper'

RSpec.describe Lionpath::LionpathDeleteExpiredRecords do
  let!(:dept_head_role) { FactoryBot.create :committee_role, is_program_head: true }
  let!(:non_lp_sub1) { FactoryBot.create :submission, :collecting_program_information }
  let!(:non_lp_sub2) { FactoryBot.create :submission, :collecting_program_information }
  let!(:non_exp_lp_sub1) do
    FactoryBot.create :submission, :collecting_program_information, lionpath_updated_at: DateTime.now
  end
  let!(:non_exp_lp_sub2) do
    FactoryBot.create :submission, :collecting_program_information, lionpath_updated_at: (DateTime.now - 1.day)
  end
  let!(:exp_lp_sub1) do
    FactoryBot.create :submission, :collecting_program_information, lionpath_updated_at: (DateTime.now - 2.days)
  end
  let!(:exp_lp_sub2) do
    FactoryBot.create :submission, :collecting_program_information, lionpath_updated_at: (DateTime.now - 10.days)
  end
  let!(:exp_lp_sub3) do
    FactoryBot.create :submission, :collecting_program_information, lionpath_updated_at: (DateTime.now - 10.days),
                      created_at: (DateTime.now - 5.years)
  end
  let!(:exp_lp_sub4) do
    FactoryBot.create :submission, :collecting_committee, lionpath_updated_at: (DateTime.now - 10.days)
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
  let!(:exp_lp_cm4) do
    FactoryBot.create :committee_member, lionpath_updated_at: (DateTime.now - 10.days),
                                         external_to_psu_id: 'mgc25'
  end

  context "when less than 5% of the total number of records are expired" do
    it "deletes expired lionpath submissions that are less than 5 years old and collecting program information" do
      FactoryBot.create_list :submission, 100, lionpath_updated_at: DateTime.now
      FactoryBot.create_list :committee_member, 100, lionpath_updated_at: DateTime.now
      expect { described_class.delete }.to change(Submission, :count).by(-2)
      expect { exp_lp_sub1.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { exp_lp_sub2.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(exp_lp_sub3.reload).to eq exp_lp_sub3
      expect(exp_lp_sub4.reload).to eq exp_lp_sub4
      expect(WorkflowMailer.deliveries.count).to eq 0
    end

    it "deletes expired lionpath committee_members that are less than 5 years old, not external to PSU, and not program chairs" do
      FactoryBot.create_list :committee_member, 100, lionpath_updated_at: DateTime.now
      FactoryBot.create_list :submission, 100, lionpath_updated_at: DateTime.now
      expect { described_class.delete }.to change(CommitteeMember, :count).by(-2)
      expect { exp_lp_cm1.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { exp_lp_cm2.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(exp_lp_cm3.reload).to eq exp_lp_cm3
      expect(exp_lp_cm4.reload).to eq exp_lp_cm4
      expect(WorkflowMailer.deliveries.count).to eq 0
    end
  end

  context "when more than 5% of the total number of records are expired" do
    it "does not delete expired lionpath submissions" do
      FactoryBot.create_list :committee_member, 100, lionpath_updated_at: DateTime.now
      expect { described_class.delete }.not_to change(Submission, :count)
      expect(WorkflowMailer.deliveries.count).to eq 1
    end

    it "does not delete expired lionpath committee_members" do
      FactoryBot.create_list :submission, 100, lionpath_updated_at: DateTime.now
      expect { described_class.delete }.not_to change(CommitteeMember, :count)
      expect(WorkflowMailer.deliveries.count).to eq 1
    end
  end
end

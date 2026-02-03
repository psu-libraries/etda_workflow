require "rails_helper"

RSpec.describe CommitteeRoleNormalizer do
  describe ".normalize" do
    it "maps co-chair roles correctly" do
      expect(
        described_class.normalize("Co-Chair & Dissertation Advisor")
      ).to eq("Co-Chairperson")
    end

    it "maps chair roles correctly" do
      expect(
        described_class.normalize("Chair of Committee")
      ).to eq("Chairperson")
    end

    it "prioritizes chair over advisor when both appear" do
      expect(
        described_class.normalize("Chair & Dissertation Advisor")
      ).to eq("Chairperson")
    end

    it "maps advisor roles" do
      expect(
        described_class.normalize("Dissertation Advisr")
      ).to eq("Advisor")
    end

    it "maps member and representative roles" do
      expect(
        described_class.normalize("Committee Member & Dean Grad Sch Rep")
      ).to eq("Member")
    end

    it "returns Other for unknown roles" do
      expect(
        described_class.normalize("Some Weird ETDA Thing")
      ).to eq("Other")
    end

    it "returns Other for blank values" do
      expect(
        described_class.normalize(nil)
      ).to eq("Other")
    end
  end
end

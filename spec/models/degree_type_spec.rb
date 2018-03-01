# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe DegreeType, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:slug).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }

  it { is_expected.to have_db_index(:name).unique(true) }
  it { is_expected.to have_db_index(:slug).unique(true) }

  describe '#default' do
    it "returns the first degree type" do
      expect(described_class.default).to eq(described_class.first)
    end
  end

  describe '#to_s' do
    let(:degree_type) { described_class.new(name: "The Name") }

    it "returns the name" do
      expect(degree_type.to_s).to eq "The Name"
      expect(degree_type.to_s).to eq(degree_type.name)
    end
  end

  describe '#to_param' do
    let(:degree_type) { described_class.new(slug: "the_name") }

    it "returns the slug, which is suitable for a URL" do
      expect(degree_type.to_param).to eq "the_name"
    end
  end

  describe '#to_sym' do
    let(:degree_type) { described_class.new(slug: "the_name") }

    it "returns a symbol based on the slug" do
      expect(degree_type.to_sym).to eq :the_name
    end
  end

  # describe '#required_committee_roles' do
  #   let(:required_roles) { described_class.default.required_committee_roles }
  #   let(:degree_type_current) { described_class.default.id }
  #
  #   it "returns the proper type and number of committee roles for this degree type" do
  #     @role_list = []
  #     CommitteeRole.all.where(degree_type_id: degree_type_current).each do |r|
  #       r.num_required.times do |_rr|
  #         @role_list << r
  #       end
  #     end
  #     expect(@role_list).to eq required_roles
  #     expect(@role_list.count).to eq required_roles.count
  #   end
  # end

  describe "the DegreeType seed data" do
    context "when partner is graduate" do
      it "creates the two essential degree types" do
        expect(described_class.all.collect(&:name)).to eq(DegreeType::NAMES[current_partner.id])
      end
    end
  end
end

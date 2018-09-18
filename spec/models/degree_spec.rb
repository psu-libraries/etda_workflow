# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe Degree, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:name).of_type(:string) }
  it { is_expected.to have_db_column(:description).of_type(:string) }
  it { is_expected.to have_db_column(:degree_type_id).of_type(:integer) }
  it { is_expected.to have_db_column(:is_active).of_type(:boolean) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:legacy_id).of_type(:integer) }
  it { is_expected.to have_db_column(:legacy_old_id).of_type(:integer) }

  it { is_expected.to belong_to(:degree_type).class_name('DegreeType') }

  it { is_expected.to have_db_index(:degree_type_id) }
  it { is_expected.to have_db_index(:legacy_id) }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :description }

  it { is_expected.to have_many :submissions }
  it { is_expected.to belong_to :degree_type }

  describe described_class do
    subject { expect(subject).to validate_uniqueness_of :name }

    let(:degree) { described_class.new(degree_type_id: DegreeType.default, name: 'MyDegree') }
  end

  describe '#active_status' do
    degree = described_class.new(degree_type_id: DegreeType.first)
    context 'When is_active is false or nil' do
      it 'returns No' do
        degree.is_active = false
        expect(degree.active_status).to eq('No')
        degree.is_active = nil
        expect(degree.active_status).to eq('No')
      end
    end

    context 'When is_active is true' do
      it 'returns Yes' do
        degree.is_active = true
        expect(degree.active_status).to eq('Yes')
      end
    end
  end

  describe '#set_to_active_to_true' do
    it "Sets activation status to true for new instances" do
      testdegree = described_class.create(name: 'testdegree', description: 'test', degree_type_id: DegreeType.first.id)
      expect(testdegree.is_active).to be_truthy
    end
  end

  describe '#list of valid degree names in upcase' do
    it 'returns an array of active degree names with blanks replaced by underscores' do
      described_class.create(name: 'M M M', is_active: true, description: 'one', degree_type_id: DegreeType.default.id)
      described_class.create(name: 'a b c', is_active: true, description: 'two', degree_type_id: DegreeType.default.id)
      described_class.create(name: 'XBC', is_active: false, description: 'three', degree_type_id: DegreeType.default.id)
      described_class.create(name: 'MY degree name', is_active: true, description: 'four', degree_type_id: DegreeType.default.id)
      list = described_class.valid_degrees_list
      expect(list).to be_a_kind_of(Array)
      expect(list.count).to eql(described_class.where(is_active: true).count)
      expect(list).to include('M_M_M')
      expect(list).not_to include('a b c')
      expect(list).not_to include('XBC')
    end
  end

  describe '#etd_degree_slug' do
    it 'returns the degree name normalized' do
      expect(described_class.new(name: 'De GrEE').slug).to eq('DE_GREE')
    end
    it 'returns nil when given an invalid degree id' do
      expect(described_class.etd_degree_slug(200)).to be_nil
    end
  end
end

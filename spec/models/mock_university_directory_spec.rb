# frozen_string_literal: true

require 'model_spec_helper'
require 'shared/shared_examples_for_university_directory'

RSpec.describe MockUniversityDirectory, type: :model do
  subject(:directory) { described_class.new }

  it_behaves_like "a UniversityDirectory"

  describe '#autocomplete' do
    let(:result) { directory.autocomplete(search_string) }

    context "when given string that doesn't match any of the fake data" do
      let(:search_string) { "not there" }

      it "returns an empty array" do
        expect(result).to eq([])
      end
    end

    context "when given a string that matches the fake data" do
      let(:search_string) { "alex" }

      it "returns an array of hashes that can be returned to jQuery autocomplete" do
        expect(result).to be_a_kind_of(Array)
        expect(result.first).to have_key(:id)
        expect(result.first).to have_key(:label)
        expect(result.first).to have_key(:value)
      end
    end
  end

  describe '#exists?' do
    let(:result) { directory.exists?(access_id) }

    context "when given an access ID that is not part of the fake data" do
      let(:access_id) { "not there" }

      it "returns false" do
        expect(result).to be(false)
      end
    end

    context "when given an access ID that is part of the fake data" do
      let(:access_id) { "ajk5603" }

      it "returns true" do
        expect(result).to be(true)
      end
    end
  end

  describe '#retrieve' do
    let(:result) { directory.retrieve(access_id, 'uid', LdapResultsMap::AUTHOR_LDAP_MAP) }

    context "when given an access ID that is not part of the fake data" do
      let(:access_id) { "not there" }

      it "returns an empty string" do
        expect(result).to eq([])
      end
    end

    context "when given an access ID that is part of the fake data" do
      let(:access_id) { "ajk5603" }

      it "returns an array of hashes for an author record" do
        expect(result).to be_a_kind_of(Hash)
        expect(result).to have_key(:access_id)
        expect(result).to have_key(:first_name)
        expect(result).to have_key(:address_1)
        expect(result).to have_key(:city)
        expect(result).to have_key(:state)
        expect(result).to have_key(:phone_number)
        expect(result).to have_key(:psu_idn)
      end
    end
  end

  describe 'get_psu_id_number' do
    let(:result) { directory.get_psu_id_number('accessid') }

    context "using any access id to return a fake number" do
      it "returns a fake psu_id_number" do
        expect(result).to eq('999999999')
      end
    end
  end

  describe 'in_admin_group?' do
    let(:result) { directory.in_admin_group?('ajk5603') }

    context 'returns true if admin user' do
      it 'is true' do
        expect(result).to be_truthy
      end
    end

    context 'returns false if no results' do
      it 'is false' do
        result = directory.in_admin_group?('saw140')
        expect(result).to be_falsey
      end
    end

    context 'returns false if user does not exist' do
      it 'is false' do
        result = directory.in_admin_group?('')
        expect(result).to be_falsey
      end
    end
  end
end

# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe LdapSearchFilter, type: :model do
  describe '#create_filter' do
    let(:term) { 'jim smith' }
    let(:client) { instance_double(PsuIdentity::SearchService::Client) }
    let(:eligible_person) { instance_double('Person', user_id: 'abc123', affiliation: ['FACULTY']) }
    let(:second_eligible_person) { instance_double('Person', user_id: 'def456', affiliation: ['RETIREE']) }
    let(:ineligible_person) { instance_double('Person', user_id: 'ghi789', affiliation: ['STUDENT']) }

    before do
      allow(PsuIdentity::SearchService::Client).to receive(:new).and_return(client)
    end

    it 'queries the identity service with expected parameters' do
      allow(client).to receive(:search).and_return([eligible_person])

      described_class.new(term).create_filter

      expect(client).to have_received(:search).with(text: term, size: 50, active: true, service_account: false)
    end

    it 'builds an OR uid LDAP filter for eligible affiliations only' do
      allow(client).to receive(:search).and_return([eligible_person, ineligible_person, second_eligible_person])

      filter = described_class.new(term).create_filter
      expected_filter = Net::LDAP::Filter.eq('uid', 'abc123') | Net::LDAP::Filter.eq('uid', 'def456')

      expect(filter.to_json).to eql(expected_filter.to_json)
    end

    it 'returns nil when no eligible people are returned' do
      allow(client).to receive(:search).and_return([ineligible_person])

      filter = described_class.new(term).create_filter

      expect(filter).to be_nil
    end

    it 'returns nil when search returns no people' do
      allow(client).to receive(:search).and_return([])

      filter = described_class.new(term).create_filter

      expect(filter).to be_nil
    end

    it 'returns nil and logs an error when the identity service raises an error' do
      allow(client).to receive(:search).and_raise(PsuIdentity::SearchService::Error, 'timeout')
      allow(Rails.logger).to receive(:error)

      filter = described_class.new(term).create_filter

      expect(filter).to be_nil
      expect(Rails.logger).to have_received(:error).with('Error searching PSU Identity Service: timeout')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
include Devise::Strategies

RSpec.describe Devise::Strategies::WebaccessAuthenticatable do
  subject { described_class.new(nil) }
  before { allow(subject).to receive(:request).and_return(request) }

  # describe '#valid_author?(request.headers)' do
  #   context 'in a production environment' do
  #     before { allow(Rails).to receive(:env) { "production".inquiry } }
  #
  #
  #     context 'using REMOTE_USER' do
  #       let(:headers) {{ 'REMOTE_USER' => 'abc123' }}
  #       let(:request) { double(headers: { 'REMOTE_USER' => 'abc123' }) }
  #       it { is_expected.to be true }
  #     end
  #     context 'using HTTP_REMOTE_USER' do
  #       let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'abc123' }) }
  #       it { is_expected.not_to be_valid }
  #     end
  #     context 'using no header' do
  #       let(:request) { double(headers: {}) }
  #       it { is_expected.not_to be_valid }
  #     end
  #   end
  #   context 'in a development or test environment' do
  #     context 'using REMOTE_USER' do
  #       let(:request) { double(headers: { 'REMOTE_USER' => 'abc123' }) }
  #       it { is_expected.to be_valid }
  #     end
  #     context 'using HTTP_REMOTE_USER' do
  #       let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'abc123' }) }
  #       it { is_expected.to be_valid }
  #     end
  #     context 'using no header' do
  #       let(:request) { double(headers: {}) }
  #
  #       it { is_expected.not_to be_valid }
  #     end
  #   end
  # end

  describe 'authenticate!' do
    let(:author) { FactoryBot.create(:author) }
    let(:request) { double(headers: { 'HTTP_REMOTE_USER' =>  author.access_id, 'REQUEST_URI' => '/author/submissions' }) }

    context 'with a new user' do
      before { allow(Author).to receive(:find_by_access_id).with(author.access_id).and_return(nil) }
      it 'populates attributes' do
        expect(Author).to receive(:create).with(access_id: author.access_id, psu_email_address: "#{author.access_id}@psu.edu").once.and_return(author)
        expect_any_instance_of(Author).to receive(:populate_attributes).once
        # expect(subject).to be_valid
        expect(subject.authenticate!).to eq(:success)
      end
    end

    context 'with an existing user' do
      before { allow(Author).to receive(:find_by_access_id).with(author.access_id).and_return(author) }
      it 'does not populate attributes' do
        expect(Author).to receive(:create).with(access_id: author.access_id).never
        expect_any_instance_of(Author).to receive(:populate_attributes).never
        # expect(subject).to be_valid
        expect(subject.authenticate!).to eq(:success)
      end
    end
  end
end

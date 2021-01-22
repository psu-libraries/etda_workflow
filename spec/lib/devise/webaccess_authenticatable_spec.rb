# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devise::Strategies::WebaccessAuthenticatable do
  include Devise::Strategies
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

    context 'when author' do
      let(:author) { FactoryBot.create(:author) }
      let(:request) { double(headers: { 'HTTP_REMOTE_USER' => author.access_id, 'REQUEST_URI' => '/author/submissions' }) }

      context 'with a new user' do
        before { allow(Author).to receive(:find_by_access_id).with(author.access_id).and_return(nil) }
        it 'authenticates while creating new user and populating attributes' do
          expect(Author).to receive(:create).with(access_id: author.access_id, psu_email_address: "#{author.access_id}@psu.edu").once.and_return(author)
          expect_any_instance_of(Author).to receive(:populate_attributes).once
          expect(subject).to be_valid
          expect(subject.authenticate!).to eq(:success)
        end
      end

      context 'with an existing user' do
        before { allow(Author).to receive(:find_by_access_id).with(author.access_id).and_return(author) }
        it 'authenticates without creating new user and populating attributes' do
          expect(Author).to receive(:create).with(access_id: author.access_id).never
          expect_any_instance_of(Author).to receive(:populate_attributes).never
          expect_any_instance_of(Author).to receive(:refresh_important_attributes).once
          expect(subject).to be_valid
          expect(subject.authenticate!).to eq(:success)
        end
      end
    end

    context 'when admin' do
      let(:admin) { FactoryBot.create(:admin) }
      let(:request) { double(headers: { 'HTTP_REMOTE_USER' => admin.access_id, 'REQUEST_URI' => '/admin/dissertation' }) }

      context 'with a new user' do
        before { allow(Admin).to receive(:find_by_access_id).with(admin.access_id).and_return(nil) }
        it 'authenticates while creating new user and populating attributes' do
          allow_any_instance_of(LdapUniversityDirectory).to receive(:in_admin_group?).and_return true
          expect(Admin).to receive(:create).with(access_id: admin.access_id, psu_email_address: "#{admin.access_id}@psu.edu").once.and_return(admin)
          expect_any_instance_of(Admin).to receive(:populate_attributes).once
          expect(subject).to be_valid
          expect(subject.authenticate!).to eq(:success)
        end
      end

      context 'with an existing user' do
        before { allow(Admin).to receive(:find_by_access_id).with(admin.access_id).and_return(admin) }
        it 'authenticates without creating new user and populating attributes' do
          expect(Admin).to receive(:create).with(access_id: admin.access_id).never
          expect_any_instance_of(Admin).to receive(:populate_attributes).never
          expect_any_instance_of(Admin).to receive(:refresh_important_attributes).once
          expect(subject).to be_valid
          expect(subject.authenticate!).to eq(:success)
        end
      end
    end

    context 'when approver' do
      let(:approver) { FactoryBot.create(:approver) }
      let(:request) { double(headers: { 'HTTP_REMOTE_USER' => approver.access_id, 'REQUEST_URI' => "/approver/committee_member/1" } ) }

      context 'with a new user' do
        before { allow(Approver).to receive(:find_by_access_id).with(approver.access_id).and_return(nil) }
        it 'authenticates while creating new user' do
          expect(Approver).to receive(:create).with(access_id: approver.access_id).once.and_return(approver)
          expect(subject).to be_valid
          expect(subject.authenticate!).to eq(:success)
        end
      end

      context 'with an existing user' do
        before { allow(Approver).to receive(:find_by_access_id).with(approver.access_id).and_return(approver) }
        it 'authenticates without creating new user' do
          expect(Approver).to receive(:create).with(access_id: approver.access_id).never
          expect(subject).to be_valid
          expect(subject.authenticate!).to eq(:success)
        end
      end
    end
  end

  describe 'fail!' do
    context 'when directing to /author' do
      let(:request) { double(headers: { 'HTTP_REMOTE_USER' => nil, 'REQUEST_URI' => '/author/submissions' }) }

      it 'fails' do
        expect(subject).not_to be_valid
        expect(subject.authenticate!).to eq(:failure)
      end
    end

    context 'when directing to /admin' do
      let(:request) { double(headers: { 'HTTP_REMOTE_USER' => nil, 'REQUEST_URI' => '/admin/dissertation' }) }

      it 'fails' do
        expect(subject).not_to be_valid
        expect(subject.authenticate!).to eq(:failure)
      end
    end

    context 'when directing to /approver' do
      let(:request) { double(headers: { 'HTTP_REMOTE_USER' => nil, 'REQUEST_URI' => '/approver/committee_member/1' }) }

      it 'fails' do
        expect(subject).not_to be_valid
        expect(subject.authenticate!).to eq(:failure)
      end
    end
  end
end

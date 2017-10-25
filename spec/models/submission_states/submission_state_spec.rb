require 'rails_helper'
require 'shoulda-matchers'
require 'support/request_spec_helper'

RSpec.describe SubmissionStates::SubmissionState do
  describe 'class methods' do
    let(:subject) { described_class }
    it { is_expected.to respond_to(:name) }
  end

  describe 'instance methods' do
    let(:subject) { described_class.new }
    it {  is_expected.to respond_to(:valid_state_change?) }
    it {  is_expected.to respond_to(:transitions_to) }
  end

  describe 'name' do
    let(:subject) { described_class.name }
    it { is_expected.not_to be_blank }
  end

  describe 'transitions_to' do
    let(:subject) { described_class.new.transitions_to }
    it { is_expected.to eq [] }
  end

  describe 'transition' do
    let(:submission) { FactoryBot.create :submission, :final_is_restricted }
    let(:subject) { described_class.transition submission }
    it { is_expected.to be_falsey }
  end
end

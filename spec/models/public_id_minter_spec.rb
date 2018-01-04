# frozen_string_literal: true
require 'model_spec_helper'

RSpec.describe PublicIdMinter do
  let(:author) { FactoryBot.create :author }
  let(:submission) { FactoryBot.create :submission, author: author, public_id: '' }
  let(:matching_submission) { FactoryBot.create :submission }
  subject(:id) { described_class.new(submission).id }

  describe 'creates a public id' do
    context "#id" do
      it "returns unique id using submission.id and author's access_id" do
        expect(id).to eq("#{submission.id}#{submission.author.access_id}")
      end
    end

    context "public id exists in a different submission" do
      it "adds the author id to the base public id to make it unique" do
        matching_submission.public_id = described_class.new(submission).id
        matching_submission.save!
        public_id_with_author_id_added = "#{submission.id}#{submission.author.access_id}-#{submission.author.id}"
        second_public_id = described_class.new(submission).id
        expect(second_public_id).to eql(public_id_with_author_id_added)
      end
    end

    context "author's access_id is blank" do
      it "returns a public id using submission_id and author_id" do
        author.access_id = ''
        alternate_public_id = described_class.new(submission).id
        expect(alternate_public_id).to eql("#{submission.id}-#{author.id}")
      end
    end
  end
end

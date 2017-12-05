# frozen_string_literal: true
require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe EtdaFilePaths, type: :model do
  workflow_path = WORKFLOW_BASE_PATH
  explore_path = EXPLORE_BASE_PATH
  this_host = Rails.application.secrets[:webaccess][:path]

  context '#base_path' do
    it 'returns workflow_base_path' do
      expect(described_class.new.workflow_base_path).to eql("#{workflow_path}")
    end
    it 'returns explore_default path' do
      expect(described_class.new.explore_base_path).to eql("#{explore_path}")
    end
  end
  context '#this_host' do
    it 'returns default host' do
      expect(described_class.new.this_host).to eql(this_host + '/')
    end
  end
  context 'workflow uploads' do
    it 'returns final-files path' do
      expect(subject.workflow_upload_final_files_path).to eql("#{workflow_path}#{this_host}/final-submission-files")
    end
    it 'returns format-review path' do
      expect(subject.workflow_upload_format_review_path).to eql("#{workflow_path}#{this_host}/format-review-files")
    end
  end
  context '#workflow_restricted' do
    it 'returns path of published restricted files' do
      expect(subject.workflow_restricted).to eql("#{workflow_path}#{this_host}/restricted")
    end
  end
  context 'explore published paths' do
    it 'returns path of restricted to institution files' do
      expect(subject.explore_psu_only).to eql("#{explore_path}#{this_host}/restricted_institution")
    end
    it 'returns path of open_access files' do
      expect(subject.explore_open).to eql("#{explore_path}#{this_host}/open")
    end
  end
end

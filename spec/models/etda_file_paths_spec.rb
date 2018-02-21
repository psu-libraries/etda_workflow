# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe EtdaFilePath, type: :model do
  workflow_path = WORKFLOW_BASE_PATH
  explore_path = EXPLORE_BASE_PATH

  context '#base_path' do
    it 'returns workflow_base_path' do
      expect(described_class.new.workflow_base_path).to eql(workflow_path.to_s)
    end
    it 'returns explore_default path' do
      expect(described_class.new.explore_base_path).to eql(explore_path.to_s)
    end
  end

  context 'workflow uploads' do
    it 'returns final-files path' do
      expect(described_class.new.workflow_upload_final_files_path).to eql("#{workflow_path}final_submission_files/")
    end
    it 'returns format-review path' do
      expect(described_class.new.workflow_upload_format_review_path).to eql("#{workflow_path}format_review_files/")
    end
  end
  context '#workflow_restricted' do
    it 'returns path of published restricted files' do
      expect(described_class.new.workflow_restricted).to eql("#{workflow_path}restricted/")
    end
  end
  context 'explore published paths' do
    it 'returns path of restricted to institution files' do
      expect(described_class.new.explore_psu_only).to eql("#{explore_path}restricted_institution/")
    end
    it 'returns path of open_access files' do
      expect(described_class.new.explore_open).to eql("#{explore_path}open_access/")
    end
  end
end

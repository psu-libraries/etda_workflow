# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe EtdaFilePaths, type: :model do
  workflow_path = WORKFLOW_BASE_PATH
  explore_path = EXPLORE_BASE_PATH

  describe '#base_path' do
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

  describe '#workflow_restricted' do
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

  describe '#move_a_file' do
    let(:file_paths) { described_class.new }
    let(:fid) { 123 }
    let(:original_file_location) { '/tmp/original/file.pdf' }
    let(:updated_file) do
      instance_double('FinalSubmissionFile',
                      full_file_path: '/dest/path/',
                      asset_identifier: 'file.pdf')
    end

    context 'when the original file does not exist' do
      it 'returns an error message and does not look up the file' do
        allow(File).to receive(:exist?).with(original_file_location).and_return(false)
        allow(Rails.logger).to receive(:error)
        file_class = class_double('FinalSubmissionFile')
        allow(file_class).to receive(:find)

        result = file_paths.move_a_file(fid, original_file_location, file_class: file_class)

        expect(result).to eq("File not found: #{original_file_location}")
        expect(file_class).not_to have_received(:find)
      end
    end

    context 'when the original file exists' do
      it 'moves the file using the provided file_class' do
        file_class = class_double('RemediatedFinalSubmissionFile').as_stubbed_const

        allow(File).to receive(:exist?).with(original_file_location).and_return(true)
        allow(file_class).to receive(:find).with(fid).and_return(updated_file)
        allow(FileUtils).to receive(:mkpath)
        allow(FileUtils).to receive(:mv)

        result = file_paths.move_a_file(fid, original_file_location, file_class: file_class)

        expect(FileUtils).to have_received(:mkpath).with('/dest/path/')
        expect(FileUtils).to have_received(:mv).with(original_file_location, '/dest/path/file.pdf')
        expect(result).to eq('')
      end
    end

    context 'when using FinalSubmissionFile as the file_class' do
      it 'uses FinalSubmissionFile to find the record' do
        file_class = class_double('FinalSubmissionFile').as_stubbed_const

        allow(File).to receive(:exist?).with(original_file_location).and_return(true)
        allow(file_class).to receive(:find).with(fid).and_return(updated_file)
        allow(FileUtils).to receive(:mkpath)
        allow(FileUtils).to receive(:mv)

        file_paths.move_a_file(fid, original_file_location, file_class: file_class)

        expect(file_class).to have_received(:find).with(fid)
      end
    end
  end
end

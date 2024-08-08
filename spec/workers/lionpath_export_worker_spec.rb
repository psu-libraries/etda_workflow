require 'rails_helper'

RSpec.describe LionpathExportWorker do
  let(:submission) { create(:submission) }

  describe '#perform' do
    it 'finds the submission and calls Lionpath::LionpathExport' do
      allow(Submission).to receive(:find).with(submission.id).and_return(submission)

      export_instance = instance_double(Lionpath::LionpathExport)
      allow(Lionpath::LionpathExport).to receive(:new).with(submission).and_return(export_instance)
      allow(export_instance).to receive(:call)

      described_class.perform(submission.id)

      expect(Submission).to have_received(:find).with(submission.id)
      expect(Lionpath::LionpathExport).to have_received(:new).with(submission)
      expect(export_instance).to have_received(:call)
    end
  end

  describe '.perform_async' do
    it 'queues the job' do
      Sidekiq::Worker.clear_all

      expect { described_class.perform_async(submission.id) }.to change { Sidekiq::Worker.jobs.size }.by(1)
    end
  end
end

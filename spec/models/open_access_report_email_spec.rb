require 'model_spec_helper'

RSpec.describe OpenAccessReportEmail do
  subject(:open_access_report_email) { described_class.new }
  context 'when Spring semester' do
    let!(:within_submission) do
      FactoryBot.create :submission, :released_for_publication,
                                      access_level: 'open_access',
                                      released_for_publication_at: DateTime.strptime("03/01/#{Date.today.year}", "%D")
    end
    let!(:outside_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("09/01/#{Date.today.year}", "%D")
    end

    describe '#submissions' do
      it 'includes open_access publications released during Spring semester' do
        allow(open_access_report_email).to receive(:today).and_return Date.strptime("05/31/#{Date.today.year}", "%D")
        expect(open_access_report_email.send(:submissions)).to eq [within_submission]
      end
    end
  end

  context 'when Summer semester' do

  end

  context 'when Fall semester' do

  end
end

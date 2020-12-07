require 'model_spec_helper'

RSpec.describe OpenAccessReportEmail do
  subject(:open_access_report_email) { described_class.new }

  let(:this_year) { Date.today.year }

  describe '#csv' do
    let(:submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.now
    end
    let(:csv) do
      "Last Name,First Name,Title,Degree Type,Graduation Semester,Released On\n#{submission.author.last_name},#{submission.author.first_name},#{submission.title},#{submission.degree.degree_type.name},#{submission.semester} #{submission.year},#{submission.released_for_publication_at.strftime('%D')}\n"
    end

    it 'generates a csv from queried submissions' do
      allow_any_instance_of(described_class).to receive(:submissions).and_return [submission]
      expect(open_access_report_email.send(:csv)).to eq csv
    end
  end

  context 'when report is run on an invalid month' do
    before do
      allow(Date).to receive(:today).and_return Date.strptime("03/30/#{this_year}", "%m/%d/%Y")
    end

    it 'raises and error' do
      expect { open_access_report_email.deliver }.to raise_error OpenAccessReportEmail::InvalidReleaseMonth
    end
  end

  context 'when Spring semester' do
    let!(:within_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("03/01/#{this_year}", "%m/%d/%Y")
    end
    let!(:outside_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("09/01/#{this_year}", "%m/%d/%Y")
    end

    before do
      allow(Date).to receive(:today).and_return Date.strptime("06/30/#{this_year}", "%m/%d/%Y")
    end

    describe '#submissions' do
      it 'includes open_access publications released during Spring semester' do
        expect(open_access_report_email.send(:submissions)).to eq [within_submission]
      end
    end

    describe '#date_range' do
      it 'returns February 1st - June 31st in standard US format' do
        expect(open_access_report_email.send(:date_range)).to eq "02/01/#{this_year} - 06/30/#{this_year}"
      end
    end
  end

  context 'when Summer semester' do
    let!(:within_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("07/31/#{this_year}", "%m/%d/%Y")
    end
    let!(:outside_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("02/01/#{this_year}", "%m/%d/%Y")
    end

    before do
      allow(Date).to receive(:today).and_return Date.strptime("09/30/#{this_year}", "%m/%d/%Y")
    end

    describe '#submissions' do
      it 'includes open_access publications released during Spring semester' do
        expect(open_access_report_email.send(:submissions)).to eq [within_submission]
      end
    end

    describe '#date_range' do
      it 'returns July 1st - September 31st in standard US format' do
        expect(open_access_report_email.send(:date_range)).to eq "07/01/#{this_year} - 09/30/#{this_year}"
      end
    end
  end

  context 'when Fall semester' do
    let!(:within_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("11/02/#{this_year}", "%m/%d/%Y")
    end
    let!(:within_submission2) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("01/02/#{this_year + 1}", "%m/%d/%Y")
    end
    let!(:outside_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("07/01/#{this_year}", "%m/%d/%Y")
    end

    before do
      allow(Date).to receive(:today).and_return Date.strptime("01/31/#{this_year + 1}", "%m/%d/%Y")
    end

    describe '#submissions' do
      it 'includes open_access publications released during Spring semester' do
        expect(open_access_report_email.send(:submissions)).to eq [within_submission, within_submission2]
      end
    end

    describe '#date_range' do
      it 'returns October 1st - January 31st in standard US format' do
        expect(open_access_report_email.send(:date_range)).to eq "10/01/#{this_year} - 01/31/#{this_year + 1}"
      end
    end
  end
end

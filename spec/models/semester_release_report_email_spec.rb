require 'model_spec_helper'

RSpec.describe SemesterReleaseReportEmail do
  subject(:semester_release_report_email) { described_class.new }

  let(:this_year) { Date.today.year }

  describe '#deliver' do
    it 'delivers an email' do
      expect { semester_release_report_email.deliver }.to change { WorkflowMailer.deliveries.count }.by 1
    end
  end

  describe '#csv' do
    let!(:submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("03/01/#{this_year}", "%m/%d/%Y")
    end
    let!(:submission2) do
      FactoryBot.create :submission, :final_is_restricted,
                        released_metadata_at: DateTime.strptime("04/10/#{this_year}", "%m/%d/%Y")
    end
    let!(:submission3) do
      FactoryBot.create :submission, :final_is_restricted_to_institution,
                        released_metadata_at: DateTime.strptime("04/10/#{this_year - 2}", "%m/%d/%Y"),
                        released_for_publication_at: DateTime.strptime("04/10/#{this_year}", "%m/%d/%Y")
    end
    let(:csv) do
      "Last Name,First Name,Title,Degree Type,Graduation Semester,Released On,Access Level\n#{submission.author.last_name},#{submission.author.first_name},#{submission.title},#{submission.degree.degree_type.name},#{submission.preferred_semester} #{submission.preferred_year},#{submission.released_for_publication_at.strftime('%D')},#{submission.access_level}\n#{submission2.author.last_name},#{submission2.author.first_name},#{submission2.title},#{submission2.degree.degree_type.name},#{submission2.preferred_semester} #{submission2.preferred_year},#{submission2.released_metadata_at.strftime('%D')},#{submission2.access_level}\n"
    end

    before do
      allow(Date).to receive(:today).and_return Date.strptime("06/30/#{this_year}", "%m/%d/%Y")
      allow(Semester).to receive(:today).and_return Date.strptime("06/30/#{this_year}", "%m/%d/%Y")
    end

    it 'generates a csv from queried submissions (submission3 should be excluded)' do
      expect(semester_release_report_email.send(:csv)).to eq csv
    end
  end

  context 'when currently Summer semester' do
    let!(:within_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("03/01/#{this_year}", "%m/%d/%Y")
    end
    let!(:within_submission2) do
      FactoryBot.create :submission, :final_is_restricted,
                        released_metadata_at: DateTime.strptime("03/01/#{this_year}", "%m/%d/%Y")
    end
    let!(:outside_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("09/01/#{this_year}", "%m/%d/%Y")
    end
    let!(:outside_submission2) do
      FactoryBot.create :submission, :final_is_restricted,
                        released_metadata_at: DateTime.strptime("09/01/#{this_year}", "%m/%d/%Y")
    end

    before do
      allow(Date).to receive(:today).and_return Date.strptime("06/30/#{this_year}", "%m/%d/%Y")
      allow(Semester).to receive(:today).and_return Date.strptime("06/30/#{this_year}", "%m/%d/%Y")
    end

    describe '#submissions' do
      it 'includes all publications released during Spring semester' do
        expect(semester_release_report_email.send(:submissions)).to eq [within_submission, within_submission2]
      end
    end

    describe '#date_range' do
      it 'returns February 1st - June 31st in standard US format' do
        expect(semester_release_report_email.send(:date_range)).to eq "02/01/#{this_year} - 06/30/#{this_year}"
      end
    end

    describe '#filename' do
      it 'returns ETD_SPRING_RELEASE_REPORT.csv' do
        expect(semester_release_report_email.send(:filename)).to eq "ETD_#{this_year}SPRING_RELEASE_REPORT.csv"
      end
    end
  end

  context 'when currently Fall semester' do
    let!(:within_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("07/31/#{this_year}", "%m/%d/%Y")
    end
    let!(:within_submission2) do
      FactoryBot.create :submission, :final_is_restricted_to_institution,
                        released_metadata_at: DateTime.strptime("07/31/#{this_year}", "%m/%d/%Y")
    end
    let!(:outside_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("02/01/#{this_year}", "%m/%d/%Y")
    end
    let!(:outside_submission2) do
      FactoryBot.create :submission, :final_is_restricted_to_institution,
                        released_metadata_at: DateTime.strptime("02/01/#{this_year}", "%m/%d/%Y")
    end

    before do
      allow(Date).to receive(:today).and_return Date.strptime("08/30/#{this_year}", "%m/%d/%Y")
      allow(Semester).to receive(:today).and_return Date.strptime("08/30/#{this_year}", "%m/%d/%Y")
    end

    describe '#submissions' do
      it 'includes all publications released during Spring semester' do
        expect(semester_release_report_email.send(:submissions)).to eq [within_submission, within_submission2]
      end
    end

    describe '#date_range' do
      it 'returns June 1st - August 30th in standard US format' do
        expect(semester_release_report_email.send(:date_range)).to eq "06/01/#{this_year} - 08/30/#{this_year}"
      end
    end

    describe '#filename' do
      it 'returns ETD_SUMMER_RELEASE_REPORT.csv' do
        expect(semester_release_report_email.send(:filename)).to eq "ETD_#{this_year}SUMMER_RELEASE_REPORT.csv"
      end
    end
  end

  context 'when currently Spring semester' do
    let!(:within_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("11/02/#{this_year - 1}", "%m/%d/%Y")
    end
    let!(:within_submission2) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("01/02/#{this_year}", "%m/%d/%Y")
    end
    let!(:outside_submission) do
      FactoryBot.create :submission, :released_for_publication,
                        access_level: 'open_access',
                        released_for_publication_at: DateTime.strptime("07/01/#{this_year - 1}", "%m/%d/%Y")
    end
    let!(:outside_submission2) do
      FactoryBot.create :submission, :final_is_restricted_to_institution,
                        released_metadata_at: DateTime.strptime("02/01/#{this_year}", "%m/%d/%Y")
    end

    before do
      allow(Date).to receive(:today).and_return Date.strptime("01/31/#{this_year}", "%m/%d/%Y")
      allow(Semester).to receive(:today).and_return Date.strptime("01/31/#{this_year}", "%m/%d/%Y")
    end

    describe '#submissions' do
      it 'includes all publications released during Spring semester' do
        expect(semester_release_report_email.send(:submissions)).to eq [within_submission, within_submission2]
      end
    end

    describe '#date_range' do
      it 'returns September 1st - January 31st in standard US format' do
        expect(semester_release_report_email.send(:date_range)).to eq "09/01/#{this_year - 1} - 01/31/#{this_year}"
      end
    end

    describe '#filename' do
      it 'returns ETD_FALL_RELEASE_REPORT.csv' do
        expect(semester_release_report_email.send(:filename)).to eq "ETD_#{this_year - 1}FALL_RELEASE_REPORT.csv"
      end
    end
  end
end

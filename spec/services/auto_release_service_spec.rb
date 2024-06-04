# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe AutoReleaseService do
  describe '#release' do
    let!(:sub1) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.days_ago(1),
                        released_metadata_at: Time.zone.today.years_ago(2),
                        access_level: 'restricted'
    end
    let!(:sub2) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.days_ago(1),
                        released_metadata_at: Time.zone.today.years_ago(1),
                        access_level: 'restricted'
    end
    let!(:sub3) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.days_ago(1),
                        released_metadata_at: Time.zone.today.years_ago(2),
                        access_level: 'restricted'
    end

    before { allow(Submission).to receive(:release_for_publication).with([sub1.id, sub3.id], DateTime.now.end_of_day, 'Release as Open Access') }

    it 'sends eligible submissions for release to publication' do
      described_class.new.release
      expect(Submission).to have_received(:release_for_publication).with([sub1.id, sub3.id], DateTime.now.end_of_day, 'Release as Open Access')
    end
  end

  describe '#notify_author' do
    let!(:sub1) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.next_month,
                        released_metadata_at: Time.zone.today.years_ago(1)
      end
    let!(:sub2) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.next_month,
                        released_metadata_at: Time.zone.today.years_ago(1),
                        author_release_warning_sent_at: Time.zone.today.last_week
    end
    let!(:sub3) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.next_week,
                        released_metadata_at: Time.zone.today.years_ago(1)
    end

    before { allow(WorkflowMailer).to receive(:author_release_warning)}

    it 'calls the release warning mailer on eligible submissions' do
      described_class.new.notify_author
      expect(WorkflowMailer).to have_received(:author_release_warning).with(sub1)
      expect(WorkflowMailer).not_to have_received(:author_release_warning).with(sub2)
      expect(WorkflowMailer).to have_received(:author_release_warning).with(sub3)
    end
  end
end

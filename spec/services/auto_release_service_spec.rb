# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe AutoReleaseService do
  describe '#release' do
    let!(:sub1) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.days_ago(1),
                        access_level: 'restricted_to_institution'
    end
    let!(:sub2) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.next_week,
                        access_level: 'restricted_to_institution'
    end
    let!(:sub3) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.days_ago(1),
                        access_level: 'restricted_to_institution'
    end
    let!(:sub4) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.days_ago(1),
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
                        released_metadata_at: Time.zone.today.years_ago(1),
                        author_release_warning_sent_at: nil,
                        access_level: 'restricted_to_institution'
    end
    let!(:sub2) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.next_month,
                        released_metadata_at: Time.zone.today.years_ago(1),
                        author_release_warning_sent_at: one_week_ago,
                        access_level: 'restricted_to_institution'
    end
    let!(:sub3) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.next_week,
                        released_metadata_at: Time.zone.today.years_ago(1),
                        author_release_warning_sent_at: nil,
                        access_level: 'restricted_to_institution'
    end
    let!(:sub4) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.next_month,
                        released_metadata_at: Time.zone.today.years_ago(1),
                        author_release_warning_sent_at: nil,
                        access_level: 'restricted'
    end
    let(:one_week_ago) { Time.zone.today.end_of_day.last_week }

    before { allow(WorkflowMailer).to receive(:send_author_release_warning) }

    it 'calls the release warning mailer on eligible submissions' do
      expect(sub1.extension_token).to be_nil
      expect(sub3.extension_token).to be_nil
      described_class.new.notify_author
      expect(WorkflowMailer).to have_received(:send_author_release_warning).with(sub1)
      expect(WorkflowMailer).not_to have_received(:send_author_release_warning).with(sub2)
      expect(WorkflowMailer).to have_received(:send_author_release_warning).with(sub3)

      sub1.reload
      sub2.reload
      sub3.reload

      expect(sub1.author_release_warning_sent_at).to be_within(1.minute).of(Time.zone.now)
      expect(sub1.extension_token).not_to be_nil
      expect(sub2.author_release_warning_sent_at).to eq(one_week_ago)
      expect(sub3.author_release_warning_sent_at).to be_within(1.minute).of(Time.zone.now)
      expect(sub3.extension_token).not_to be_nil
    end
  end
end

class SubmissionReleaseService
  def initialize
    @error_message = I18n.t('released_message.base_error')
    @error_count = 0
  end

  def publish(submission_ids, date_to_release)
    submission_ids.each do |id|
      publish_a_submission(id, date_to_release)
    end
    final_results(submission_ids.count)
  end

  private

    def publish_a_submission(id, date_to_release)
      s = Submission.find(id)
      new_publication_release_date = s.publication_release_date date_to_release
      new_metadata_release_date = s.released_metadata_at.nil? ? date_to_release : s.released_metadata_at
      new_access_level = s.publication_release_access_level
      new_public_id = s.public_id.presence || PublicIdMinter.new(s).id
      if new_public_id.present?
        status_giver = SubmissionStatusGiver.new(s)
        status_giver.can_release_for_publication?
        new_access_level == 'restricted' ? status_giver.released_for_publication_metadata_only! : status_giver.released_for_publication!
        s.update_attributes(released_for_publication_at: new_publication_release_date, released_metadata_at: new_metadata_release_date, access_level: new_access_level, public_id: new_public_id)
        # UpdateSubmissionService.new.call(s, date_params)
        OutboundLionPathRecord.new(submission: s).report_status_change
        # Archiver.new(s).create!
      else
        @error_message += I18n.t('released_message.submission_error', id: s.id, last_name: s.author.last_name, first_name: s.author.first_name).to_s
        @error_count += 1
      end
    end

    def final_results(total_submissions)
      released_total = total_submissions - @error_count
      plural_txt = released_total.positive? ? released_total.to_s : 'No'
      result_message = I18n.t('released_message.success', released_count: plural_txt, submissions: 'submission'.pluralize(released_total))
      result_message += @error_message unless @error_count.zero?
      result_message
    end
end

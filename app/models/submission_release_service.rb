class SubmissionReleaseService
  attr_accessor :new_access_level
  attr_accessor :previous_access_level

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

  def unpublish(original_final_files)
    release_files(original_final_files)
  end

  def final_files_for_submission(s)
    # saves the file id and the original file path
    location_array = []
    s.final_submission_files.each do |f|
      location_array << [f.id, f.current_location]
    end
    location_array
  end

  private

    def publish_a_submission(id, date_to_release)
      s = Submission.find(id)
      original_final_files = final_files_for_submission(s)
      new_publication_release_date = s.publication_release_date date_to_release
      new_metadata_release_date = s.released_metadata_at.nil? ? date_to_release : s.released_metadata_at
      new_access_level = s.publication_release_access_level
      new_public_id = s.public_id.presence || PublicIdMinter.new(s).id
      if new_public_id.present?
        status_giver = SubmissionStatusGiver.new(s)
        status_giver.can_release_for_publication?
        new_access_level == 'restricted' ? status_giver.released_for_publication_metadata_only! : status_giver.released_for_publication!
        s.update_attributes(released_for_publication_at: new_publication_release_date, released_metadata_at: new_metadata_release_date, access_level: new_access_level, public_id: new_public_id)

        release_files(original_final_files)
        UpdateSubmissionService.call(s)
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

    def release_files(original_file_locations)
      original_file_locations.each do |fid, original_file_location|
        EtdaFilePaths.new.move_a_file(fid, original_file_location)
        # updated_file = FinalSubmissionFile.find(fid)
        #
        # # this is calculating the new location based on updated submission and file attributes
        # new_location = updated_file.new_location_path
        #
        # # create file path if it doesn't exist
        # FileUtils.mkpath(new_location)
        #
        # # file path + file name
        # new_file_location = new_location + updated_file.asset_identifier
        # FileUtils.mv(original_file_location, new_file_location) unless new_file_location == original_file_location

        # move to explore/open_access if new_access_level == 'open_access'
        # move to explore/psu_only if new_access_level == 'restricted_to_institution'
        # move to workflow/restricted if new_access_level == 'restricted'
      end
    end
end

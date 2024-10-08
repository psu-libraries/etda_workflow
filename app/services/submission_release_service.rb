# Release submissions for publication
class SubmissionReleaseService
  attr_accessor :new_access_level

  def initialize
    @error_message = []
    @error_count = 0
    @released_submissions = 0
  end

  def publish(submission_ids, date_to_release, release_type)
    submission_ids.each do |id|
      submission = Submission.find(id)
      original_final_files = final_files_for_submission(submission)
      file_verification_results = file_verification(original_final_files)
      return ['File not found.', file_verification_results[:file_error_list]] unless file_verification_results[:valid]

      case release_type
      when 'Release selected for publication'
        publish_a_submission(submission, date_to_release, original_final_files)
      when 'Release as Open Access'
        update_restricted_submission_to_open_access(submission, date_to_release, original_final_files)
      end
      SolrDataImportService.new.index_submission(submission, true)
    end
    final_results(submission_ids.count)
  end

  def unpublish(original_final_files)
    release_files(original_final_files)
  end

  def final_files_for_submission(submission)
    # saves the file id and the original file path
    location_array = []
    submission.final_submission_files.each do |f|
      location_array << [f.id, f.current_location]
    end
    location_array
  end

  def release_files(original_file_locations)
    etda_file_util = EtdaFilePaths.new
    original_file_locations.each do |fid, original_file_location|
      msg = etda_file_util.move_a_file(fid, original_file_location)
      next if msg.blank?

      record_error(msg)
      return false
    end
    true
  end

  def file_verification(original_files_array)
    file_error_list = []
    original_files_array.each do |id, original_file|
      next if File.exist? original_file

      err = "File Not Found for Final Submission File #{id}, #{original_file} "
      record_error(err)
      file_error_list << err
    end
    { valid: file_error_list.empty? ? true : false, file_error_list: }
  end

  private

    def publish_a_submission(submission, date_to_release, original_final_files)
      publication_release_date = submission.publication_release_date date_to_release
      metadata_release_date = submission.released_metadata_at.nil? ? date_to_release : submission.released_metadata_at
      public_id = submission.public_id.presence || PublicIdMinter.new(submission).id
      return unless public_id_ok(public_id)

      status_giver = SubmissionStatusGiver.new(submission)
      status_giver.can_release_for_publication?
      if submission.restricted? || submission.restricted_to_institution?
        status_giver.released_for_publication_metadata_only!
      else
        status_giver.released_for_publication!
      end
      submission.update!(released_for_publication_at: publication_release_date, released_metadata_at: metadata_release_date, public_id:)
      WorkflowMailer.send_publication_release_messages(submission)
      return unless release_files(original_final_files)

      @released_submissions += 1
      # Archiver.new(s).create!
    rescue StandardError => e
      record_error("Error occurred processing submission id: #{submission.id}, #{submission.author.last_name}, #{submission.author.first_name}, #{e}")
    end

    def update_restricted_submission_to_open_access(submission, date_to_release, original_final_files)
      update_service = UpdateSubmissionService.new
      new_publication_release_date = date_to_release
      new_metadata_release_date = submission.released_metadata_at.nil? ? date_to_release : submission.released_metadata_at
      original_access_level = submission.access_level
      new_access_level = submission.publication_release_access_level
      new_public_id = submission.public_id.presence || PublicIdMinter.new(submission).id
      return unless public_id_ok(new_public_id)

      return if new_access_level == 'restricted' || new_access_level == 'restricted to institution'

      status_giver = SubmissionStatusGiver.new(submission)
      status_giver.can_release_for_publication?
      status_giver.released_for_publication!
      submission.update!(released_for_publication_at: new_publication_release_date, released_metadata_at: new_metadata_release_date, access_level: new_access_level, public_id: new_public_id)
      return unless release_files(original_final_files)

      update_service.send_email(submission, original_access_level)
      @released_submissions += 1
      # Archiver.new(s).create!
    rescue StandardError => e
      record_error("Error occurred processing submission id: #{submission.id}, #{submission.author.last_name}, #{submission.author.first_name}, #{e}")
    end

    def final_results(total_submissions)
      released_total = total_submissions - @error_count
      plural_txt = released_total.positive? ? released_total.to_s : 'No'
      result_message = I18n.t('released_message.success', released_count: plural_txt, submissions: 'submission'.pluralize(released_total))
      @error_message = '' unless @error_count.positive?
      [result_message, @error_message]
    end

    def public_id_ok(new_public_id)
      return true if new_public_id.present?

      record_error("Public ID error#{I18n.t('released_message.submission_error', id: s.id, last_name: s.author.last_name, first_name: s.author.first_name)}")
      false
    end

    def record_error(message)
      Rails.logger.error("#{Time.zone.now}Final Submission release-unrelease error:#{message}")
      Bugsnag.notify("#{Time.zone.now}Final Submission release-unrelease error:#{message}")
      @error_message << message
      @error_count += 1
    end
end

class Legacy::FileImporter
  def initialize
    @display_logger = Logger.new(STDOUT)
    @import_logger = Logger.new(STDOUT)
    @original_count = 0
    @files_copied = 0
    @missing_file_name = 0
  end

  def copy_format_review_files(source_file_path, skip_verification)
    # copies entire directory structure
    path_builder = EtdaFilePaths.new
    source_path = SourcePath.new('format_review_files', source_file_path)
    if total_file_count(path_builder.workflow_upload_format_review_path).positive?
      @import_logger.info "Quitting -- Destination directory (#{path_builder.workflow_upload_format_review_path} is not empty"
      abort('Destination directories must be empty to import files.')
    end
    @original_count = total_file_count(source_path.base)
    record_message "Original Count - Number of Format Review Files in #{source_path.base} : #{@original_count}"
    begin
       FileUtils.mkdir_p path_builder.workflow_upload_format_review_path
       if skip_verification
         @import_logger.info "Copying files"
         FileUtils.copy_entry(source_path.base, path_builder.workflow_upload_format_review_path, :noop)
       else
         @import_logger.info "Rsync files"
         cmd = "rsync -vacx #{source_path.base} #{path_builder.workflow_upload_format_review_path}"
         record_message "Executing command - #{cmd}"
         system cmd.to_s
       end
       @files_copied = total_file_count(path_builder.workflow_upload_format_review_path)
       record_message "FORMAT REVIEW -- Original Count:  #{@original_count}"
       record_message "Total of #{@files_copied} files were copied.  See logs for more information"
       @display_logger.info "See logs for more information"
    rescue StandardError
       @import_logger.log("Quitting: Error occurred")
     end
  end

  def copy_final_submission_files(source_file_path, skip_verification)
    # copies each file using access_level and status to determine the correct destination path
    path_builder = EtdaFilePaths.new
    source_path = SourcePath.new('final_submission_files', source_file_path)
    if destination_files_exist?('final_submission_files') && !Rails.env.test?
      @import_logger.info "Quitting -- Destination directories for final submission files are not empty"
      abort('Destination directories must be empty')
    end
    @original_count = total_file_count(source_path.base)
    record_message "Original Count - Number of Final Submission Files in #{source_path.base} : #{@original_count}"
    begin
      FinalSubmissionFile.find_each do |final_file|
        submission = Submission.find(final_file.submission_id)
        if submission.nil?
          @import_logger.info "Submission with id = #{final_file.submission_id} missing for Final Submission File with id = #{final_file.id}"
        else
          file_detail_path = path_builder.detailed_file_path(final_file.id)
          source_full_path = source_path.base + file_detail_path
          destination_path = SubmissionFilePath.new(submission)
          copy_the_file(source_full_path, destination_path.full_path_for_final_submissions + file_detail_path, final_file.asset_identifier, skip_verification) if verify_the_file(source_full_path, final_file.asset_identifier)
        end
      end
      record_message "FINAL SUBMISSION -- Original Count: #{@original_count}"
      record_message "Total of #{@files_copied} files were copied. See logs for more information"
      record_message "Missing files count #{@missing_file_name}"
    rescue StandardError
        record_message 'Quitting: error occurred'
        abort
    end
  end

  def copy_the_file(source_path, destination_path, file_name, skip_verification)
    files_ok = true
    FileUtils.mkdir_p destination_path
    original_checksum = build_checksum(source_path, file_name) unless skip_verification
    FileUtils.copy_entry(File.join(source_path, file_name), File.join(destination_path, file_name), :preserve, :noop)
    new_checksum = build_checksum(destination_path, file_name) unless skip_verification
    files_ok = verify_checksums(original_checksum, new_checksum) unless skip_verification
    @files_copied += 1 if files_ok
  end

  def total_file_count(file_directory)
    count = Dir.glob(File.join(file_directory, '**', '*')).select { |file| File.file?(file) }.count
    count
  end

  def destination_files_exist?(file_type)
    path_builder = EtdaFilePaths.new
    return total_file_count(path_builder.workflow_upload_format_review_path).positive? if file_type == 'format_review_files'

    total_file_count(path_builder.workflow_upload_final_files_path).positive? || total_file_count(path_builder.explore_base_path).positive?
    # || total_file_count(path_builder.explore_base_path).positive?
  end

  def verify_checksums(original_checksum, new_checksum)
    result = original_checksum.hexdigest.eql? new_checksum.hexdigest
    original_checksum.reset
    new_checksum.reset
    result
  end

  def verify_the_file(source_path, filename)
    if filename.empty?
      @import_logger.info "Database record has missing file name for path #{source_path}"
      @missing_file_name += 1
      return false
    end
    unless File.exist?(File.join(source_path, filename))
      record_message "Legacy file not found: #{source_path}#{filename}"
      return false
    end
    true
  end

  def build_checksum(file_path, filename)
      Digest::MD5.new.file(File.join(file_path, filename))
  rescue Errno::ENOENT => e
      @import_logger.info e.message.to_s
      msg = "File not found when building checksum:  #{file_path}/#{filename}"
      record_message msg
      false
  end

  def record_message(msg)
    @display_logger.info msg
    @import_logger.info msg
  end
end
# production source path base will look like this:   /legacy_prod/etda-graduate/  or /legacy-qa/etda-honors/  or /legacy-stage/etda-milsch/, etc.
# development & test source path base is the source_path parameter w/o changes
class SourcePath
  def initialize(file_type, source_path)
    @file_type = file_type
    @source_path = source_path.last != '/' ? source_path + '/' : source_path
  end

  def base
    file_base_path = @source_path unless Rails.env.production?
    file_base_path = "/legacy_#{@source_path}etda-#{current_partner.id}/" if Rails.env.production?
    file_base_path + @file_type + '/'
  end
end

class Legacy::FileImporter
  def initialize
    @display_logger = Logger.new(STDOUT)
    @import_logger = Logger.new("log/#{current_partner.id}_file_import.log")
    @original_count = 0
    @files_copied = 0
  end

  def copy_format_review_files(source_file_path)
    # copies entire directory structure
    path_builder = EtdaFilePaths.new
    source_path = SourcePath.new('format_review_files', source_file_path)

    if file_count(path_builder.workflow_upload_format_review_path).positive?
      @import_logger.info "Quitting -- Destination directory (#{path_builder.workflow_upload_format_review_path} is not empty"
      abort('Destination directories must be empty to import files.')
    end
    @original_count = file_count(source_path.base)
    @import_logger.info "Original Count - Number of Format Review Files in #{source_path.base} : #{@original_count}"
    begin
      FileUtils.mkdir_p path_builder.workflow_upload_format_review_path
      FileUtils.copy_entry(source_path.base, path_builder.workflow_upload_format_review_path, :noop)
      @files_copied = file_count(path_builder.workflow_upload_format_review_path)
      @import_logger.info "New Count - Number of Format Review Files in #{path_builder.workflow_upload_format_review_path} : #{@files_copied}"
      @display_logger.info "Total of #{@files_copied} files were copied.  See logs for more information"
    rescue StandardError
      @import_logger.log("Quitting: Error occurred")
    end
  end

  def copy_final_submission_files(source_file_path)
    # copies each file using access_level and status to determine the correct destination path
    path_builder = EtdaFilePaths.new
    source_path = SourcePath.new('final_submission_files', source_file_path)
    @original_count = FinalSubmissionFile.all.count
    if destination_files_exist?('final_submission_files') && !Rails.env.test?
      @import_logger.info "Quitting -- Destination directories for final submission files are not empty"
      abort('Destination directories must be empty')
    end
    begin
      FinalSubmissionFile.find_each do |final_file|
        submission = Submission.find(final_file.submission_id)
        if submission.nil?
          @import_logger.info "Submission with id = #{final_file.submission_id} missing for Final Submission File with id = #{final_file.id}"
        else
          file_detail_path = path_builder.detailed_file_path(final_file.id)
          source_full_path = source_path.base + file_detail_path
          destination_path = SubmissionFilePath.new(submission)
          copy_the_file(source_full_path, destination_path.full_path_for_final_submissions + file_detail_path, final_file.asset_identifier)
        end
      end
      @display_logger.info "Total of #{@files_copied} files were copied. See logs for more information"
      @import_logger.info "Original File Count: #{@original_count} : Final file Count #{@files_copied}"
    rescue StandardError
        @import_logger.log('Quitting: error occurred')
    end
  end

  def copy_the_file(source_path, destination_path, file_name)
    if file_name.nil?
      @import_logger.info 'missing file name'
    elsif File.exist?(File.join(source_path, file_name))
      FileUtils.mkdir_p destination_path
      FileUtils.copy_entry(File.join(source_path, file_name), File.join(destination_path, file_name), :preserve, :noop)
      @files_copied += 1
    else
      @import_logger.info "File not found: #{source_path}#{file_name}"
      @display_logger.info "File not found: #{source_path}#{file_name}"
    end
  end

  def file_count(file_directory)
    count = Dir.glob(File.join(file_directory, '**', '*')).select { |file| File.file?(file) }.count
    count
  end

  def destination_files_exist?(file_type)
    path_builder = EtdaFilePaths.new
    return file_count(path_builder.workflow_upload_format_review_path).positive? if file_type == 'format_review_files'

    file_count(path_builder.workflow_upload_final_files_path).positive? || file_count(path_builder.explore_base_path).positive?
    # || file_count(path_builder.explore_base_path).positive?
  end
end

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

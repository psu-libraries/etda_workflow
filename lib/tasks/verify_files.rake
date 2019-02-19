namespace :final_files do

  desc "Verify final submission files exist in the correct directory."
  task verify: :environment do

    open_log_file
    file_count = 0
    misplaced_files_count = 0

    FinalSubmissionFile.all.each do |f|
      file_count += 1
      submission_id = ''
      next if File.exist? f.current_location
      misplaced_files_count += 1
      matching_file_found = locate_file(f)
      next if matching_file_found.nil?
      possible_file_match = validate_file_path(matching_file_found, f)
      next if possible_file_match.nil?
    end
    send_notification(@verify_file_report, misplaced_files_count)
    close_log_file(file_count, misplaced_files_count)
    exit
  end

  def locate_file(f)
    return find_file(f) unless f.asset_identifier.nil?
    log_it("No file name (asset identifier) for FinalSubmissionFile ID:  #{f.id}, submission_id #{f.submission_id}")
    nil
  end

  def workflow_search(file_name)
    WORKFLOW_BASE_PATH+"**/#{file_name}"
  end

  def explore_search(file_name)
    EXPLORE_BASE_PATH+"**/#{file_name}"
  end

  def find_file(f)
    search_result = Dir.glob([explore_search(f.asset_identifier), workflow_search(f.asset_identifier)])
    log_it("No file found in explore or workflow directories for - #{f.asset_identifier}, file id: #{f.id}, submission_id: #{f.submission_id}") if search_result.empty?
    return nil if search_result.empty?
    search_result
  end

  def validate_file_path(search_result, f)
    search_result.each do |full_file_path|
      log_it("Possible match for file found at #{full_file_path}, file id: #{f.id}, submission: #{f.submission_id}")
      return full_file_path if full_file_path.include? f.file_detail_path
    end
    log_it("Cannot verify correct file has been located:  matching detail file path (#{f.file_detail_path}) not found for file #{f.asset_identifier}, file id: #{f.id}, submission: #{f.submission_id} search located: #{search_result}")
    nil
  end

  def open_log_file
    file_report_name = "#{Rails.root}/log/etda_file_report_#{Date.today.to_s}.log"
    @verify_file_report = File.open(file_report_name, 'w+')
    log_it("File Verification for ETDA #{Time.zone.now.to_s}\n")
    puts "Created report - #{file_report_name}"
  end

  def close_log_file(file_count, misplaced_files_count)
    log_it("Final Submission Files in database: #{file_count}")
    log_it("Missing and/or misplaced file count: #{misplaced_files_count}")
    @verify_file_report.close
  end

  def log_it(msg)
    puts msg
    @verify_file_report.write msg + "\n"
  end

  def send_notification(results, misplaced_files_count)
    WorkflowMailer.verify_files_email(results.read).deliver_now unless misplaced_files_count == 0
  end
end
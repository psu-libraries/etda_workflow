namespace :verify do

  desc "Verify final submission files exist in the correct directory."
  task files: :environment do
    FinalSubmissionFile.all.each do |f|
      unless File.exist?(f.current_location)
        Rails.logger.error("File ID: #{f.id} at #{f.current_location} is missing")
      end
    end
  end
end

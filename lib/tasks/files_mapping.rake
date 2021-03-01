namespace :final_files do

  desc 'Migrate redis db to keys with namespaces identified'
  task path_map: :environment do
    mapped_array = [['File Path', 'Submission ID']]
    file_name = 'path_map.csv'
    FinalSubmissionFile.joins(:submission).where('submissions.access_level = ?', 'open_access').each do |file|
      mapped_array << [file.current_location, file.submission_id.to_s]
    end
    csv = CSV.generate do |s|
      mapped_array.each do |line|
        s << line
      end
    end
    File.write(file_name, csv)
    `mv #{file_name} ~/#{file_name}`
  end
end

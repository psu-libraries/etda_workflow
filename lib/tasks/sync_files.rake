namespace :sync_files do
  namespace :copy do
    desc 'Create empty files using information in database (supply file directory for output)'
    task 'empty_files', [:my_file_directory] => :environment do |task, args|
      puts "Creating files; this may take a while'"
      f=exclusionfile
    end
  end
  def exclusionfile()
    target="tmp/rsyncskips.txt"
    f=File.open(target, "w+")
    Submission.where(access_level: 'restricted').each do |s|
      s.final_submission_files.each do |finalfile|
        unless finalfile.nil?
          f.puts(finalfile.current_location)
        end
      end
    end
    f
  end
  # TODO: prevent on production
end
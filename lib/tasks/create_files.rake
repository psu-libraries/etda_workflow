namespace :etda_files do

  namespace :create do
    desc 'Create empty files using information in database (supply file directory for output)'
    task 'empty_files', [:my_file_directory] => :environment do |task, args|
      puts "Creating files; this may take a while'"
      # output_file_directory = args.extras<<args.my_file_directory
      # abort "Must enter a directory for building files" if output_file_directory.empty?
      Submission.all.each do |s|
        title = s.cleaned_title || 'no title given'
        text = ["#{title}", "#{s.author.last_name}, #{s.author.first_name}"]
        s.format_review_files.each do |frfile|
          unless frfile.nil?
            create_path(frfile.full_file_path, frfile.asset_identifier, text) unless frfile.asset_identifier.nil?
            create_empty_file(frfile.current_location, frfile.asset_identifier, text, frfile.asset.content_type) unless frfile.nil?
          end
        end
        s.final_submission_files.each do |finalfile|
          unless finalfile.nil?
            create_path(finalfile.full_file_path, finalfile.asset_identifier, text) unless finalfile.asset_identifier.nil?
            create_empty_file(finalfile.current_location, finalfile.asset_identifier, text, finalfile.asset.content_type) unless finalfile.nil?
          end
        end
      end
    end
  end

  namespace :empty do
    desc 'Create empty files for restricted submissions'
    task 'restricted' do |task, args|

    end
  end

  def create_path(filepath, filename, filetext)
    #path = filepath[0..filepath.rindex('/')]
    full_path = filepath + filename
    FileUtils.mkdir_p "#{filepath}" unless File.directory? "#{full_path}"
  end

  def create_empty_file(filepath, filename, filetext, content_type)
    if not is_pdf? content_type
      if is_doc? content_type
        Caracal::Document.save "#{filepath}" do |doc|
          doc.p "Title: #{filetext[0]}"
          doc.p "Author: #{filetext[1]}"
          doc.p "File Path: #{filepath}"
        end
      else
        touch filepath unless filepath.nil?
      end
      return
    end
    Prawn::Document.generate("#{filepath}") do
      text "Title: #{filetext[0]}"
      text "Author: #{filetext[1]}"
      text "File Path: #{filepath}"
    end
  end

  def is_pdf? content_type
    content_type == 'application/pdf'
  end

  MS_TYPES = %w(application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/msword application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.openxmlformats-officedocument.wordprocessingml.document)

  def is_doc? content_type
     MS_TYPES.include? content_type
  end
end


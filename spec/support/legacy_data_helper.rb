class LegacyDataHelper
   # populates the asset in FinalSubmissionFile records

   def load_assets(source_path)
     FinalSubmissionFile.all.each do |f|
       path_builder = EtdaFilePaths.new
       file_detail_path = path_builder.detailed_file_path(f.id)
       source_full_path = source_path + file_detail_path
       filename = "FinalSubmissionFile_#{f.id}" + ".pdf"
       f.asset = File.open("#{source_full_path}#{filename}")
       f.save(validate: false)
     end
   end

   def empty_file_directories
     workflow_files = Rails.root.join('tmp/workflow').to_s
     FileUtils.rm_rf Dir.glob(workflow_files) if workflow_files.present?
     explore_files = Rails.root.join('tmp/explore').to_s
     FileUtils.rm_rf Dir.glob(explore_files) if explore_files.present?
   end
end

namespace :workflow do
  namespace :solr do
    # these tasks perform the importing of legacy database and files

    desc "index all submissions"
    task index_all: :environment do
      puts 'starting index'
      Submission.where('status = "released for publication"').each do |submission|
        SolrDataImportService.new.index_submission(submission, false)
      end
      Submission.where('status = "released for publication metadata only"').each do |submission|
        SolrDataImportService.new.index_submission(submission, false)
      end
      puts 'sending commit'
      SolrDataImportService.new.send_commit
    end
  end
end

namespace :workflow do
  namespace :solr do
    # these tasks perform the importing of legacy database and files

    desc "perform solr delta_import"
    task delta_import: :environment do
       result = SolrDataImportService.new.delta_import
       # write to log?
       puts result.inspect
       exit
    end

    desc "perform solr full_import"
    task full_import: :environment do
       result = SolrDataImportService.new.full_import
       # write to log?
       puts result.inspect
       exit
    end
  end
end
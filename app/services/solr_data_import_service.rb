class SolrDataImportService
  def index_submission(submission, commit_to_solr)
    as_solr = SolrSubmission.new(submission).to_solr
    solr.add as_solr
    send_commit if commit_to_solr
  end

  def remove_submission(submission)
    solr.delete_by_id(submission.public_id)
    send_commit
  end

  def send_commit
    solr.commit
  end

  private

    def solr
      @solr ||= RSolr.connect url: solr_url, core: solr_collection
      @solr
    end

    def solr_username
      ENV.fetch('SOLR_USERNAME', nil)
    end

    def solr_password
      ENV.fetch('SOLR_PASSWORD', nil)
    end

    def solr_host
      default_host = if Rails.env.development?
                       'localhost'
                     else
                       EtdUrls.new.explore.gsub(/https?\:\/\//, '')
                     end
      ENV.fetch('SOLR_HOST', default_host)
    end

    def solr_collection
      ENV.fetch('SOLR_COLLECTION', current_core)
    end

    def solr_port
      ENV.fetch('SOLR_PORT', 8983)
    end

    def solr_url
      url = if solr_username && solr_password
              "http://#{solr_username}:#{URI.encode_www_form_component(solr_password)}@#{solr_host}:#{solr_port}/solr/#{solr_collection}"
            else
              "https://#{solr_host}/solr"
            end
      url
    end

    def current_core
      return 'development' if Rails.env.development?

      "#{current_partner.id}_core"
    end
end

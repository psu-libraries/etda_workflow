class SolrDataImportService
  def delta_import
    # https://etda-explore-partner/solr/partner_core/dataimport?wt=json&command=delta-import&clean=false
    # solr.get dataimport, params: delta_import_params
    execute_cmd(delta_import_params)
  end

  def full_import
    # https://etda-explore-partner/solr/partner_core/dataimport?wt=json&command=full-import&clean=true
    # solr.get dataimport, params: full_import_params
    execute_cmd(full_import_params)
  end

  private

    def execute_cmd(params)
      result = solr.get dataimport, params: params
      Rails.logger result
      return result if result[:error]

      solr_status_checker = RSolr.connect url: solr_url, core: solr_collection
      # wait until the process has finished

      processing_is_incomplete = true
      while processing_is_incomplete
        sleep(10.0)
        check_results = solr_status_checker.get dataimport, 'command' => 'status', 'clean' => false
        processing_is_incomplete = solr_is_busy?(check_results)
      end
      if check_results[:error]
        SolrLog.info "ERROR occurred checking solr results: " + check_results
      else
        SolrLog.info check_results
      end
      check_results
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::EADDRNOTAVAIL => e
      Rails.logger.error e.inspect
      SolrLog.info e.inspect unless e.nil?
      SolrLog.info result
      { error: true, "statusMessages" => { "" => "An error occurred! Check the log messages for more information" } }
    end

    def solr
      @solr ||= RSolr.connect url: solr_url, core: solr_collection
      @solr
    end

    def delta_import_params
      { 'command' => 'delta-import', 'clean' => false, :wt => :xml }
    end

    def full_import_params
      { 'command' => 'full-import', 'clean' => true, :wt => :xml }
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
              "http://#{solr_username}:#{URI.encode_www_form_component(solr_password)}@#{solr_host}:#{solr_port}/solr"
            else
              "http://#{solr_host}/solr"
            end
      url
    end

    def dataimport
      "#{solr_collection}/dataimport"
    end

    def current_core
      return 'development' if Rails.env.development?

      "#{current_partner.id}_core"
    end

    def solr_is_busy?(current_result)
      current_result['status'] == 'busy'
    end
end

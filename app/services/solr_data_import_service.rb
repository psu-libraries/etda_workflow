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
      return result if result[:error]

      solr_status_checker = RSolr.connect url: solr_url, core: current_core
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
      @solr ||= RSolr.connect url: solr_url, core: current_core
      @solr
    end

    def delta_import_params
      { 'command' => 'delta-import', 'clean' => false }
    end

    def full_import_params
      { 'command' => 'full-import', 'clean' => true }
    end

    def solr_url
      return 'http://localhost:8983/solr' if Rails.env.development?

      url = EtdUrls.new.explore
      url + '/solr'
    end

    def dataimport
      "#{current_core}/dataimport"
    end

    def current_core
      return 'development' if Rails.env.development?

      "#{current_partner.id}_core"
    end

    def solr_is_busy?(current_result)
      current_result['status'] == 'busy'
    end
end

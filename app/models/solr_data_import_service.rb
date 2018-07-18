class SolrDataImportService
  def delta_import
    #  https://etda-explore-partner/solr/partner_core/dataimport?wt=json&command=delta-import&clean=false
    # response = solr.get dataimport, params: delta_import_params
    response = execute_cmd(delta_import_params)
    response
  end

  def full_import
    #  https://etda-explore-partner/solr/partner_core/dataimport?wt=json&command=full-import&clean=true
    # response = solr.get dataimport, params: full_import_params
    response = execute_cmd(full_import_params)
    response
  end

  private

  def execute_cmd(params)
    result = solr.get dataimport, params: params
    return result if result[:error]

    # wait until the process has finished
    processing_is_not_complete = true
    while processing_is_not_complete
      sleep(10.0)
      processing_results = solr.get dataimport, params: params
      processing_is_not_complete = processing_results["status"] == "busy"
    end
    processing_results
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
    Rails.logger.error e.inspect
    return { error: true, "statusMessages" => { "" => "An error occured!  Check the log messages for more information" } }
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
    url = Rails.application.secrets.webaccess[:vservice].strip
    url.sub! 'workflow', 'explore'
    url.sub! 'http:', 'https:'
    url + '/solr'
  end

  def dataimport
    "#{current_core}/dataimport"
  end

  def current_core
    "#{current_partner.id}_core"
  end
end

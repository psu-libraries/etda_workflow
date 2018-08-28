if defined?(SolrWrapper)
  SolrWrapper.default_instance_options= {
      version: '5.5.5',
      instance_dir: 'solr_instance',
      download_dir: 'tmp',
      port: '8983',
      extra_lib_dir: File.join(File.expand_path("../..", File.dirname(__FILE__)), "solr", "lib")}
  require 'solr_wrapper/rake_task'
  require "net/http"
  require "uri"

  namespace :solr do

    desc 'Configure cores'
    task config: :environment  do
      solr = SolrWrapper.default_instance
      solr.extract_and_configure
      started = solr.started?
      solr.start unless started
      solr.create(name: 'development', dir: File.join(File.expand_path("../..", File.dirname(__FILE__)), "solr", "conf"))
      solr.create(name: 'test', dir: File.join(File.expand_path("../..", File.dirname(__FILE__)), "solr", "conf"))
      if started
        solr.restart #restart so cinfigurations take effect
      else
        solr.stop #stop to leave it in the same state as before the command
      end
    end

    desc 'Configure cores'
    task reconfig: :environment  do
      solr = SolrWrapper.default_instance
      FileUtils.cp_r File.join(File.expand_path("../..", File.dirname(__FILE__)), "solr", "conf", '.'),  File.join(solr.instance_dir, 'server',   'solr','development','conf')
      FileUtils.cp_r File.join(File.expand_path("../..", File.dirname(__FILE__)), "solr", "conf", '.'),  File.join(solr.instance_dir, 'server',   'solr','test','conf')
      solr.restart if solr.started? #restart so cinfigurations take effect
    end

  end
end

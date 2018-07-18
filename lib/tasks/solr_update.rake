namespace :solr do
  # these tasks perform the importing of legacy database and files

  desc "perform solr delta_import"
  task delta_import: :environment do
    solr_cmd_str = solr_command(cmd_type='delta', clean='false')

    # Returning from test environment so that it's not necessary to load solr on travis & locally
    puts "#{solr_cmd_str}" if ENV['CI'] || Rails.env.test?

    # result =  'wget solr_cmd_str'

  end

  desc "perform solr full_import"
  task full_import: :environment do
    solr_cmd_str = solr_command(cmd_type='full', clean='true')

    # Returning from test environment so that it's not necessary to load solr on travis & locally
    puts "#{solr_cmd_str}" if ENV['CI'] || Rails.env.test?

    # result =  'wget solr_cmd_str'

  end

  def solr_url
    url = Rails.application.secrets.webaccess[:vservice].strip
    url.sub! 'workflow', 'explore'
    url.sub! 'http:', 'https:'
    url
  end

  def solr_command(cmd_type, clean)
    cmd = "#{solr_url}/solr/#/#{current_partner.id}_core/dataimport//dataimport?command=#{cmd_type}_import&clean=#{clean}"
    cmd
  end
end

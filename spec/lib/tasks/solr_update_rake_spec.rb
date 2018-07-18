require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe "Rake::Task['workflow:solr:delta_import']", type: :task do

  subject(:task) { Rake::Task['solr:delta_import'] }

  xit 'executes the delta_import command' do
    delta_cmd = "#{test_solr_url}/solr/#/#{current_partner.id}_core/dataimport//dataimport?command=delta_import&clean=false\n"

    expect{task.invoke}.to output("#{delta_cmd}").to_stdout
  end
end

RSpec.describe "Rake::Task['solr:full_import']", type: :task do
  Rails.application.load_tasks

  subject(:task) { Rake::Task['workflow:solr:full_import'] }

  xit 'executes the full_import command' do
    full_cmd = "#{test_solr_url}/solr/#/#{current_partner.id}_core/dataimport//dataimport?command=full_import&clean=true\n"
    expect{task.invoke}.to output("#{full_cmd}").to_stdout
  end
end


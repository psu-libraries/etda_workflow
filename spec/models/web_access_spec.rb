# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe WebAccess, type: :model do
  before do
    allow(Rails.application.secrets).to receive(:webaccess).and_return(vservice: 'https://myapp-workflow.psu.edu')
  end

  it 'has a login_url and no referrer' do
    expect(described_class.new('').login_url).to eql('https://webaccess.psu.edu/?factors=dce.psu.edu&cosign-myapp-workflow.psu.edu&https://myapp-workflow.psu.edu')
  end

  it 'has a login_url with a referrer' do
    expect(described_class.new('https://myapp-workflow.psu.edu/admin').login_url).to eql('https://webaccess.psu.edu/?factors=dce.psu.edu&cosign-myapp-workflow.psu.edu&https://myapp-workflow.psu.edu/admin')
  end

  it 'has a logout_url' do
    expect(described_class.new('').logout_url).to eql('https://webaccess.psu.edu/cgi-bin/logout?myapp-workflow.psu.edu')
  end

  it 'replaces workflow with explore when building URL for non-production servers' do
    # application_url = described_class.new.send('application_url')
    allow_any_instance_of(WebAccess).to receive(:application_url).and_return('https://myapp-workflow-qa.psu.edu')
    expect(described_class.new.explore_base_url).to eql('https://myapp-explore-qa.psu.edu')
  end
  it 'removes workflow when building URL for production servers' do
    application_url = described_class.new.send('application_url')
    expect(application_url).to eq('https://myapp-workflow.psu.edu')
    expect(described_class.new.explore_base_url).to eql('https://myapp.psu.edu')
  end
end

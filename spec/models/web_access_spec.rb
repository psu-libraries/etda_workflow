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

  it 'has an explore base url' do
    application_url = described_class.new.send('application_url')
    expect(application_url).to eq('https://myapp-workflow.psu.edu')
    expect(described_class.new.explore_base_url).to eql('https://myapp-explore.psu.edu')
  end
end

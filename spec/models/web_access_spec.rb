# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe WebAccess, type: :model do
  before do
    allow(Rails.application.secrets).to receive(:webaccess).and_return(vservice: 'https://myapp.psu.edu')
  end

  it 'has a login_url and no referrer' do
    expect(described_class.new('').login_url).to eql('https://webaccess.psu.edu/?factors=dce.psu.edu&cosign-myapp.psu.edu&https://myapp.psu.edu')
  end

  it 'has a login_url with a referrer' do
    expect(described_class.new('https://myapp.psu.edu/admin').login_url).to eql('https://webaccess.psu.edu/?factors=dce.psu.edu&cosign-myapp.psu.edu&https://myapp.psu.edu/admin')
  end

  it 'has a logout_url' do
    expect(described_class.new('').logout_url).to eql('https://webaccess.psu.edu/cgi-bin/logout?myapp.psu.edu')
  end

  it 'has an explore base url' do
    application_url = described_class.new.send('application_url')
    expect(described_class.new.explore_base_url).to eql(application_url.split('-workflow').join)
  end
end

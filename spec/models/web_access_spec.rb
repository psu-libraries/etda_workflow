# frozen_string_literal: true
require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe WebAccess, type: :model do
  before do
    allow(Rails.application.secrets).to receive(:webaccess).and_return(vservice: "ahost.psu.edu", vhost: 'https://myapp.psu.edu')
  end

  it 'has a login_url and no referrer' do
    expect(described_class.new('').login_url).to eql('https://webaccess.psu.edu/?factors=dce.psu.edu&cosign-ahost.psu.edu&https://myapp.psu.edu')
  end

  it 'has a login_url with a referrer' do
    expect(described_class.new('https://myapp.psu.edu/admin').login_url).to eql('https://webaccess.psu.edu/?factors=dce.psu.edu&cosign-ahost.psu.edu&https://myapp.psu.edu/admin')
  end

  it 'has a logout_url' do
    expect(described_class.new('').logout_url).to eql('https://webaccess.psu.edu/cgi-bin/logout?ahost.psu.edu')
  end
end

# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe WebAccess, type: :model do
  it 'has a login_url and no referrer' do
    expect(described_class.new('').login_url).to eql('https://webaccess.psu.edu/?factors=dce.psu.edu&cosign-myapp-workflow.psu.edu&https://myapp-workflow.psu.edu')
  end

  it 'has a login_url with a referrer' do
    expect(described_class.new('https://myapp-workflow.psu.edu/admin').login_url).to eql('https://webaccess.psu.edu/?factors=dce.psu.edu&cosign-myapp-workflow.psu.edu&https://myapp-workflow.psu.edu/admin')
  end

  it 'has a logout_url' do
    expect(described_class.new('').logout_url).to eql('https://webaccess.psu.edu/cgi-bin/logout?myapp-workflow.psu.edu')
  end
end

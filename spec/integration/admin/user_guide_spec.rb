RSpec.describe "Visiting the admin user guide", :honors, type: :integration do
  require 'integration/integration_spec_helper'

  before do
    oidc_authorize_admin
    visit admin_user_guide_path
  end

  it 'has FAQ content' do
    expect(page).to have_content('Frequently Asked Questions')
    expect(page).to have_content('Admins')
    expect(page).to have_content('Authors')
  end

  it 'shows certain content depending on partner' do
    expect(page).to have_content('head of program') if current_partner.graduate?
    expect(page).not_to have_content('head of program') unless current_partner.graduate?
  end
end

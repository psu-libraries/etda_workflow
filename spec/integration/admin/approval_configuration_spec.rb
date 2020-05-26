RSpec.describe "Editing approval configuration", js: true, honors: true, milsch: true do
  require 'integration/integration_spec_helper'

  let!(:degree) { FactoryBot.create(:degree, name: "Doctor of Philosophy", is_active: true) }
  let!(:approval_configuration_1) { FactoryBot.create(:approval_configuration, degree_type: DegreeType.first) }

  let!(:approval_configuration_2) { FactoryBot.create(:approval_configuration, degree_type: DegreeType.second) } if current_partner.graduate?

  before do
    webaccess_authorize_admin
    visit edit_admin_approval_configuration_path(approval_configuration_1)
  end

  it 'has approval configuration content' do
    expect(page).to have_content("Edit #{degree.degree_type.name} Configuration")
    expect(page).to have_content('Help: ')
    expect(page).to have_content('Committee approval method')
    expect(page).to have_content('Rejections permitted*')
    expect(page).not_to have_content('Percentage for approval*')
    expect(page).to have_content('Require approval from head of graduate program?') if current_partner.graduate?
    expect(page).to have_content('Email admins')
    expect(page).to have_content('Email authors')
    expect(page).to have_button('Update Approval Configuration')
    expect(page).to have_link('Cancel')
  end

  it 'changes display depending on committee approval method radio buttons' do
    find('#approval_configuration_use_percentage_true').click
    expect(page).not_to have_content('Rejections permitted*')
    expect(page).to have_content('Percentage for approval*')
  end

  it 'updates changes applied by admin' do
    # select Date.today.year, from: 'approval_configuration_approval_deadline_on_1i'
    # select Date.today.strftime("%B"), from: 'approval_configuration_approval_deadline_on_2i'
    # select Date.today.day, from: 'approval_configuration_approval_deadline_on_3i'
    find('#approval_configuration_use_percentage_true').click
    fill_in 'Percentage for approval*', with: 80
    find('#approval_configuration_head_of_program_is_approving_false').click if current_partner.graduate?
    find('#approval_configuration_email_admins_true').click
    find('#approval_configuration_email_authors_true').click
    click_on 'Update Approval Configuration'
    expect(page).to have_content('Manage Approval Configurations')
    # expect(ApprovalConfiguration.find(approval_configuration.id).approval_deadline_on).to eq Date.today # Determining use case for approval configuration
    expect(ApprovalConfiguration.find(approval_configuration_1.id).use_percentage).to eq true
    expect(ApprovalConfiguration.find(approval_configuration_1.id).configuration_threshold).to eq 80
    expect(ApprovalConfiguration.find(approval_configuration_1.id).head_of_program_is_approving).to eq false if current_partner.graduate?
    expect(ApprovalConfiguration.find(approval_configuration_1.id).email_admins).to eq true
    expect(ApprovalConfiguration.find(approval_configuration_1.id).email_authors).to eq true
  end
end

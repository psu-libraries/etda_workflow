# frozen_string_literal: true

RSpec.describe "Manage Degrees", js: true do
  require 'integration/integration_spec_helper'

  let!(:degree) { FactoryBot.create :degree }
  let!(:degree2) { FactoryBot.create :degree }

  before do
     webaccess_authorize_admin
     visit admin_degrees_path
  end

  it 'has a list of degrees' do
    degree.degree_type_id = DegreeType.default.id
    degree2.degree_type_id = DegreeType.default.id
    expect(page).to have_link(degree.name)
    expect(page).to have_link(degree2.name)
    click_link('New Degree')
    expect(page).to have_button('Create Degree')
    fill_in 'Name', with: 'MArch'
    fill_in 'Description', with: 'Master of Architecture'
    check 'Is active'
    select DegreeType.default.name, from: 'Degree type'
    click_button 'Create Degree'
    expect(page).to have_current_path(admin_degrees_path)
    expect(page).to have_content(degree.name)
    within('tr', text: 'MArch') do
      expect(page).to have_content('Master of Architecture')
      expect(page).to have_content(DegreeType.default.name)
      expect(page).to have_content('Yes')
    end
    expect(page).to have_content('Degree successfully created')
    click_link 'MArch'
    expect(page).to have_content('Edit Degree')
    expect(page).to have_selector("input[value='Master of Architecture']")
    fill_in 'Name', with: 'a new name'
    fill_in 'Description', with: 'NEWDESC'
    uncheck 'Is active'
    select 'Thesis', from: 'Degree type'
    click_button 'Update Degree'
    expect(page).to have_content(degree.name)
    expect(page).to have_content('Degree successfully updated')
    within('tr', text: 'NEWDESC') do
      expect(page).to have_content('a new name')
      expect(page).to have_content('Thesis')
      expect(page).to have_content('No')
    end
    fill_in 'Search records...', with: 'a new name'
    expect(page).not_to have_content(degree.name)
    expect(page).not_to have_content(degree2.name)
    status_str = printf('Showing 1 to %1d of %1d entries', Degree.all.count, Degree.all.count)
    expect(page).to have_content(status_str)
    expect(page).to have_link('Accessibility')
  end
end

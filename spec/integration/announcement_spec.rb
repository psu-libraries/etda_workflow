# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Announcement', :js do
  context 'when show_announcement is false' do
    before do
      Settings.add_source!(
        {
          show_announcement: false,
          announcement: nil
        }
      )
      Settings.reload!
    end

    it 'does not display an announcement on top' do
      visit root_path
      expect(page).to have_no_css '.announcement'
    end
  end

  context 'when show_announcement is nil' do
    before do
      Settings.add_source!(
        {
          show_announcement: nil,
          announcement: nil
        }
      )
      Settings.reload!
    end

    it 'does not display an announcement on top' do
      visit root_path
      expect(page).to have_no_css '.announcement'
    end
  end

  context 'when show_announcement is true' do
    before do
      Settings.add_source!(
        {
          show_announcement: true,
          announcement: {
            message: 'ETDA is for cool kids'
          }
        }
      )
      Settings.reload!
    end

    it 'displays the given announcement' do
      visit root_path
      expect(page).to have_css '.announcement'
      expect(page).to have_content 'ETDA is for cool kids'
    end
  end
end

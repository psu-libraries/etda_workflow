RSpec.describe 'actions that send an email notifying users of an access level update on a submission', js: true do
  require 'integration/integration_spec_helper'

  describe 'updating the access level for an approved final submission' do
    # admin = FactoryBot.create :admin, site_administrator: true, administrator: true

    before do
      webaccess_authorize_admin
      webaccess_authorize_author
    end

    it 'sends an email to the appropriate people with the updated access level information' do
      author = FactoryBot.create :author
      submission = FactoryBot.create :submission, :final_is_restricted, author: author
      start_count = ActionMailer::Base.deliveries.count
      visit admin_submissions_index_path(DegreeType.default, 'final_withheld')
      sleep(3)
      click_button 'Select Visible'
      sleep(3)
      click_button 'Release as Open Access'
      sleep(2)
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 1)
      email_to_address = submission.author.alternate_email_address || submission.author.psu_email_address
      open_email(email_to_address)
      puts current_email.inspect
      expect(current_email.body).to match(/Old Availability - Restricted/i)
      expect(current_email.body).to match(/New Availability - Open Access/i)
      expect(current_email).to have_content submission.year
      expect(current_email).to have_content submission.author_full_name
      expect(current_email).to have_content submission.title
      expect(current_email.subject).to match(/Access Level for your submission has been updated/i)
      expect(current_email.cc).to be_blank
      expect(current_email.from).to eq [current_partner.email_address]
    end
  end

  #   describe 'bulk releasing submissions', js: true do
  #     let(:degree_type_name) { current_partner.graduate? ? 'dissertation' : 'thesis' }
  #     let(:degree_type) { DegreeType.find_by(slug: degree_type_name) }
  #     let!(:submission1) { create :submission, :final_is_restricted }
  #     let!(:author2) { create :author, alternate_email_address: 'alt@gmail.com' }
  #     let!(:submission2) { create :submission, :final_is_restricted }
  #     let(:submission1_email) { open_email(submission1.author.alternate_email_address) }
  #     let(:submission2_email) { open_email(submission2.author.alternate_email_address) }
  #     before do
  #       submission1.degree.update_attributes(degree_type: degree_type)
  #       submission2.degree.update_attributes(degree_type: degree_type)
  #       submission2.update_attributes!(author: author2)
  #       # allow(Partner).to receive(:current).and_return(Partner.new('honors'))
  #       sign_in_as(admin)
  #       visit admin_submissions_index_path(degree_type, 'final_withheld')
  #       within "#final-withheld-index" do
  #         all('input').each do |input|
  #           input.set(true)
  #         end
  #       end
  # #      click_button "Release as Open Access", wait: 5
  #
  #       page.find('.release-btn').trigger('click')
  #     end
  #
  #     it 'sends an email for each submission release with the updated access level information' do
  #       expect(submission1_email.body).to match(/Old Availability - Restricted/i)
  #       expect(submission1_email.body).to match(/New Availability - Open Access/i)
  #       expect(submission1_email).to have_content submission1.year
  #       expect(submission1_email).to have_content submission1.author_full_name
  #       expect(submission1_email).to have_content submission1.title
  #       expect(submission1_email.subject).to match(/Access Level for your submission has been updated/i)
  #       expect(submission1_email.cc).to match_array [AccessLevelUpdatedEmail.otm_email_address, AccessLevelUpdatedEmail.cataloging_email_address]
  #       expect(submission1_email.from).to eq [current_partner.email_address]
  #       open_email(submission2.author.alternate_email_address)
  #       expect(submission2_email.body).to match(/Old Availability - Restricted/i)
  #       expect(submission2_email.body).to match(/New Availability - Open Access/i)
  #       expect(submission2_email).to have_content submission2.year
  #       expect(submission2_email).to have_content submission2.author_full_name
  #       expect(submission2_email).to have_content submission2.title
  #       expect(submission2_email.subject).to match(/Access Level for your submission has been updated/i)
  #       expect(submission2_email.cc).to match_array [AccessLevelUpdatedEmail.otm_email_address, AccessLevelUpdatedEmail.cataloging_email_address]
  #       expect(submission2_email.from).to eq [current_partner.email_address]
  #     end
  #   end
end

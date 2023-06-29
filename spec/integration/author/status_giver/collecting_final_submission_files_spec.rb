RSpec.describe 'Step 5: Collecting Final Submission Files', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'collecting final submission files'" do
    before do
      oidc_authorize_author
    end

    let!(:author) { current_author }
    let!(:submission) { FactoryBot.create :submission, :collecting_final_submission_files, lion_path_degree_code: 'PHD', author:, degree: }
    let!(:committee_members) { create_committee(submission) }
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: false }

    context "visiting the 'Upload Final Submission Files page'" do
      context 'when current_partner is graduate' do
        before do
          skip 'Graduate Only' unless current_partner.graduate?
        end

        context 'when student has not paid their fee' do
          before do
            WebMock.reset!
            stub_request(:get, /https:\/\/secure.gradsch.psu.edu\/services\/etd\/etdPayment.cfm/)
              .to_return(status: 200, body: "\r\n    {\"data\":[{\"ETDPAYMENTFOUND\":\"N\"}],\"error\":\"\"}\r\n    ")
          end

          it 'redirects to the author root page and displays a dialog' do
            visit author_submission_edit_final_submission_path(submission)
            expect(page).to have_current_path(author_root_path)
            dialog = find('#dialog-confirm')
            expect(dialog[:class]).to eq "modal fade show"
            sleep 1
            click_button('Ok')
            dialog = find('#dialog-confirm')
            expect(dialog[:class]).to eq "modal fade"
          end
        end
      end
    end
  end
end

RSpec.describe 'Step 2: Collecting Committee status', js: true do
  require 'integration/integration_spec_helper'

  describe "author can delete a submission" do
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: true }
    let(:author) { current_author }

    before do
      oidc_authorize_author
    end

    it "deletes the submission" do
      FactoryBot.create :submission, :collecting_format_review_files, author: author
      start_count = author.submissions.count
      expect(start_count > 0).to be_truthy
      visit author_root_path
      if !current_partner.graduate?
        click_link("delete")
        expect(author.submissions.count).to eq(start_count - 1)
      else
        expect(page).not_to have_link('delete')
      end
    end
  end
end

require 'presenters/presenters_spec_helper'
RSpec.describe Admin::AuthorOptOutView do
  describe 'it creates an array of authors with published submissions' do
    let(:author1) { FactoryBot.create :author }
    let(:author2) { FactoryBot.create :author }
    let(:author3) { FactoryBot.create :author }
    let(:author4) { FactoryBot.create :author }

    if current_partner.graduate?
      it 'creates a list' do
        FactoryBot.create :submission, :final_is_restricted, author: author1
        FactoryBot.create :submission, :final_is_restricted_to_institution, author: author2
        FactoryBot.create :submission, status: 'released for publication', author: author3
        FactoryBot.create :submission, status: 'collecting format review files', author: author4
        expect(Submission.released_for_publication.count).to eq(3)
        authors = described_class.new.author_email_list
        expect(authors.count).to eq(3)
        expect(authors).to include(id: author1.id, last_name: author1.last_name, first_name: author1.first_name,
                                   year: author1.submissions.last.year, alternate_email_address: author1.alternate_email_address,
                                   opt_out_email: author1.opt_out_email? ? 'yes' : 'no', opt_out_user_set: author1.opt_out_default? ? 'no' : 'yes')
        expect(authors).not_to include(id: author4.id, last_name: author4.last_name, first_name: author4.first_name,
                                       year: author4.submissions.last.year, alternate_email_address: author4.alternate_email_address,
                                       opt_out_email: author4.opt_out_email? ? 'yes' : 'no', opt_out_user_set: author4.opt_out_default? ? 'no' : 'yes')
      end
    end
  end
end

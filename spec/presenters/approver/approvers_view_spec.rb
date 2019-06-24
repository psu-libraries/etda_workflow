require 'presenters/presenters_spec_helper'
RSpec.describe Approver::ApproversView do
  let(:submission) { FactoryBot.create :submission }
  let(:view) { described_class.new(submission) }

  describe '#tooltip_text' do
    context 'when open access' do
      it "returns the proper text for open access" do
        submission.update_attribute :access_level, 'open_access'

        expect(view.tooltip_text).to eq 'Allows free worldwide access to the entire work beginning immediately after degree conferral.'
      end
    end

    context 'when restricted to institution' do
      it "returns the proper text for restricted to institution" do
        submission.update_attribute :access_level, 'restricted_to_institution'

        expect(view.tooltip_text).to eq 'Access restricted to individuals having a valid Penn State Access Account.  Allows restricted access of the entire work beginning immediately after degree conferral.  At the end of the two-year period, the status will automatically change to Open Access.  This work should not be duplicated, shared, or used for any reason other than this review.'
      end
    end

    context 'when restricted' do
      it "returns the proper text for restricted" do
        submission.update_attribute :access_level, 'restricted'

        expect(view.tooltip_text).to eq 'Restricts the entire work for patent and/or proprietary purposes.  At the end of the two-year period, the status will automatically change to Open Access.  This work should not be duplicated, shared, or used for any reason other than this review.'
      end
    end
  end
end

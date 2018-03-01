require 'presenters/presenters_spec_helper'
RSpec.describe Admin::SignatoryPageView do
  let(:author) { FactoryBot.create :author }
  let(:view) { described_class.new(author) }

  describe 'it returns author address for display' do
    it 'returns first line of address' do
      expect(view.address_line1).to eq(author.address_1)
    end

    it 'returns city, state, zip' do
      author_address2 = "#{author.city}, #{author.state} #{author.zip}"
      expect(view.address_line2).to eql(author_address2)
    end
  end

  describe 'it returns blank lines when address is missing' do
    before do
      author.address_1 = nil
      author.city = nil
    end
    it 'contains empty lines' do
      empty_line = '________________'
      expect(view.address_line1).to include(empty_line)
      expect(view.address_line2).to include(empty_line)
    end
  end
end

# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe AuthorAbility, type: :model do
  author_user = FactoryBot.create :author

  context 'An Author can edit and update personal information' do
    author_ability = described_class.new(author_user, nil, nil)

    it 'allows author can edit and update his or her personal information' do
      expect(author_ability.can? :edit, author_user).to be_truthy
      expect(author_ability.can? :update, author_user).to be_truthy
    end
    it 'does not allow author to delete his or her personal information' do
      expect(author_ability.can? :destroy, author_user).to be_falsey
      expect(author_ability.can? :create, author_user).to be_falsey
    end
    it "does not allow author to edit or update a different author's record" do
      different_person = FactoryBot.create :author, access_id: 'different123'
      expect(author_ability.can? :edit, different_person).to be_falsey
      expect(author_ability.can? :udpate, different_person).to be_falsey
    end
  end
end

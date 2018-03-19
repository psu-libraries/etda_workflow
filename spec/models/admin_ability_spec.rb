# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe AdminAbility, type: :model do
  admin_user = FactoryBot.create :admin, administrator: true, site_administrator: true

  it 'authorizes an admin user' do
    current_ability = described_class.new(admin_user)
    expect(current_ability.can? :administer, :all).to be_truthy
  end

  it 'recognizes user without admin privileges' do
    admin_user.administrator = false
    admin_user.site_administrator = false
    current_ability = described_class.new(admin_user)
    expect(current_ability.can? :administer, :all).to be_falsey
  end
end

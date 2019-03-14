class Approver < ApplicationRecord
  Devise.add_module(:webacess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  devise :webaccess_authenticatable, :rememberable, :trackable, :registerable
end

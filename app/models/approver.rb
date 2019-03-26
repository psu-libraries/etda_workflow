class Approver < ApplicationRecord
  Devise.add_module(:webacess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  devise :webaccess_authenticatable, :rememberable, :trackable, :registerable

  validates :access_id, presence: true

  def self.current
    Thread.current[:approver]
  end

  def self.current=(approver)
    Thread.current[:approver] = approver
  end
end

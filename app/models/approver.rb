class Approver < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :webaccess_authenticatable, :rememberable, :trackable, :registerable
end

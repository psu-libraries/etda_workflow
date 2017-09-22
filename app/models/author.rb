class Author < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :webaccess_authenticatable, :rememberable, :trackable, :registerable
end

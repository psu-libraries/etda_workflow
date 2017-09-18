class Author < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :webaccess_authenticatable, :rememberable, :trackable, :registerable

  attr_accessor :access_id, :psu_email_address
end

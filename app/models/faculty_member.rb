class FacultyMembers < ApplicationRecord
    has_many: committee_members
    
    validates :webaccess_id, 
              :first_name, 
              :last_name, presence: true
             
    validates :access_id, uniqueness: { case_sensitive: true }

end
class MockDirectoryService
  class << self
    def get_accessid_by_email(email_address)
      return nil if email_address.blank?

      return email_address.gsub('@psu.edu', '').strip if email_address.match?(/.*@psu.edu/)

      return 'pbm123' if email_address == 'buck@hotmail.com'

      nil
    end
  end
end

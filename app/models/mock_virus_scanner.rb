# frozen_string_literal: true

class MockVirusScanner
  def self.safe?(_value)
    true
  end

  def self.scan(*)
    Response.new(true)
  end

  Response = Struct.new(:safe?)
end

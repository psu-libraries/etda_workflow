# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe Semester, type: :model do
  describe 'Semester' do
    year = Time.now.year
    it 'returns fall for dates after 8-15' do
      semester = described_class.current(Time.zone.parse("#{year}-8-16:T00:00"))
      expect(semester).to eql("#{year} Fall")
    end
    it 'returns summer for dates after 5-15' do
      semester = described_class.current(Time.zone.parse("#{year}-5-16:T00:00"))
      expect(semester).to eql("#{year} Summer")
    end
    it 'returns spring for dates before 5-16' do
      semester = described_class.current(Time.zone.parse("#{year}-5-15:T00:00"))
      expect(semester).to eql("#{year} Spring")
    end
  end
end

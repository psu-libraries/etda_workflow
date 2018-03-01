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
    it 'returns all years for admin drop-down' do
      all_years = described_class.all_years
      expect(all_years).to be_an(Array)
      expect(all_years.last).to eq(1998)
      expect(all_years.first).to eq(Time.zone.today.year + 3)
    end

    it 'returns current year + 5 years for student year drop-down' do
      expect(described_class.graduation_years).to be_an(Array)
      expect(described_class.graduation_years.first).to eq(Time.zone.today.year)
      expect(described_class.graduation_years.last).to eq(Time.zone.today.year + 5)
    end
  end
end

# frozen_string_literal: true
require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe Semester, type: :model do
  describe 'Semester' do
    it 'returns fall for dates after 8-15' do
      semester = described_class.current(Time.zone.parse "2016-8-16:T00:00")
      expect(semester).to eql('2016 Fall')
    end
    it 'returns summer for dates after 5-15' do
      semester = described_class.current(Time.zone.parse "2016-5-16:T00:00")
      expect(semester).to eql('2016 Summer')
    end
    it 'returns spring for dates before 5-16' do
      semester = described_class.current(Time.zone.parse "2016-5-15:T00:00")
      expect(semester).to eql('2016 Spring')
    end
  end
end

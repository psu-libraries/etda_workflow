# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe Semester, type: :model do
  describe 'Semester' do
    let(:year) { Time.now.year }

    describe '#current' do
      let(:semester) { described_class.current }

      it 'returns fall for dates after 8-15' do
        allow(Semester).to receive(:today).and_return(Time.zone.parse("#{year}-8-16:T00:00"))
        expect(semester).to eql("#{year} Fall")
      end
      it 'returns summer for dates after 5-15' do
        allow(Semester).to receive(:today).and_return(Time.zone.parse("#{year}-5-16:T00:00"))
        expect(semester).to eql("#{year} Summer")
      end
      it 'returns spring for dates before 5-16' do
        allow(Semester).to receive(:today).and_return(Time.zone.parse("#{year}-5-15:T00:00"))
        expect(semester).to eql("#{year} Spring")
      end
    end

    describe '#last' do
      let(:semester) { described_class.last }

      it 'returns Summer for dates after 8-15' do
        allow(Semester).to receive(:today).and_return(Time.zone.parse("#{year}-8-16:T00:00"))
        expect(semester).to eql("#{year} Summer")
      end
      it 'returns Spring for dates after 5-15' do
        allow(Semester).to receive(:today).and_return(Time.zone.parse("#{year}-5-16:T00:00"))
        expect(semester).to eql("#{year} Spring")
      end
      it 'returns Fall for dates before 5-16' do
        allow(Semester).to receive(:today).and_return(Time.zone.parse("#{year}-5-15:T00:00"))
        expect(semester).to eql("#{year - 1} Fall")
      end
    end

    it 'returns all years for admin drop-down' do
      all_years = described_class.all_years
      expect(all_years).to be_an(Array)
      expect(all_years.last).to eq(1998)
      expect(all_years.first).to eq(Time.zone.today.year + 10)
    end

    it 'returns current year + 10 years for student year drop-down' do
      expect(described_class.graduation_years).to be_an(Array)
      expect(described_class.graduation_years.first).to eq(Time.zone.today.year - 10)
      expect(described_class.graduation_years.last).to eq(Time.zone.today.year + 10)
    end
  end
end

# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe MockVirusScanner do
  describe '.scan' do
    it 'accepts anything' do
      expect { described_class.scan(location: '/dev/null') }.not_to raise_error
    end

    it 'returns a MockVirusScanner::Response' do
      expect(described_class.scan).to respond_to :safe?
    end
  end
end

RSpec.describe MockVirusScanner::Response do
  let(:safe)   { described_class.new(true) }
  let(:unsafe) { described_class.new(false) }

  it 'responds to :safe?' do
    expect(safe.safe?).to be true
    expect(unsafe.safe?).to be false
  end
end

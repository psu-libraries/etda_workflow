# frozen_string_literal: true

require 'rails_helper'

RSpec.describe String, type: :model do
  describe '#strip_control_and_extended_characters' do
    it 'removes non-ascii characters' do
      str = "\u00BD"
      str += 'hello there'
      expect(str).not_to eql('hello there')
      new_str = str.strip_control_and_extended_characters
      expect(new_str).to eql('hello there')
    end
  end
end

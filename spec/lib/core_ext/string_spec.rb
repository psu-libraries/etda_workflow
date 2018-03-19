# frozen_string_literal: true

require 'rails_helper'

RSpec.describe String, type: :model do
  context '#strip_control_and_extended_characters' do
    it 'removes non-ascii characters' do
      str = "\u00BD"
      str += 'hello there'
      expect(str).not_to eql('hello there')
      new_str = str.strip_control_and_extended_characters
      expect(new_str).to eql('hello there')
    end
  end

  context '#articalize' do
    it 'properly uses "an" before words starting with a vowel' do
      str = 'egg'
      expect(str.articleize).to eq('an egg')
    end
    it 'does uses "a" before words starting with a constant' do
      str = 'house'
      expect(str.articleize).to eq('a house')
    end
  end
end

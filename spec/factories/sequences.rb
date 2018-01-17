# frozen_string_literal: true

# Sequences reused across factories
FactoryBot.define do
  sequence :name, 1000 do |n|
    "name #{n}"
  end

  sequence :description, 1000 do |n|
    "description #{n}"
  end

  sequence :title, 1000 do |n|
    "title #{n}"
  end
end

if ENV['TRAVIS']
  VERSION_NUMBER_FILE = 'spec/fixtures/version_number.rb'
end
if File.exists? VERSION_NUMBER_FILE    #("#{Rails.root}/config/version_number.yml")
  VERSION_NUMBER = File.read(VERSION_NUMBER_FILE)
else
  VERSION_NUMBER = ''
end
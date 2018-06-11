# frozen_string_literal: true

namespace :application do
  desc "update config/locales/version_number with tagged version from git.  Run this after tagging a new version and before pushing it to github."
  task git_version_number: :environment do
     # `git describe --tags --abbrev=0 HEAD` will eliminate the hash after the version#.  This occurs if a new tag is not created.
    unless testing?
      version_number = `git describe --tags HEAD`
      current_version_number = version_number.strip.strip
    end
    update_version_number_file(current_version_number)
  end

  def update_version_number_file(current_version)
    filename = VERSION_NUMBER_FILE
    if testing?
      current_version = 'v.101-test'
    else
      filename = VERSION_NUMBER_FILE
    end
    if current_version.empty?
      puts 'No updates occurred:  No version number found.'
      return
    end
    File.write("#{filename}", "#{current_version}")
    puts "#{filename} updated with #{current_version}"
  end

  def testing?
    Rails.env.test? || ENV['CI']
  end
end


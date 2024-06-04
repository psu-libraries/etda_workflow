# frozen_string_literal: true

desc 'Release eligible restricted submissions'
task auto_release: :environment do
  AutoReleaseService.new.release
end

desc 'Notify authors of upcoming restricted submission release'
task upcoming_auto_release_notification: :environment do
  AutoReleaseService.new.notify_author
end
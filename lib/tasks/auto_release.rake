# frozen_string_literal: true

desc 'Release eligible restricted submissions'
task auto_release: :environment do
  AutoReleaseService.new.release
end
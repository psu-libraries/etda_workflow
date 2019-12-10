# frozen_string_literal: true

namespace :confidential do

  desc 'Update authors that have a confidential hold status in ldap'
  task update: :environment do
    Author.all.each do |author|
      conf_hold_update_service = ConfidentialHoldUpdateService.new author, 'rake_task'
      conf_hold_update_service.update
    end
  end
end

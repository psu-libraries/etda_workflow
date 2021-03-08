namespace :utilities do

  desc "Deactivate legacy programs post lionpath release"
  task deactivate_legacy_programs: :environment do
    Program.where('code IS NULL').each { |p| p.update is_active: false }
  end
end

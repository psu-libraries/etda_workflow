FactoryBot.define do
  factory :sed_file, class: SedFile do |_f|
    submission
    asset { File.open(fixture('ancillary_file.pdf')) }
  end
end

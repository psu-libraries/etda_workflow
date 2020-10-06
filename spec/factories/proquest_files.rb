FactoryBot.define do
  factory :proquest_file, class: ProquestFile do |_f|
    submission
    asset { File.open(fixture('ancillary_file.pdf')) }
  end
end

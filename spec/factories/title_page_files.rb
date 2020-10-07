FactoryBot.define do
  factory :title_page_file, class: TitlePageFile do |_f|
    submission
    asset { File.open(fixture('ancillary_file.pdf')) }
  end
end

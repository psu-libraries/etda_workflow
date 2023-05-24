Rails.application.config.to_prepare do
  if Rails.env == 'test'
    LdapUniversityDirectory = MockUniversityDirectory
    VirusScanner = MockVirusScanner
    DirectoryService = MockDirectoryService
    WORKFLOW_BASE_PATH = 'tmp/workflow/'
    EXPLORE_BASE_PATH = 'tmp/explore/'
  elsif Rails.env == 'development'
    LdapUniversityDirectory = MockUniversityDirectory
    VirusScanner = MockVirusScanner
    DirectoryService = MockDirectoryService
    WORKFLOW_BASE_PATH = "tmp/workflow_files/#{Partner.current.id}/"
    EXPLORE_BASE_PATH = "tmp/explore_files/#{Partner.current.id}/"
    FILE_SOURCE_BASE_PATH = "/Users/ajk5603/RubymineProjects/etda_workflow/uploads/"
  elsif Rails.env == 'production'
    VirusScanner = Clamby
    UniversityDirectory = LdapUniversityDirectory
    WORKFLOW_BASE_PATH = Rails.root.join('workflow_data_files/').to_s
    EXPLORE_BASE_PATH =  Rails.root.join('explore_data_files/').to_s
  end
end

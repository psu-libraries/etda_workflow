# frozen_string_literal: true

class EtdaFilePaths < EtdaUtilities::EtdaFilePaths
  def workflow_base_path
    WORKFLOW_BASE_PATH
  end

  def explore_base_path
    EXPLORE_BASE_PATH
  end

  def this_host
    Rails.application.secrets.webaccess[:path] + '/'
  end
end

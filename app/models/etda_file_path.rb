# frozen_string_literal: true

class EtdaFilePath < EtdaUtilities::EtdaFilePaths
  def workflow_base_path
    WORKFLOW_BASE_PATH
  end

  def explore_base_path
    EXPLORE_BASE_PATH
  end
end

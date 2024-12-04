class FileUtilityHelper
  def copy_test_file(to_path)
    FileUtils.cp(Rails.root.join('spec', 'fixtures', 'files', 'final_submission_file_01.pdf'), to_path)
  end

  def remove_test_file(from_path)
    FileUtils.remove_file(from_path, true)
  end

  def file_was_moved?(original_location, new_location)
    return false unless File.exist? new_location
    return false unless original_location != new_location
    return false if File.exist? original_location

    true
  end
end

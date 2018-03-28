class Author::FilesController < FilesController
  private

    def find_file
      return FormatReviewFile.find(params[:id]) unless params[:action] == 'download_final_submission'
      FinalSubmissionFile.find(params[:id])
    end

    def current_ability
      file = find_file
      @current_ability ||= AuthorAbility.new(current_author, file.submission, file)
    end
end

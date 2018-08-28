class Author::FilesController < FilesController
  before_action :current_file

  private

    def current_file
      # file type
      @current_file = if params[:action] == 'download_final_submission'
                        FinalSubmissionFile.find(params[:id])
                      else
                        FormatReviewFile.find(params[:id])
                      end
    end

    def current_ability
      file = current_file
      @current_ability ||= AuthorAbility.new(current_author, file.submission, file)
    end
end

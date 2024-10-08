class FinalSubmissionReleaseService
  attr_accessor :submission

  def initialize(submission)
    @submission = submission
  end

  def released_unpublish
    release_service = SubmissionReleaseService.new
    original_final_files = release_service.final_files_for_submission(submission)
    file_verification_results = release_service.file_verification(original_final_files)
    status_giver = SubmissionStatusGiver.new(submission)

    status_giver.unreleased_for_publication!
    submission.update(released_for_publication_at: nil,
                      released_metadata_at: nil)
    release_service.unpublish(original_final_files) if file_verification_results[:valid]
    # update the index after the paper has been unreleased
    solr_result = SolrDataImportService.new.remove_submission(submission)
    { msg: final_unrelease_message(solr_result, file_verification_results), redirect_path: admin_edit_sub_path }
  end

  private

    def final_unrelease_message(solr_result, file_verification_results)
      msg = solr_result[:error] ? solr_error_msg : success_msg
      # the following loop prints full file path details.  After app is stable, consider removing this.
      # The same information is also printed in production.log
      unless file_verification_results[:valid]
        msg << file_error_msg
        file_verification_results[:file_error_list].each do |error_msg|
          msg << error_msg
        end
      end
      msg
    end

    def solr_error_msg
      author_name = "#{submission.author_first_name} #{submission.author_last_name}"
      "Solr indexing error occurred when un-publishing submission for #{author_name}"
    end

    def success_msg
      "Submission for #{submission.author_first_name} #{submission.author_last_name} was successfully un-published."
    end

    def file_error_msg
      "\nError occurred relocating file for submission id #{submission.id}.  Please contact an administrator:  "
    end

    def admin_edit_sub_path
      url_helpers.admin_edit_submission_path(submission.id.to_s)
    end

    def url_helpers
      Rails.application.routes.url_helpers
    end
end

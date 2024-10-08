class Author::SubmissionFormatReviewController < AuthorController
  before_action :find_submission

  def edit
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_upload_format_review_files?
    render 'author/submissions/edit_format_review'
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = t("#{current_partner.id}.partner.not_allowed_alert")
  end

  def update
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_upload_format_review_files?
    @submission.update!(format_review_params)
    status_giver.waiting_for_format_review_response!
    @submission.update_format_review_timestamps!(Time.zone.now)
    redirect_to author_root_path
    WorkflowMailer.send_format_review_received_email(@submission)
    flash[:notice] = 'Format review files uploaded successfully.'
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = @submission.errors.messages.values.join(" ")
    redirect_to author_submission_edit_format_review_path(@submission)
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = t("#{current_partner.id}.partner.not_allowed_alert")
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to author_root_path
    flash[:alert] = 'Oops! You may have submitted invalid format review data. Please check that your format review information is correct.'
  end

  def show
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_review_format_review_files?
    render 'author/submissions/format_review'
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = t("#{current_partner.id}.partner.not_allowed_alert")
  end

  private

    def find_submission
      @submission = @author.submissions.find(params[:submission_id])
      @submission.author_edit = true unless @submission.nil?
      @submission.federal_funding_details.author_edit = true if @submission.federal_funding_details.present?
      @submission
    end

    def format_review_params
      params.require(:submission).permit(:title,
                                         :allow_all_caps_in_title,
                                         :semester,
                                         :year,
                                         :federal_funding,
                                         format_review_files_attributes: [:asset, :asset_cache, :submission_id, :id, :_destroy],
                                         admin_feedback_files_attributes: [:asset, :asset_cache, :submission_id, :feedback_type, :id, :_destroy],
                                         federal_funding_details_attributes: [:id, :submission_id, :training_support_funding, :training_support_acknowledged, :other_funding, :other_funding_acknowledged])
    end
end

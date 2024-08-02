# frozen_string_literal: true

class ExtensionController < ApplicationController
  def autorelease_extension
    @submission = find_submission
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_request_extension?

    new_release_date = @submission.released_for_publication_at + 1.year
    @submission.update!(released_for_publication_at: new_release_date)

    redirect_to root_path
    formatted_release_date = @submission.reload.released_for_publication_at.strftime("%B %d, %Y")
    flash[:notice] = "Your extension was successful. The updated release date is #{formatted_release_date}"
  rescue SubmissionStatusGiver::AccessForbidden, ActiveRecord::RecordNotFound
    redirect_to root_path
    flash[:alert] = t("#{current_partner.id}.partner.extension_not_allowed")
  end

  private

    def find_submission
      submission = Submission.find_by(extension_token: params[:extension_token])
      raise ActiveRecord::RecordNotFound if submission.blank?

      submission
    end
end

# frozen_string_literal: true

class Review::CommitteeMemberReviewController < ReviewController
  protect_from_forgery with: :exception

  def edit
    # raise params
    @submission = Submission.find(params[:submission_id])
  end

end
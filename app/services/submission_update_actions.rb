class SubmissionUpdateActions
  attr_accessor :params

  def initialize(params)
    @params = params
  end

  def approved?
    return true if params[:approved]

    false
  end

  def rejected?
    return true if params[:rejected]

    false
  end

  def record_updated?
    return true if params[:update_format_review] || params[:update_final] || params[:update]

    false
  end

  def send_back_to_final_submission?
    return true if params[:send_back_to_final_submission]

    false
  end

  def send_to_hold?
    return true if params[:send_to_hold]

    false
  end

  def remove_hold?
    return true if params[:remove_hold]

    false
  end

  def rejected_committee?
    return true if params[:rejected_committee]

    false
  end
end

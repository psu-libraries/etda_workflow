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
end

class OpenAccessReportEmail
  def deliver
    mailer.open_access_report(submissions, date_range).deliver_now
  end

  private

  def mailer
    WorkflowMailer.new
  end

  def date_range
    case end_month
    when 5
      "01/01/#{current_year} - #{strf_today}"
    when 8
      "06/01/#{current_year} - #{strf_today}"
    when 12
      "09/01/#{current_year} - #{strf_today}"
    end
  end

  def submissions
    Submission.where(status: 'released for publication',
                     access_level: 'open_access').
               where('submissions.released_for_publication_at >= ? AND submissions.released_for_publication_at <= ?',
                     Date.strptime("0#{start_month}/01/#{current_year}", "%D"), today)
  end

  def start_month
    case end_month
    when 5
      1
    when 8
      6
    when 12
      9
    end
  end

  def end_month
    today.month
  end

  def current_year
    today.year
  end

  def strf_today
    today.strftime('%D')
  end

  def today
    Date.today
  end
end

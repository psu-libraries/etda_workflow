class OpenAccessReportEmail
  def deliver
    @mail_sender.open_access_report(submissions, date_range).deliver_now
  end

  private

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
                     start_month, end_month)
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
    Date.today.month
  end

  def current_year
    Date.today.year
  end

  def strf_today
    Date.today.strftime('%D')
  end
end

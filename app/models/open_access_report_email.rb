class OpenAccessReportEmail
  class InvalidReleaseMonth < RuntimeError; end

  def deliver
    WorkflowMailer.open_access_report(submissions, date_range).deliver_now
  end

  private

  def date_range
    case end_month
    when 6
      "02/01/#{semester_year} - #{strf_today}"
    when 9
      "07/01/#{semester_year} - #{strf_today}"
    when 1
      "10/01/#{semester_year} - #{strf_today}"
    else
      raise InvalidReleaseMonth
    end
  end

  def submissions
    Submission.where(status: 'released for publication',
                     access_level: 'open_access')
              .where('submissions.released_for_publication_at >= ? AND submissions.released_for_publication_at <= ?',
                     Date.strptime("#{start_month}/01/#{semester_year}", '%m/%d/%Y'), today)
  end

  def start_month
    case end_month
    when 6
      '02'
    when 9
      '07'
    when 1
      '10'
    else
      raise InvalidReleaseMonth
    end
  end

  def end_month
    today.month
  end

  def semester_year
    return (today.year - 1) if today.month == 1

    today.year
  end

  def strf_today
    today.strftime('%m/%d/%Y')
  end

  def today
    Date.today
  end
end

class OpenAccessReportEmail
  def deliver
    WorkflowMailer.open_access_report(date_range, csv).deliver_now
  end

  private

  def csv
    CSV.generate do |csv|
      csv << headers
      submissions.each do |submission|
        csv << row(submission)
      end
    end
  end

  def headers
    ['Last Name', 'First Name', 'Title', 'Degree Type', 'Graduation Semester', 'Released On']
  end

  def row(submission)
    [submission.author.last_name.to_s, submission.author.first_name.to_s, submission.title.strip.to_s,
     submission.degree.degree_type.name.to_s, "#{submission.semester} #{submission.year}",
     submission.released_for_publication_at.strftime('%D').to_s]
  end

  def submissions
    Submission.where(status: 'released for publication', access_level: 'open_access')
              .where('submissions.released_for_publication_at >= ? AND submissions.released_for_publication_at <= ?',
                     Date.strptime("#{start_month}/01/#{semester_year}", '%m/%d/%Y'), today)
  end

  def date_range
    "#{start_month}/01/#{semester_year} - #{strf_today}"
  end

  def start_month
    case end_month
    when 2, 3, 4, 5, 6
      '02'
    when 7, 8, 9
      '07'
    when 10, 11, 12, 1
      '10'
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

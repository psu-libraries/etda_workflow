class SemesterReleaseReportEmail
  def deliver
    WorkflowMailer.semester_release_report(date_range, csv, filename).deliver_now
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

    def filename
      "ETD_#{Semester.last.gsub(' ', '').upcase}_RELEASE_REPORT.csv"
    end

    def headers
      ['Last Name', 'First Name', 'Title', 'Degree Type', 'Graduation Semester', 'Released On', 'Access Level']
    end

    def row(submission)
      [submission.author.last_name.to_s, submission.author.first_name.to_s, submission.title.strip.to_s,
       submission.degree.degree_type.name.to_s, "#{submission.semester} #{submission.year}",
       released_at(submission), submission.access_level.to_s]
    end

    def released_at(submission)
      if submission.restricted? || submission.restricted_to_institution?
        submission.released_metadata_at.strftime('%D').to_s
      else
        submission.released_for_publication_at.strftime('%D').to_s
      end
    end

    def submissions
      Submission.where("submissions.status = 'released for publication' AND submissions.access_level = 'open_access'")
                .where('submissions.released_for_publication_at >= ? AND submissions.released_for_publication_at <= ?',
                       Date.strptime("#{start_month}/01/#{semester_year}", '%m/%d/%Y'), today)
                .or(Submission.where("submissions.status LIKE '%released for publication%'")
                              .where('submissions.released_metadata_at >= ? AND submissions.released_metadata_at <= ?',
                                     Date.strptime("#{start_month}/01/#{semester_year}", '%m/%d/%Y'), today))
    end

    def date_range
      "#{start_month}/01/#{semester_year} - #{strf_today}"
    end

    def start_month
      if Semester.last.include? 'Spring'
        '02'
      elsif Semester.last.include? 'Summer'
        '06'
      elsif Semester.last.include? 'Fall'
        '09'
      else
        '02'
      end
    end

    def end_month
      today.month
    end

    def semester_year
      Semester.last.split(' ').first
    end

    def strf_today
      today.strftime('%m/%d/%Y')
    end

    def today
      Date.today
    end
end

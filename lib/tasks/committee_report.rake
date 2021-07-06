namespace :report do

  desc "Generates a report listing the committee members for each submission"
  task committee: :environment do
    header_length = Submission.joins(:committee_members).group("submissions.id").count.values.max
    CSV.open("#{Rails.root}/tmp/committee_report.csv", "wb:UTF-8") do |csv|
      Submission.all.each_with_index do |submission, i|
        if i == 0
          header = ['Student ID', 'Program', 'Paper Title', 'Paper Access']

          committee_header = header_length.times.collect {
              |n| ["Committee Member #{n + 1} Name", "Committee Member #{n + 1} Access ID"]
          }

          header << committee_header.flatten
          csv << header.flatten
          next
        end
        row = [submission.author.access_id.to_s, (submission.program.present? ? submission.program.name : nil),
               submission.title, submission.access_level.present? ? submission.access_level.gsub('_', ' ').titleize : nil]

        committee_member_rows = submission.committee_members.collect {
            |cm| [cm.name, cm.access_id]
        }

        row << committee_member_rows.flatten
        csv << row.flatten
      end
    end
  end
end

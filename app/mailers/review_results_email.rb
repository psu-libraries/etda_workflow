class ReviewResultsEmail
  attr_accessor :submission

  def initialize(submission)
    @submission = submission
  end

  def generate
    output = ''
    @submission.committee_members.each_with_index do |cm, i|
      output << "#{i + 1}. #{cm.name}\n"
      output << "\t- Response: #{cm.status&.titleize}\n"
      output << "\t- Comments: #{cm.notes}\n"
      output << "\n"
    end
    output
  end
end

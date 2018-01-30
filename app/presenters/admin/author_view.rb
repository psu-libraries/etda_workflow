class Admin::AuthorView
  def initialize(author)
    @this_author = author || nil
  end

  def submission_list
    submissions = @this_author.submissions.order('created_at DESC')
    return '<p>No submissions for this author</p>'.html_safe unless submissions.count.positive?
    list = build_submission_list(submissions)
    list.html_safe
  end

  private

  def build_submission_list(submissions)
    list = "<ul>"
    submissions.each do |s|
      list << list_item(s)
    end
    list << '</ul>'
  end

  def list_item(s)
    return "<li><a href='/admin/submissions/#{s.id}/edit'>#{s.title}</a><br/>status: #{s.status}, created: #{s.created_at.strftime('%m/%d/%Y')}</li>" if s.status_behavior.beyond_collecting_format_review_files?
    "<li>#{s.title}<br/>status: #{s.status}, created: #{s.created_at.strftime('%m/%d/%Y')}</li>"
  end
end

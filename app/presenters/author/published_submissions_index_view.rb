class Author::PublishedSubmissionsIndexView
  attr_reader :submissions

  def initialize(author)
    @author = author
    @submissions = @author.submissions.released_for_publication
  end

  def title_link(submission)
    "<span class='sr-only'>link to your submission #{submission.cleaned_title} opens in a new tab</span> <a target = blank href = '#{WebAccess.new.explore_base_url}/catalog/#{submission.public_id}' class='title'> #{submission.cleaned_title} </a>"
  end

  def release_information(submission)
    if submission.restricted?
      date = submission.released_metadata_at
      str = '<strong>Abstract Publish Date: </strong>'
    else
      date = submission.released_for_publication_at
      str = '<strong>Publication Date: </strong>'
    end
    str + date.strftime('%B %-e, %Y')
  end
end

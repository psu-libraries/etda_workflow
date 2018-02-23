class SubmissionDecorator < Decorator
  attr_reader :context

  include GlobalID::Identification

  def initialize(submission, context)
    @context = context
    super(submission)
  end

  def table_title
    title.presence || '[Title not available]'
  end

  delegate :label, to: :access_level, prefix: true

  def released_for_publication_date
    format_date(released_for_publication_at)
  end

  def format_review_files_uploaded_date
    format_date(format_review_files_first_uploaded_at)
  end

  def final_submission_files_uploaded_date
    format_date(final_submission_files_first_uploaded_at)
  end

  def creation_date
    format_date(created_at)
  end

  def most_relevant_file_links
    if final_submission_files.any?
      final_submission_files.map { |f| context.link_to(f.asset_identifier, Rails.application.routes.url_helpers.final_submission_file_path(f.id), 'data-no-turbolink': true) }
    elsif format_review_files.any?
      format_review_files.map { |f| context.link_to(Partner.current.graduate? ? f.asset_identifier.truncate(38) : f.asset_identifier, Rails.application.routes.url_helpers.format_review_file_path(f.id), 'data-no-turbolink': true) }
    else
      []
    end
  end

  def indicator_labels
    indicators = []

    indicators << '<span class="label label-warning">Rejected</span>' if (status_behavior.collecting_format_review_files? && status_behavior.collecting_format_review_files_rejected?) || (status_behavior.collecting_final_submission_files? && status_behavior.collecting_final_submission_files_rejected?)

    indicators.any? ? (indicators.join(' ') + ' ').html_safe : ''
  end

  private

  def format_date(date)
    date.try(:strftime, '%Y-%m-%e')
  end
end

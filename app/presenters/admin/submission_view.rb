class Admin::SubmissionView < SimpleDelegator
  delegate :class, to: :__getobj__

  attr_reader :context

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
      final_submission_files.map do |f|
        next if f.asset_identifier.blank?

        context.link_to f.asset_identifier.truncate(30, omission: "...#{f.asset_identifier[-7, 7]}"),
                        context.admin_final_submission_file_path(f.id), 'data-no-turbolink': true
      end
    elsif format_review_files.any?
      format_review_files.map do |f|
        next if f.asset_identifier.blank?

        context.link_to f.asset_identifier.truncate(30, omission: "...#{f.asset_identifier[-7, 7]}"),
                        context.admin_format_review_file_path(f.id), 'data-no-turbolink': true
      end
    else
      []
    end
  end

  def indicator_labels
    indicators = []

    indicators << '<span class="label label-warning">Rejected</span>' if status_behavior.format_review_rejected? || status_behavior.final_submission_rejected?

    indicators.any? ? (indicators.join(' ') + ' ').html_safe : ''
  end

  private

    def format_date(date)
      date.try(:strftime, '%Y-%m-%d')
    end
end

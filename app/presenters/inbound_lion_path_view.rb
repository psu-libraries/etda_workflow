class InboundLionPathView
  attr_reader :model,
              :author

  delegate :id,
           :title,
           :status,
           :access_level,
           :released_metadata_at,
           :released_for_publication_at,
           to: :model

  def initialize(model)
    @model = model
    @author = model.author
  end

  def degree
    model.program.name.concat(degree_code)
  end

  def cleaned_title
    title.strip_control_and_extended_characters
  end

  def status_date
    format_date(SubmissionStates::StateGenerator.state_for_name(model.status).status_date(model))
  end

  def embargo_start
    format_date(model.released_metadata_at)
  end

  def embargo_end
    format_date(model.released_for_publication_at)
  end

  def release_date
    format_date(model.released_for_publication_at)
  end

  def degree_code
    return '_PHD' if model.degree_type.id == DegreeType.default.id

    '_MS'
  end

  private

    def format_date(this_date)
      return 'N/A' if this_date.nil?

      this_date.strftime(LionPath::LpFormats::DEFENSE_DATE_FORMAT)
    end
end

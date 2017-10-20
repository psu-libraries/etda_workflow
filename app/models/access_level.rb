class AccessLevel < Enumerize::Value
  # *** IMPORTANT NOTE ***
  # The order of the keys in this array matter and they should go from least restrictive to most restrictive
  # This is used in the comparison operation (<=>) below
  ACCESS_LEVEL_KEYS = ["open_access", "restricted_to_institution", "restricted"]

  # create instances of each type that can be used
  # OPEN_ACCESS, RESTRICTED, and RESTRICTED_TO_INSTITUTION (graduate only)
  class << self
    (ACCESS_LEVEL_KEYS).each do |level|
      define_method(level.upcase) do
        new(level)
      end
    end
  end

  def self.paper_access_level_keys
    ACCESS_LEVEL_KEYS
  end

  def self.valid_levels
    paper_access_level_keys + ['']
  end

  def self.paper_access_levels
    paper_access_level_keys.map do |key|
      level = AccessLevel.new(key)
      { type: key, label: level.text, description: level.description }
    end
  end

  def initialize(level)
    super(submission_attributes, level)
  end

  def <=>(other)
    alevel = other
    alevel = self.class.new(alevel) unless alevel.instance_of? self.class
    to_i <=> alevel.to_i
  end

  def scope
    I18n.t("#{i18n_attr_handle}.scope", default: 'released_for_publication')
  end

  def label
    I18n.t("#{i18n_handle}", default: '')
  end

  def description
    I18n.t("#{i18n_attr_handle}.description_html", default: '').html_safe
  end

  # define the integer value of the item as the index in the access other keys array
  def to_i
    self.class.valid_levels.find_index self
  end

  private

    def i18n_attr_handle
      "#{i18n_handle}_attr"
    end

    def i18n_handle
      "#{EtdaUtilities::Partnercurrent.id}.access_level.#{self}"
    end

    def submission_attributes
      @attributes ||= Submission.enumerized_attributes[:access_level]
    end

    def method_missing(sym, *args, &block)
      super
    rescue NoMethodError
      name = sym.to_s.sub('?', '')
      if ACCESS_LEVEL_KEYS.include?(name)
        return false
      else
        raise
      end
    end
end

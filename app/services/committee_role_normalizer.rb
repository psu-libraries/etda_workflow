class CommitteeRoleNormalizer
  PRIORITY_REGEX = [
    ["Co-Chairperson", /\b(co[-\s]?chair|co[-\s]?chairperson|committee chair\/co-chair)\b/i],
    ["Chairperson", /\b(chairperson|chair of committee|committee chair|chair)\b/i],
    ["Co-Advisor", /\b(co[-\s]?dissertation\s*advis(or|er)|co[-\s]?advisor)\b/i],
    ["Advisor", /\b(dissertation\s*advis(or|er)|advisor)\b/i],
    ["Supervisor", /\bsupervisor\b/i],
    ["Mentor", /\bmentor\b/i],
    ["Second Reader", /\bsecond\s+reader\b/i],
    ["Reader", /\breader\b/i],
    ["Member", /\b(member|rep|represent|representative|substitute)\b/i]
  ].freeze

  def self.normalize(raw_name)
    text = raw_name.to_s.strip
    return "Other" if text.empty?

    PRIORITY_REGEX.each do |label, regex|
      return label if text.match?(regex)
    end

    "Other"
  end
end

class String
  def strip_control_characters
    chars.each_with_object("") do |char, str|
      str << char unless char.ascii_only? && (char.ord < 32 || char.ord == 127)
    end
  end

  def strip_control_and_extended_characters
    chars.each_with_object("") do |char, str|
      str << char if char.ascii_only? && char.ord.between?(32, 126)
    end
  end

  def articleize
    %w[a e i o u].include?(self[0].downcase) ? "an #{self}" : "a #{self}"
  end
end

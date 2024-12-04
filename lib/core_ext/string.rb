module CoreExt
  class String
    def strip_control_and_extended_characters
      chars.each_with_object("") do |char, str|
        str << char if char.ascii_only? && char.ord.between?(32, 126)
      end
    end

    def articleize
      %w[a e i o u].include?(self[0].downcase) ? "an #{self}" : "a #{self}"
    end

    def numeric?
      begin
        Float(self).nil?
      rescue StandardError
        return false
      end
      true
    end
  end
end

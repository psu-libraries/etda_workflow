class Decorator < SimpleDelegator
  delegate :class, to: :__getobj__
end

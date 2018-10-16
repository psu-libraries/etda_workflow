module ApplicationUrl
  thread_mattr_accessor :current
  thread_mattr_accessor :stage

  def self.stage
    return '-qa' if current.include? '-qa.'
    return '-stage' if current.include? '-stage.'
    return '-dev' if current.include? '-dev.'

    ''
  end
end

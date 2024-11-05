# Load the Rails application.
require_relative "application"

# This method returns true if the current instance is the development env
# or is running in qa or dev (as opposed to stage, prod, or the test env).
# The development instances are used for manually testing new development features.
# Use this method to build logic around features that may impede manual testing.
def development_instance?
  Rails.env.development? || ENV["HOSTNAME"] == 'etdaworkflow1qa' || ENV["HOSTNAME"] == 'etdaworkflow1dev' || ENV['DEVELOPMENT_INSTANCE'].present?
end

# Initialize the Rails application.
Rails.application.initialize!

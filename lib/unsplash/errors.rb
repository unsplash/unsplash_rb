module Unsplash # :nodoc:
  # Raised when there is an error communicating with Unsplash.
  class Error < StandardError; end
  # Raise for deprecation errors
  class DeprecationError < Error; end
end

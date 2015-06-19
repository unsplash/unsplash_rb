require "httparty"

require "unsplash/version"
require "unsplash/configuration"
require "unsplash/connection"

module Unsplash
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end

module Unsplash # :nodoc:
  class Configuration # :nodoc:
    attr_accessor :application_access_key
    attr_accessor :application_secret
    attr_accessor :application_redirect_uri
    attr_accessor :logger
    attr_accessor :utm_source
    attr_writer   :test

    def initialize
      @test = true
      @logger = Logger.new(STDOUT)
    end

    def test?
      !!@test
    end

    def application_id=(key)
      logger.warn "Configuring application_id is deprecated. Use application_access_key."
      self.application_access_key = key
    end

    def application_id
      application_access_key
    end

  end
end
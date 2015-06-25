module Unsplash # :nodoc:
  class Configuration # :nodoc:
    attr_accessor :application_id
    attr_accessor :application_secret
    attr_accessor :application_redirect_uri
    attr_writer   :test

    def initialize
      @test = true
    end

    def test?
      !!@test
    end

  end
end
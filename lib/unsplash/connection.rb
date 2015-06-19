module Unsplash
  class Connection
    include HTTParty

    DEFAULT_VERSION  = "v1"
    DEFAULT_BASE_URI = "http://api.unsplash.com"

    def initialize(application_id, application_secret, options = {})
      @application_id     = application_id
      @application_secret = application_secret
      @api_version        = options.fetch(:version, DEFAULT_VERSION)
      @base_uri           = options.fetch(:base_uri, DEFAULT_BASE_URI)

      Unsplash::Connection.base_uri @base_uri
    end

    def get(path)
      self.class.get path, headers: auth_header
    end

    private

    def auth_header
      { "Authorization" => "Client-ID #{@application_id}" }
    end

  end


end
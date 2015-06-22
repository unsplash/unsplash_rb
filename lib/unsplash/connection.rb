module Unsplash
  class Connection
    include HTTParty

    DEFAULT_VERSION  = "v1"
    DEFAULT_API_BASE_URI   = "http://api.unsplash.com"
    DEFAULT_OAUTH_BASE_URI = "http://www.unsplash.com"

    def initialize(application_id, application_secret, options = {})
      @application_id     = application_id
      @application_secret = application_secret
      @api_version        = options.fetch(:version, DEFAULT_VERSION)
      @api_base_uri       = options.fetch(:api_base_uri, DEFAULT_API_BASE_URI)
      @oauth_base_uri     = options.fetch(:oauth_base_uri, DEFAULT_OAUTH_BASE_URI)

      @oauth = ::OAuth2::Client.new(@application_id, @application_secret, site: @oauth_base_uri)

      Unsplash::Connection.base_uri @api_base_uri
    end

    def get(path)
      # TODO OAuth stuff.
      # TODO Error handling.
      self.class.get path, headers: auth_header
    end

    private

    def auth_header
      { "Authorization" => "Client-ID #{@application_id}" }
    end

  end


end
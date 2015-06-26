module Unsplash #:nodoc:

  # HTTP connection to and communication with the Unsplash API.
  class Connection
    include HTTParty

    # The version of the API being used if unspecified.
    DEFAULT_VERSION  = "v1"

    # Base URI for the Unsplash API..
    DEFAULT_API_BASE_URI   = "https://api.unsplash.com"

    # Base URI for Unsplash OAuth.
    DEFAULT_OAUTH_BASE_URI = "https://unsplash.com"

    # Create a Connection object.
    # @param version [String] The Unsplash API version to use.
    # @param api_base_uri [String] Base URI at which to make API calls.
    # @param oauth_base_uri [String] Base URI for OAuth requests.
    def initialize(version: DEFAULT_VERSION, api_base_uri: DEFAULT_API_BASE_URI, oauth_base_uri: DEFAULT_OAUTH_BASE_URI)
      @application_id     = Unsplash.configuration.application_id
      @application_secret = Unsplash.configuration.application_secret
      @api_version        = version
      @api_base_uri       = api_base_uri
      
      oauth_base_uri     = oauth_base_uri
      @oauth = ::OAuth2::Client.new(@application_id, @application_secret, site: oauth_base_uri) do |http|
        http.request :multipart
        http.request :url_encoded
        http.adapter :net_http
      end

      Unsplash::Connection.base_uri @api_base_uri
    end

    # Get OAuth URL for user authentication and authorization.
    # @param requested_scopes [Array] An array of permission scopes being requested.
    # @return [String] The authorization URL.
    def authorization_url(requested_scopes = ["public"])
      @oauth.auth_code.authorize_url(redirect_uri: Unsplash.configuration.application_redirect_uri,
                                     scope:        requested_scopes.join(" "))
    end

    # Generate an access token given an auth code received from Unsplash.
    # This is used internally to authenticate and authorize future user actions.
    # @param auth_code [String] The OAuth authentication code from Unsplash.
    def authorize!(auth_code)
      @oauth_token = @oauth.auth_code.get_token(auth_code, redirect_uri: Unsplash.configuration.application_redirect_uri)
      # TODO check if it succeeded
    end

    # Perform a GET request.
    # @param path [String] The path at which to make ther request.
    # @param params [Hash] A hash of request parameters.
    def get(path, params = {})
      request :get, path, params
    end

    # Perform a PUT request.
    # @param path [String] The path at which to make ther request.
    # @param params [Hash] A hash of request parameters.
    def put(path, params = {})
      request :put, path, params
    end

    # Perform a POST request.
    # @param path [String] The path at which to make ther request.
    # @param params [Hash] A hash of request parameters.
    def post(path, params = {})
      request :post, path, params
    end

    private

    def request(verb, path, params = {})
      raise ArgumentError.new "Invalid http verb #{verb}" if ![:get, :post, :put].include?(verb)

      headers = {
        "Accept-Version" => @api_version
        # Anything else? User agent?
      }

      response = if @oauth_token
        refresh_token!

        param_key = verb == :post ? :body : :params
        @oauth_token.public_send(verb,  @api_base_uri + path, param_key => params, headers: headers)
      
      else        
        self.class.public_send verb, path, query: params, headers: public_auth_header
      end

      status_code = response.respond_to?(:status) ? response.status : response.code

      if !(200..299).include?(status_code)
        body = JSON.parse(response.body)
        msg = body["error"] || body["errors"].join(" ")
        raise Unsplash::Error.new msg
      end

      response
    end

    def public_auth_header
      { "Authorization" => "Client-ID #{@application_id}" }
    end

    def refresh_token!
      return if !@oauth_token.expired?

      @oauth_token = @oauth_token.refresh_token
    end
  end


end
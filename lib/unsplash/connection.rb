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
      @application_access_key = Unsplash.configuration.application_access_key
      @application_secret = Unsplash.configuration.application_secret
      @api_version        = version
      @api_base_uri       = api_base_uri

      oauth_base_uri = oauth_base_uri
      @oauth = ::OAuth2::Client.new(@application_access_key, @application_secret, site: oauth_base_uri) do |http|
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

    # Extract hash with OAuth token attributes.  Extracted token attributes can
    # be used with create_and_assign_token to prevent the need for
    # reauthorization.
    # @return [Hash, nil] @oauth_token converted to a hash.
    def extract_token
      @oauth_token.to_hash if @oauth_token
    end

    # Create and assign new access token from extracted token.  To be used with
    # extract_token to reauthorize app without api call.
    # @param token_extract [Hash] OAuth token hash from #extract_token.
    # @return [OAuth2::AccessToken, nil] New access token object.
    def create_and_assign_token(token_extract)
      return if !token_extract
      @oauth_token = OAuth2::AccessToken.from_hash(@oauth, token_extract)
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

    # Perform a DELETE request.
    # @param path [String] The path at which to make ther request.
    # @param params [Hash] A hash of request parameters.
    def delete(path, params = {})
      request :delete, path, params
    end

    def utm_params
      {
        "utm_source"   => Unsplash.configuration.utm_source || "api_app",
        "utm_medium"   => "referral",
        "utm_campaign" => "api-credit"
      }
    end

    private

    def request(verb, path, params = {})
      raise ArgumentError.new "Invalid http verb #{verb}" if ![:get, :post, :put, :delete].include?(verb)

      params.merge!(utm_params)

      if !Unsplash.configuration.utm_source
        url = "https://help.unsplash.com/api-guidelines/unsplash-api-guidelines"
        Unsplash.configuration.logger.warn "utm_source is required as part of API Terms: #{url}"
      end

      headers = {
        "Accept-Version" => @api_version
        # Anything else? User agent?
      }

      response = begin
        if @oauth_token
          refresh_token!

          param_key = verb == :post ? :body : :params
          @oauth_token.public_send(verb,  @api_base_uri + path, param_key => params, headers: headers)
        else
          self.class.public_send verb, path, query: params, headers: public_auth_header
        end
      rescue OAuth2::Error => e
        OpenStruct.new(headers: {}, status: 403, body: e.error_message(e.response.body))
      end

      if response.headers["Warning"]
        Unsplash.configuration.logger.warn response.headers["Warning"]
      end

      status_code = response.respond_to?(:status) ? response.status : response.code

      case status_code
      when 200..299
        response
      when 401
        raise Unsplash::UnauthorizedError.new(error_message(response))
      when 403
        raise Unsplash::ForbiddenError.new(error_message(response))
      when 404
        raise Unsplash::NotFoundError.new(error_message(response))
      else
        raise Unsplash::Error.new(error_message(response))
      end

      response
    end

    def public_auth_header
      { "Authorization" => "Client-ID #{@application_access_key}" }
    end

    def refresh_token!
      return if !@oauth_token.expired?

      @oauth_token = @oauth_token.refresh_token
    end

    def error_message(response)
      body = JSON.parse(response.body)
      body["error"] || body["errors"].join(" ")
    rescue JSON::ParserError
      raise Unsplash::Error.new(response.body)
    end
  end
end

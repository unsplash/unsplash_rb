$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'unsplash'
require 'vcr'
require 'pry'
require 'coveralls'
require 'dotenv'
Coveralls.wear!
Dotenv.load("config.env")

Unsplash.configure do |config|
  config.application_access_key = ENV["UNSPLASH_ACCESS_KEY"]
  config.application_secret = ENV["UNSPLASH_SECRET_KEY"]
  config.utm_source = "unsplash_rb_specs"
end

VCR.configure do |config|
  config.default_cassette_options = { match_requests_on: [:method, :path, :query], record: :new_episodes }
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock

  config.register_request_matcher :auth_header do |request_1, request_2|
    request_1.headers["Authorization"] == request_2.headers["Authorization"]
  end

  config.before_record do |i|
    i.response.body.force_encoding("UTF-8")
  end

  config.filter_sensitive_data("<ACCESS_KEY>") { Unsplash.configuration.application_access_key }
  config.filter_sensitive_data("<APP_SECRET>") { Unsplash.configuration.application_secret }
  config.filter_sensitive_data("<API_URI>") { ENV.fetch("UNSPLASH_API_URI", "https://api.unsplash.com/") }
  config.filter_sensitive_data("<OAUTH_URI>") { ENV.fetch("UNSPLASH_OAUTH_URI", "https://unsplash.com/") }
end

RSpec.configure do |config|
  config.order = "random"

  config.before :each do |example|
    Unsplash::Client.connection = Unsplash::Connection.new(
                                  api_base_uri:   ENV.fetch("UNSPLASH_API_URI", "https://api.unsplash.com/"),
                                  oauth_base_uri: ENV.fetch("UNSPLASH_OAUTH_URI", "https://unsplash.com/"))

    if !example.metadata[:utm]
      allow_any_instance_of(Unsplash::Connection).to receive(:utm_params).and_return({})
    end
  end
end

def stub_oauth_authorization
  client = Unsplash::Client.connection.instance_variable_get(:@oauth)
  access_token = ::OAuth2::AccessToken.new(client, ENV["UNSPLASH_BEARER_TOKEN"])
  Unsplash::Client.connection.instance_variable_set(:@oauth_token, access_token)
end

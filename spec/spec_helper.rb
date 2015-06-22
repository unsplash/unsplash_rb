$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'unsplash'
require 'vcr'
require 'pry'

Unsplash.configure do |config|
  config.application_id = "baaa6a1214d50b3586bec6e06157aab859bd4d86dc0b755360f103f38974edc3"
  config.application_secret = "bb834160d12304045c55d0c0ec2eb0fe62a5fe249bc1a392386120d55eb2793a"
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
end


RSpec.configure do |config|

  config.order = "random"

  config.before :all do
    @test_connection = Unsplash::Connection.new(
                            Unsplash.configuration.application_id,
                            Unsplash.configuration.application_secret,
                            api_base_uri:   "http://api.lvh.me:3000",
                            oauth_base_uri: "http://www.lvh.me:3000")
  end

end

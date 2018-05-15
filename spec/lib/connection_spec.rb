require "spec_helper"

describe Unsplash::Connection do

  let(:connection) { Unsplash::Client.connection }

  describe "utm params", utm: true do
    before :each do
      response = double("response", status: 200, headers: {})
      allow(Unsplash::Connection).to receive(:get).and_return(response)
      Unsplash.configuration.logger = double("logger", warn: nil)
    end

    after :each do
      Unsplash.configuration.utm_source = "unsplash_rb_specs"
      Unsplash.configuration.logger = Logger.new(STDOUT)
    end

    it "warns if you don't have a utm_source" do
      Unsplash.configuration.utm_source = nil
      connection.get("/example.json")
      expect(Unsplash.configuration.logger).to have_received(:warn)
    end

    it "does not warn if you do have a utm_source" do
      Unsplash.configuration.utm_source = "my_app"
      connection.get("/example.json")
      expect(Unsplash.configuration.logger).to_not have_received(:warn)
    end

    it "appends the utm params" do
      headers = { "Authorization"=> "Client-ID #{Unsplash.configuration.application_access_key}" }
      params = {
        foo: "bar",
        utm_source:   "my_app",
        utm_medium:   "referral",
        utm_campaign: "api-credit"
      }

      Unsplash.configuration.utm_source = "my_app"
      connection.get("/example.json", { foo: "bar" })
      expect(Unsplash::Connection).to have_received(:get).with("/example.json", query: params, headers: headers)
    end
  end

  describe "#extract_token" do
    context "with an established connection" do
      it "returns @oauth_token converted to a hash" do
        stub_oauth_authorization

        VCR.use_cassette("connection") do
          @oauth_hash  = connection.extract_token
        end

        expect(@oauth_hash.keys).to include(
          :access_token, :refresh_token, :expires_at)
      end
    end

    context "without a connection" do
      it "returns nil" do
        VCR.use_cassette("connection") do
          @oauth_hash  = connection.extract_token
        end

        expect(@oath_hash).to be nil
      end
    end
  end

  describe "#create_and_assign_token" do
    context "with a valid oauth token" do
      it "creates a new OAuth2::AccessToken" do
        stub_oauth_authorization

        VCR.use_cassette("connection") do
          @oauth_hash  = connection.extract_token
        end

        @oauth_token = connection.create_and_assign_token(@oauth_hash)
        expect(@oauth_token).to be_an_instance_of(OAuth2::AccessToken)
      end

      it "allows a new connection to be established" do
        stub_oauth_authorization

        VCR.use_cassette("connection") do
          @oauth_hash  = connection.extract_token
        end

        @oath_token = connection.create_and_assign_token(@oauth_hash)
        VCR.use_cassette("collections") do
          @collection = Unsplash::Collection.create(
            title: "Ultimate Faves", private: true
          )
        end

        expect(@collection).to be_a Unsplash::Collection
      end
    end

    context "without a token" do
      it "returns nil" do
        VCR.use_cassette("connection") do
          @oauth_hash  = connection.extract_token
        end

        @oauth_token = connection.create_and_assign_token(@oauth_hash)
        expect(@oauth_token).to be nil
      end
    end
  end
end


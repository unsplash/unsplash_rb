require "spec_helper"

describe Unsplash::Connection do

  let(:connection) { Unsplash::Client.connection }

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


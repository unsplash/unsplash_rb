require "spec_helper"

describe Unsplash::User do

  let (:regularjoe) { "aarondev" }
  let (:photographer) { "lukechesser" }
  let (:fake) { "santa" }

  before :all do
    Unsplash::User.connection = @test_connection
  end

  describe "#find" do

    it "returns as User object" do
      VCR.use_cassette("users") do
        @user = Unsplash::User.find(regularjoe)
      end

      expect(@user).to be_an Unsplash::User
    end

    it "errors if the user does not exist" do
      expect {
        VCR.use_cassette("users") do
          @user = Unsplash::User.find(fake)
        end
      }.to raise_error Unsplash::Error
    end
  end

  describe "#photos" do

    it "returns an array of Photos" do
      VCR.use_cassette("users") do
        @photos = Unsplash::User.find(photographer).photos
      end

      expect(@photos).to be_an Array
      expect(@photos.size).to eq 8
    end

    it "returns empty array if the user does not have any photos" do
      VCR.use_cassette("users") do
        @photos = Unsplash::User.find(regularjoe).photos
      end

      expect(@photos).to be_empty
    end

    it "errors if the user does not exist" do
      expect {
        VCR.use_cassette("users") do
          @user = Unsplash::User.find(fake).photos
        end
      }.to raise_error Unsplash::Error
    end

  end


  describe "#current" do
    skip
  end

  describe "#update" do
    skip
  end
  
end
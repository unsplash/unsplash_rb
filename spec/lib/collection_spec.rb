require "spec_helper"

describe Unsplash::Collection do

  let (:collection_id) { 201 }
  let (:fake_id)  { 1234 }

  describe "#find" do
    it "returns a Collection object" do
      VCR.use_cassette("collections") do
        @collection = Unsplash::Collection.find(collection_id)
      end

      expect(@collection).to be_a Unsplash::Collection
    end

    it "errors if the collection doesn't exist" do
      expect {
        VCR.use_cassette("collections") do
          @collection = Unsplash::Collection.find(fake_id)
        end
      }.to raise_error Unsplash::Error
    end

    it "parses the nested user object" do
      VCR.use_cassette("collections") do
        @collection = Unsplash::Collection.find(collection_id)
      end

      expect(@collection.user).to be_an Unsplash::User
    end

    it "parses the cover photo" do
      VCR.use_cassette("collections") do
        @collection = Unsplash::Collection.find(collection_id)
      end

      expect(@collection.cover_photo).to be_an Unsplash::Photo
    end
  end

  describe "#all" do
    it "returns an array of Collections" do
      VCR.use_cassette("collections") do
        @collections = Unsplash::Collection.all(1, 12)
      end

      expect(@collections).to be_an Array
      expect(@collections.size).to eq 12
    end
    
    it "parses the nested user objects" do
      VCR.use_cassette("collections") do
        @collections = Unsplash::Collection.all(1, 12)
      end

      expect(@collections.map(&:user)).to all (be_an Unsplash::User)
    end

  end

  describe "#photos" do
    before :each do
      VCR.use_cassette("collections") do
        @photos = Unsplash::Collection.find(collection_id).photos
      end
    end

    it "returns an array of Photos" do
      expect(@photos).to be_an Array
      expect(@photos).to all (be_an Unsplash::Photo)
    end
  end
end
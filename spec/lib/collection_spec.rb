require "spec_helper"

describe Unsplash::Collection do

  let (:collection_id) { 201 }
  let (:fake_id)  { 987654321 }

  describe "#find" do
    it "returns a Collection object" do
      VCR.use_cassette("collections") do
        collection = Unsplash::Collection.find(collection_id)
        expect(collection).to be_a Unsplash::Collection
      end
    end

    it "errors if the collection doesn't exist" do
      expect {
        VCR.use_cassette("collections") do
          Unsplash::Collection.find(fake_id)
        end
      }.to raise_error Unsplash::NotFoundError
    end

    it "parses the nested user object" do
      VCR.use_cassette("collections") do
        collection = Unsplash::Collection.find(collection_id)
        expect(collection.user).to be_an Unsplash::User
      end
    end

    it "parses the cover photo" do
      VCR.use_cassette("collections") do
        collection = Unsplash::Collection.find(collection_id)
        expect(collection.cover_photo).to be_an Unsplash::Photo
      end
    end
  end

  describe "#search" do
    it "returns a SearchResult of Collections" do
      VCR.use_cassette("collections") do
        collections = Unsplash::Collection.search("explore", 1)
        expect(collections).to be_an Unsplash::SearchResult
        expect(collections.sample).to be_an Unsplash::Collection
        expect(collections.size).to be_a(Numeric)
        expect(collections.total).to be_a(Numeric)
        expect(collections.total_pages).to be_a(Numeric)
      end
    end

    it "returns an empty SearchResult if there are no users found" do
      VCR.use_cassette("collections") do
        collections = Unsplash::Collection.search("veryveryspecific", 1)
        expect(collections).to eq []
        expect(collections.total).to eq 0
        expect(collections.total_pages).to eq 0
      end
    end

    it "returns a SearchResult of Collections with number of elements per page defined" do
      VCR.use_cassette("collections") do
        collections = Unsplash::Collection.search("explore", 1, 2)
        expect(collections).to be_an Unsplash::SearchResult
        expect(collections.sample).to be_an Unsplash::Collection
        expect(collections.size).to be_a(Numeric)
        expect(collections.total).to be_a(Numeric)
        expect(collections.total_pages).to be_a(Numeric)
      end
    end
  end

  describe "#all" do
    it "returns an array of Collections" do
      VCR.use_cassette("collections") do
        collections = Unsplash::Collection.all(1, 12)
        expect(collections).to be_an Array
        expect(collections.size).to eq 12
      end
    end

    it "parses the nested user objects" do
      VCR.use_cassette("collections") do
        collections = Unsplash::Collection.all(1, 12)
        expect(collections.map(&:user)).to all (be_an Unsplash::User)
      end
    end
  end

  describe "#featured" do
    it "returns an array of featured collections" do
      VCR.use_cassette("collections") do
        collections = Unsplash::Collection.featured(1, 3)
        expect(collections).to be_an Array
        expect(collections.size).to eq 3
      end
    end
  end

  describe "#photos" do
    it "returns an array of Photos" do
      VCR.use_cassette("collections") do
        photos = Unsplash::Collection.find(collection_id).photos
        expect(photos).to be_an Array
        expect(photos).to all (be_an Unsplash::Photo)
      end
    end
  end

  describe "#create" do
    it "returns Collection object" do
      stub_oauth_authorization

      VCR.use_cassette("collections") do
        collection = Unsplash::Collection.create(title: "Ultimate Faves", private: true)
        expect(collection).to be_a Unsplash::Collection
      end
    end

    it "fails without Bearer token" do
      expect {
        VCR.use_cassette("collections", match_requests_on: [:method, :path, :body]) do
          Unsplash::Collection.create(title: "Pretty Good Pictures I Guess", private: true)
        end
      }.to raise_error Unsplash::UnauthorizedError
    end
  end

  describe "#update" do
    it "updates the Collection object" do
      stub_oauth_authorization

      VCR.use_cassette("collections") do
        collection = Unsplash::Collection.create(title: "Another Great Collection")
        collection = collection.update(title: "Best Picturez")
        expect(collection.title).to eq "Best Picturez"
      end
    end
  end

  describe "#destroy" do

    it "returns true on success" do
      stub_oauth_authorization
      VCR.use_cassette("collections") do
        collection = Unsplash::Collection.create(title: "Doomed!", private: true)
        expect(collection.destroy).to eq true
      end
    end

    it "raises on failure" do
      expect {
        stub_oauth_authorization
        VCR.use_cassette("collections") do
          collection = Unsplash::Collection.find(4397795) # exists but does not belong to user
          collection.destroy
        end
      }.to raise_error OAuth2::Error
    end

  end

  describe "#add" do
    before :each do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.find("tAKXap853rY")
      end
    end

    it "returns a metadata hash" do
      stub_oauth_authorization

      VCR.use_cassette("collections") do
        collection = Unsplash::Collection.create(title: "Super addable", private: true)
        meta = collection.add(@photo)
        expect(meta[:collection_id]).to eq collection.id
        expect(meta[:photo_id]).to eq @photo.id
      end
    end
  end

  describe "#remove" do
    before :each do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.find("tAKXap853rY")
      end
    end

    it "returns true on success" do
      stub_oauth_authorization
      VCR.use_cassette("collections") do
        collection = Unsplash::Collection.create(title: "Super removable", private: true)
        collection.add(@photo)
        expect(collection.remove(@photo)).to be true
      end
    end
  end

end

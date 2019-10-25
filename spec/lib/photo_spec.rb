require "spec_helper"

describe Unsplash::Photo do

  describe "#find" do
    let(:photo_id) { "tAKXap853rY" }
    let(:fake_id)  { "abc123" }

    it "returns a Photo object" do
      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.find(photo_id)
        expect(photo).to be_a Unsplash::Photo
      end
    end

    it "errors if the photo doesn't exist" do
      expect {
        VCR.use_cassette("photos") do
          @photo = Unsplash::Photo.find(fake_id)
        end
      }.to raise_error Unsplash::NotFoundError
    end

    it "parses the nested user object" do
      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.find(photo_id)
        expect(photo.user).to be_an Unsplash::User
      end
    end

    it "supports nested method access" do
      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.find(photo_id)
        expect(photo.user.links.html).to match /@alejandroescamilla/
      end
    end
  end

  describe "#random" do
    it "returns a Photo object" do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.random
      end

      expect(@photo).to be_a Unsplash::Photo
    end

    it "errors if there are no photos to choose from" do
      expect {
        VCR.use_cassette("photos") do
          Unsplash::Photo.random(user: "bigfoot_aint_real_either")
        end
      }.to raise_error Unsplash::NotFoundError
    end

    it "parses the nested user object" do
      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.random
        expect(photo.user).to be_an Unsplash::User
      end
    end

    context "with collections" do
      it "joins them" do
        expect(Unsplash::Photo.connection)
          .to receive(:get).with("/photos/random", collections: "4,5,6")
          .and_return double(body: "{}")

        photo = Unsplash::Photo.random(collections: [4,5,6])
      end
    end

    context "with orientation" do
      it "returns a landscaped photo" do

        VCR.use_cassette("photos") do
          @photo = Unsplash::Photo.random(orientation: :landscape)
        end

        expect(@photo).to be_a Unsplash::Photo
      end
    end

    it "logs warning when supplying both collections and query filters" do
      allow(Unsplash::Photo.connection).to receive(:get).and_return(double(body: '{ "id": "definitely_a_photo" }'))
      allow(Unsplash.configuration.logger).to receive(:warn).and_call_original

      Unsplash::Photo.random(collections: [4,5,6], query: "cute dogs")
      expect(Unsplash.configuration.logger).to have_received(:warn)
    end
  end

  describe "#search" do
    it "returns a SearchResult of Photos" do
      VCR.use_cassette("photos") do
        @photos = Unsplash::Photo.search("dog", 1)
      end

      expect(@photos).to be_an Unsplash::SearchResult
      expect(@photos.size).to eq 10
      expect(@photos.total).to be_a(Numeric)
      expect(@photos.total_pages).to be_a(Numeric)
    end

    it "returns a SearchResult of Photos with number of elements per page defined" do
      VCR.use_cassette("photos") do
        @photos = Unsplash::Photo.search("dog", 1, 3)
      end

      expect(@photos).to be_an Unsplash::SearchResult
      expect(@photos.size).to eq 3
      expect(@photos.total).to be_a(Numeric)
      expect(@photos.total_pages).to be_a(Numeric)
    end

    it "returns a SearchResult of Photos with orientation parameter" do
      VCR.use_cassette("photos") do
        @photos = Unsplash::Photo.search("dog", 1, 3, :portrait)
      end

      expect(@photos).to be_an Unsplash::SearchResult
      expect(@photos.size).to eq 3
    end
  end

  describe "#index" do
    it "returns an array of Photos" do
      VCR.use_cassette("photos") do
        @photos = Unsplash::Photo.all(1, 6)
      end

      expect(@photos).to be_an Array
      expect(@photos.size).to eq 6
    end

    it "returns an array of Photos order by oldest criteria" do
      VCR.use_cassette("photos") do
        @photos = Unsplash::Photo.all(1, 6, "oldest")
      end

      expect(@photos).to be_an Array
      expect(@photos.size).to eq 6
    end
  end

  describe "#like!" do
    let(:photo_id) { "tAKXap853rY" }

    it "returns true on success" do
      stub_oauth_authorization

      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.find(photo_id)
        expect(photo.like!).to eq true
      end
    end

    it "raises UnauthorizedError when not logged in" do
      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.new(id: "abc123")
        expect {
          photo.like!
        }.to raise_error Unsplash::UnauthorizedError
      end
    end
  end

  describe "#unlike!" do
    let(:photo_id) { "tAKXap853rY" }

    it "returns true on success" do
      stub_oauth_authorization

      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.find(photo_id)
        expect(photo.unlike!).to eq true
      end
    end

    it "raises UnauthorizedError when not logged in" do
      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.new(id: "abc123")
        expect {
          photo.unlike!
        }.to raise_error Unsplash::UnauthorizedError
      end
    end
  end

  describe "#track_download" do
    it "returns the URL" do
      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.find("tAKXap853rY")
        expect(photo.track_download).to match /macbook-air-all-faded-and-stuff.jpg/
      end
    end

    it "makes a request to Unsplash" do
      allow(Unsplash::Photo.connection).to receive(:get).and_call_original

      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.find("tAKXap853rY")
        photo.track_download
        expect(Unsplash::Photo.connection).to have_received(:get).with(photo.links.download_location)
      end
    end
  end
end

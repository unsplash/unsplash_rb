require "spec_helper"

describe Unsplash::Category do

  before :all do
    Unsplash::Category.connection = @test_connection
  end

  let (:category_id) { 7 }
  let (:fake_id)     { 42 }

  describe "#find" do
    it "returns a Category object" do
      VCR.use_cassette("categories") do
        @photo = Unsplash::Category.find(category_id)
      end

      expect(@photo).to be_a Unsplash::Category
    end

    it "errors if the category doesn't exist" do
      expect {
        VCR.use_cassette("categories") do
          @category = Unsplash::Category.find(fake_id)
        end
      }.to raise_error Unsplash::Error
    end
  end

  describe "#all" do
    it "returns an array of Categories" do
      VCR.use_cassette("categories") do
        @categories = Unsplash::Category.all
      end

      expect(@categories).to be_an Array
      expect(@categories.size).to eq 6
    end
  end

  describe "#photos" do
    it "returns an array of Photos" do
      VCR.use_cassette("categories") do
        @photos = Unsplash::Category.find(category_id).photos(1, 13)
      end

      expect(@photos).to be_an Array
      expect(@photos.size).to eq 13
    end
  end
end
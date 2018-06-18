require "spec_helper"

describe Unsplash::Category do

  let (:category_id) { 7 }

  describe "#find" do
    it "returns a Category object" do
      expect {
        VCR.use_cassette("categories") do
          @category = Unsplash::Category.find(category_id)
        end
      }.to raise_error Unsplash::DeprecationError
    end
  end

  describe "#all" do
    it "returns an array of Categories" do
      expect {
        VCR.use_cassette("categories") do
          @categories = Unsplash::Category.all
        end
      }.to raise_error Unsplash::DeprecationError
    end
  end

  describe "#photos" do
    it "returns an array of Photos" do
      expect {
        VCR.use_cassette("categories") do
          @photos = Unsplash::Category.find(category_id).photos(1, 13)
        end
      }.to raise_error Unsplash::DeprecationError
    end
  end
end

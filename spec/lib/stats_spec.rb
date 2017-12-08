require "spec_helper"

describe Unsplash::Stats do

  describe "#total" do
    let (:stats_hash) do
      {
        "total_photos" => 373132,
        "photo_downloads" => 265475445,
        "photos" => 373132,
        "downloads" => 265475445,
        "views" => 38628516221,
        "likes" => 7020656,
        "photographers" => 62861,
        "pixels" => 5414747434353,
        "downloads_per_second" => 8,
        "views_per_second" => 1904,
        "developers" => 20974,
        "applications" => 1226,
        "requests" => 4591220993
      }
    end

    it "returns the stats" do
      VCR.use_cassette("stats") do
        @counts = Unsplash::Stats.total
      end

      expect(@counts).to eq stats_hash
    end
  end

end
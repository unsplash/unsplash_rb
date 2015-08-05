require "spec_helper"

describe Unsplash::Stats do

  describe "#total" do
    let (:stats_hash) { {"photo_downloads" => 50, "batch_downloads" => 100} }

    it "returns the stats" do
      VCR.use_cassette("stats") do
        @counts = Unsplash::Stats.total
      end

      expect(@counts).to eq stats_hash
    end
  end

end
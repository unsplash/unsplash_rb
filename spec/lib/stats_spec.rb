require "spec_helper"

describe Unsplash::Stats do

  describe "#total" do
    it "returns the stats" do
      VCR.use_cassette("stats") do
        counts = Unsplash::Stats.total
        expect(counts).to be_a(Hash)
        expect(counts.values).to all be_a(Numeric)
      end
    end
  end

end

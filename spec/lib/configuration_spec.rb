require "spec_helper"

describe Unsplash::Configuration do
  describe "using deprecated application_id" do
    before :each do
      @old_value = Unsplash.configuration.application_access_key
    end

    after :each do
      Unsplash.configuration.application_access_key = @old_value
    end

    it "still assigns the value" do
      Unsplash.configure do |config|
        config.application_id = "access key"
      end

      expect(Unsplash.configuration.application_access_key).to eq "access key"
    end

    it "logs a warning" do
      allow(Unsplash.configuration.logger).to receive(:warn)

      Unsplash.configure do |config|
        config.application_id = "access key"
      end

      expect(Unsplash.configuration.logger).to have_received(:warn)
    end
  end
end

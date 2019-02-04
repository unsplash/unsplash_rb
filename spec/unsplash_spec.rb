require 'spec_helper'

describe Unsplash do
  it 'has a version number' do
    expect(Unsplash::VERSION).not_to be nil
  end

  it "logs warning response headers" do
    response = double(body: "[]", status: 200, headers: { "Warning" => "Watch out!" })
    allow(Unsplash::Connection).to receive(:get).and_return(response)

    expect(Unsplash.configuration.logger).to receive(:warn).with("Watch out!")
    Unsplash::CuratedBatch.all
  end

  it "handles 5** errors as Unsplash Errors" do
    response = double(
      body: "We are experiencing errors. Please check https://status.unsplash.com for updates.",
      status: 503,
      headers: { "Content-Type" => "text/plain" }
    )
    allow(Unsplash::Connection).to receive(:public_send).and_return(response)

    expect { Unsplash::CuratedBatch.all }.to raise_error(Unsplash::Error)
  end
end

# spec/Net/HTTP/Report_spec.rb

require_relative '../../spec_helper'
require 'Net/HTTP/Report'

describe Net::HTTP::Report do
  it "is a subclass of Net::HTTPRequest" do
    expect(Net::HTTP::Report).to be <= Net::HTTPRequest
  end

  it "has the correct METHOD" do
    expect(Net::HTTP::Report::METHOD).to eq('REPORT')
  end

  it "accepts a body" do
    expect(Net::HTTP::Report::REQUEST_HAS_BODY).to eq(true)
  end

  it "expects a response body" do
    expect(Net::HTTP::Report::RESPONSE_HAS_BODY).to eq(true)
  end
end

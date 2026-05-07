# spec/HTTP/head_spec.rb

require_relative '../spec_helper'
require 'http'

describe ".head" do
  context "with uri-only supplied" do
    before do
      stub_request(:head, 'http://example.com/path').
        to_return(status: 200, body: '', headers: {'Content-Type' => 'text/html'})
    end

    context "uri as a string" do
      let(:uri){'http://example.com/path'}

      it "returns a successful response" do
        response = HTTP.head(uri)
        expect(response.success?).to eq(true)
      end
    end

    context "uri as a URI" do
      let(:uri){URI.parse('http://example.com/path')}

      it "returns a successful response" do
        response = HTTP.head(uri)
        expect(response.success?).to eq(true)
      end
    end
  end

  context "with args supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:head, 'http://example.com/path?a=1&b=2').
        to_return(status: 200, body: '', headers: {})
    end

    it "appends query parameters" do
      response = HTTP.head(uri, {a: 1, b: 2})
      expect(response.success?).to eq(true)
    end
  end

  context "with headers supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:head, 'http://example.com/path').
        with(headers: {'User-Agent' => 'Rspec'}).
        to_return(status: 200, body: '', headers: {})
    end

    it "sets the headers on the request" do
      response = HTTP.head(uri, {}, {'User-Agent' => 'Rspec'})
      expect(response.success?).to eq(true)
    end
  end

  context "with options supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:head, 'https://example.com:80/path').
        to_return(status: 200, body: '', headers: {})
    end

    it "sets the use_ssl option on the Net::HTTP instance" do
      response = HTTP.head(uri, {}, {}, {use_ssl: true})
      expect(response.success?).to eq(true)
    end
  end

  context "with block supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:head, 'http://example.com/path').
        to_return(status: 200, body: '', headers: {})
    end

    it "yields an instance of Net::HTTPResponse" do
      expect{|b| HTTP.head(uri, &b)}.to yield_with_args(Net::HTTPResponse)
    end
  end

  context "with redirection" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}

    before do
      stub_request(:head, request_uri).
        to_return(status: 301, headers: {'location' => redirect_uri})
      stub_request(:get, redirect_uri).
        to_return(status: 200, body: '', headers: {})
    end

    it "follows the redirect" do
      response = HTTP.head(request_uri)
      expect(response.success?).to eq(true)
    end
  end

  context "no_redirect true" do
    let(:request_uri){'http://example.com/path'}

    before do
      stub_request(:head, request_uri).
        to_return(status: 301, headers: {'location' => 'http://redirected.com'})
    end

    it "returns the redirect response" do
      response = HTTP.head(request_uri, {}, {}, {no_redirect: true})
      expect(response.redirection?).to eq(true)
    end
  end
end

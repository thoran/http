# spec/HTTP/propfind_spec.rb

require_relative '../spec_helper'
require 'http'

describe ".propfind" do
  context "with uri-only supplied" do
    before do
      stub_request(:propfind, 'http://example.com/dav/').
        to_return(status: 207, body: '<multistatus/>', headers: {})
    end

    context "uri as a string" do
      let(:uri){'http://example.com/dav/'}

      it "returns a response" do
        response = HTTP.propfind(uri)
        expect(response.code).to eq('207')
      end
    end

    context "uri as a URI" do
      let(:uri){URI.parse('http://example.com/dav/')}

      it "returns a response" do
        response = HTTP.propfind(uri)
        expect(response.code).to eq('207')
      end
    end
  end

  context "with an XML body" do
    let(:uri){'http://example.com/dav/'}
    let(:xml) do
      '<?xml version="1.0" encoding="UTF-8"?><d:propfind xmlns:d="DAV:"><d:prop><d:displayname/></d:prop></d:propfind>'
    end

    before do
      stub_request(:propfind, 'http://example.com/dav/').
        with(body: xml).
        to_return(status: 207, body: '<multistatus/>', headers: {})
    end

    it "sends the XML body" do
      response = HTTP.propfind(uri, xml, {'Content-Type' => 'application/xml'})
      expect(response.code).to eq('207')
    end
  end

  context "with headers supplied" do
    let(:uri){'http://example.com/dav/'}

    before do
      stub_request(:propfind, 'http://example.com/dav/').
        with(headers: {'Depth' => '1', 'Content-Type' => 'application/xml'}).
        to_return(status: 207, body: '<multistatus/>', headers: {})
    end

    it "sets the headers on the request" do
      response = HTTP.propfind(uri, {}, {'Depth' => '1', 'Content-Type' => 'application/xml'})
      expect(response.code).to eq('207')
    end
  end

  context "with options supplied" do
    let(:uri){'http://example.com/dav/'}

    before do
      stub_request(:propfind, 'https://example.com:80/dav/').
        to_return(status: 207, body: '<multistatus/>', headers: {})
    end

    it "sets the use_ssl option on the Net::HTTP instance" do
      response = HTTP.propfind(uri, {}, {}, {use_ssl: true})
      expect(response.code).to eq('207')
    end
  end

  context "with block supplied" do
    let(:uri){'http://example.com/dav/'}

    before do
      stub_request(:propfind, 'http://example.com/dav/').
        to_return(status: 207, body: '<multistatus/>', headers: {})
    end

    it "yields an instance of Net::HTTPResponse" do
      expect{|b| HTTP.propfind(uri, &b)}.to yield_with_args(Net::HTTPResponse)
    end
  end

  context "with redirection" do
    let(:request_uri){'http://example.com/dav/'}
    let(:redirect_uri){'http://redirected.com/dav/'}

    before do
      stub_request(:propfind, request_uri).
        to_return(status: 301, headers: {'location' => redirect_uri})
      stub_request(:get, redirect_uri).
        to_return(status: 200, body: '', headers: {})
    end

    it "follows the redirect" do
      response = HTTP.propfind(request_uri)
      expect(response.success?).to eq(true)
    end
  end

  context "no_redirect true" do
    let(:request_uri){'http://example.com/dav/'}

    before do
      stub_request(:propfind, request_uri).
        to_return(status: 301, headers: {'location' => 'http://redirected.com/dav/'})
    end

    it "returns the redirect response" do
      response = HTTP.propfind(request_uri, {}, {}, {no_redirect: true})
      expect(response.redirection?).to eq(true)
    end
  end
end

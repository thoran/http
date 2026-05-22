# test/HTTP/head_test.rb

require_relative '../helper'

describe ".head" do
  describe "with uri-only supplied" do
    before do
      stub_request(:head, 'http://example.com/path').
        to_return(status: 200, body: '', headers: {'Content-Type' => 'text/html'})
    end

    describe "uri as a string" do
      let(:uri){'http://example.com/path'}

      it "returns a successful response" do
        response = HTTP.head(uri)
        _(response.success?).must_equal(true)
      end
    end

    describe "uri as a URI" do
      let(:uri){URI.parse('http://example.com/path')}

      it "returns a successful response" do
        response = HTTP.head(uri)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with args supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:head, 'http://example.com/path?a=1&b=2').
        to_return(status: 200, body: '', headers: {})
    end

    it "appends query parameters" do
      response = HTTP.head(uri, {a: 1, b: 2})
      _(response.success?).must_equal(true)
    end
  end

  describe "with headers supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:head, 'http://example.com/path').
        with(headers: {'User-Agent' => 'Minitest'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the headers on the request" do
      response = HTTP.head(uri, {}, {'User-Agent' => 'Minitest'})
      _(response.success?).must_equal(true)
    end
  end

  describe "with options supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:head, 'https://example.com:80/path').
        to_return(status: 200, body: '', headers: {})
    end

    it "sets the use_ssl option on the Net::HTTP instance" do
      response = HTTP.head(uri, {}, {}, {use_ssl: true})
      _(response.success?).must_equal(true)
    end
  end

  describe "with block supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:head, 'http://example.com/path').
        to_return(status: 200, body: '', headers: {})
    end

    it "yields an instance of Net::HTTPResponse" do
      yielded = nil
      HTTP.head(uri){|response| yielded = response}
      _(yielded).must_be_kind_of(Net::HTTPResponse)
    end
  end

  describe "with redirection" do
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
      _(response.success?).must_equal(true)
      assert_requested(:head, request_uri)
      assert_requested(:get, redirect_uri)
    end
  end

  describe "no_redirect true" do
    let(:request_uri){'http://example.com/path'}

    before do
      stub_request(:head, request_uri).
        to_return(status: 301, headers: {'location' => 'http://redirected.com'})
    end

    it "returns the redirect response without following it" do
      response = HTTP.head(request_uri, {}, {}, {no_redirect: true})
      _(response.redirection?).must_equal(true)
    end
  end
end

# test/HTTP/basic_auth_test.rb

require_relative '../helper'

describe "basic auth" do
  describe "via the options hash" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:get, uri).
        to_return(status: 200, body: '', headers: {})
    end

    it "sets the Authorization header from the username and password options" do
      request_object = Net::HTTP::Get.new(parsed_uri.request_uri)
      Net::HTTP::Get.stub(:new, request_object) do
        response = HTTP.get(uri, {}, {}, {username: 'alice', password: 'secret'})
        _(request_object['Authorization']).must_equal("Basic #{['alice:secret'].pack('m0')}")
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "via the URI" do
    let(:uri){'http://alice:secret@example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:get, 'http://example.com/path').
        to_return(status: 200, body: '', headers: {})
    end

    it "sets the Authorization header from the embedded credentials" do
      request_object = Net::HTTP::Get.new(parsed_uri.request_uri)
      Net::HTTP::Get.stub(:new, request_object) do
        response = HTTP.get(uri)
        _(request_object['Authorization']).must_equal("Basic #{['alice:secret'].pack('m0')}")
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with a username but no password" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:get, uri).
        to_return(status: 200, body: '', headers: {})
    end

    it "sends an empty password" do
      request_object = Net::HTTP::Get.new(parsed_uri.request_uri)
      Net::HTTP::Get.stub(:new, request_object) do
        response = HTTP.get(uri, {}, {}, {username: 'alice'})
        _(request_object['Authorization']).must_equal("Basic #{['alice:'].pack('m0')}")
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with credentials in both the options hash and the URI" do
    let(:uri){'http://alice:secret@example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:get, 'http://example.com/path').
        to_return(status: 200, body: '', headers: {})
    end

    it "prefers the options credentials over the URI credentials" do
      request_object = Net::HTTP::Get.new(parsed_uri.request_uri)
      Net::HTTP::Get.stub(:new, request_object) do
        response = HTTP.get(uri, {}, {}, {username: 'bob', password: 'hunter2'})
        _(request_object['Authorization']).must_equal("Basic #{['bob:hunter2'].pack('m0')}")
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "leakage into Net::HTTP options" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:get, uri).
        to_return(status: 200, body: '', headers: {})
    end

    it "does not pass the auth options through to Net::HTTP" do
      passed_options = nil
      net_http_object = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
      original_options_setter = net_http_object.method(:options=)
      net_http_object.define_singleton_method(:options=) do |options|
        passed_options = options
        original_options_setter.call(options)
      end
      Net::HTTP.stub(:new, net_http_object) do
        HTTP.get(uri, {}, {}, {username: 'alice', password: 'secret'})
      end
      _(passed_options.key?(:username)).must_equal(false)
      _(passed_options.key?(:password)).must_equal(false)
    end
  end
end

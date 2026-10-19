# test/HTTP/request_without_body_test.rb

require_relative '../helper'

describe ".request_without_body" do
  let(:uri){'http://example.com/path'}
  let(:parsed_uri){URI.parse(uri)}

  describe "without args" do
    before do
      stub_request(:get, 'http://example.com/path').
        to_return(status: 200, body: '', headers: {})
    end

    it "builds the request object for the given method" do
      received_arg = nil
      request_object = Net::HTTP::Get.new(parsed_uri.request_uri)
      Net::HTTP::Get.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.request_without_body(:get, uri)
        _(received_arg).must_equal(parsed_uri.request_uri)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with args" do
    before do
      stub_request(:get, 'http://example.com/path?a=1&b=2').
        to_return(status: 200, body: '', headers: {})
    end

    it "appends the encoded query string to the request uri" do
      received_arg = nil
      request_uri = parsed_uri.request_uri + '?a=1&b=2'
      request_object = Net::HTTP::Get.new(request_uri)
      Net::HTTP::Get.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.request_without_body(:get, uri, {a: 1, b: 2})
        _(received_arg).must_equal(request_uri)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with args and a query already in the uri" do
    let(:uri){'http://example.com/path?x=1'}

    before do
      stub_request(:get, 'http://example.com/path?x=1&a=1').
        to_return(status: 200, body: '', headers: {})
    end

    it "joins the args to the query with an ampersand" do
      received_arg = nil
      request_object = Net::HTTP::Get.new('/path?x=1&a=1')
      Net::HTTP::Get.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.request_without_body(:get, uri, {a: 1})
        _(received_arg).must_equal('/path?x=1&a=1')
        _(response.success?).must_equal(true)
      end
    end

    it "is requested so by HTTP.get" do
      response = HTTP.get(uri, {a: 1})
      _(response.success?).must_equal(true)
      assert_requested(:get, 'http://example.com/path?x=1&a=1')
    end
  end

  describe "with an array among the args" do
    before do
      stub_request(:get, 'http://example.com/path?tags=1&tags=2').
        to_return(status: 200, body: '', headers: {})
    end

    it "repeats the key for each element" do
      received_arg = nil
      request_object = Net::HTTP::Get.new('/path?tags=1&tags=2')
      Net::HTTP::Get.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.request_without_body(:get, uri, {tags: [1, 2]})
        _(received_arg).must_equal('/path?tags=1&tags=2')
        _(response.success?).must_equal(true)
      end
    end

    it "is requested so by HTTP.get" do
      response = HTTP.get(uri, {tags: [1, 2]})
      _(response.success?).must_equal(true)
      assert_requested(:get, 'http://example.com/path?tags=1&tags=2')
    end
  end

  describe "delegation from the named method" do
    it "is reached by HTTP.get with the verb prepended" do
      received_args = nil
      HTTP.stub(:request_without_body, ->(*args, &block){received_args = args; nil}) do
        HTTP.get(uri, {a: 1}, {'User-Agent' => 'Minitest'}, {use_ssl: false})
      end
      _(received_args).must_equal([:get, uri, {a: 1}, {'User-Agent' => 'Minitest'}, {use_ssl: false}])
    end
  end
end

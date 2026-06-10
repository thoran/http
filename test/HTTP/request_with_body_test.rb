# test/HTTP/request_with_body_test.rb

require_relative '../helper'

describe ".request_with_body" do
  let(:uri){'http://example.com/path'}
  let(:parsed_uri){URI.parse(uri)}

  describe "with a string body" do
    let(:body){'raw body'}

    before do
      stub_request(:post, 'http://example.com/path').
        with(body: body).
          to_return(status: 200, body: '', headers: {})
    end

    it "passes the string through unchanged" do
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, request_object) do
        response = HTTP.request_with_body(:post, uri, body)
        _(request_object.body).must_equal(body)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with a JSON content type" do
    let(:data){{a: 1, b: 2}}
    let(:headers){{'Content-Type' => 'application/json'}}

    before do
      stub_request(:post, 'http://example.com/path').
        with(body: JSON.dump(data)).
          to_return(status: 200, body: '', headers: {})
    end

    it "JSON-encodes the data" do
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, request_object) do
        response = HTTP.request_with_body(:post, uri, data, headers)
        _(request_object.body).must_equal(JSON.dump(data))
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with no content type" do
    let(:data){{a: 1, b: 2}}

    before do
      stub_request(:post, 'http://example.com/path').
        with(body: data.x_www_form_urlencode).
          to_return(status: 200, body: '', headers: {})
    end

    it "form-encodes the data" do
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, request_object) do
        response = HTTP.request_with_body(:post, uri, data)
        _(request_object.body).must_equal(data.x_www_form_urlencode)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "delegation from the named method" do
    it "is reached by HTTP.post with the verb prepended" do
      received_args = nil
      HTTP.stub(:request_with_body, ->(*args, &block){received_args = args; nil}) do
        HTTP.post(uri, {a: 1}, {'User-Agent' => 'Minitest'}, {use_ssl: false})
      end
      _(received_args).must_equal([:post, uri, {a: 1}, {'User-Agent' => 'Minitest'}, {use_ssl: false}])
    end
  end
end

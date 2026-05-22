# test/HTTP/options_test.rb

require_relative '../helper'

describe ".options" do
  describe "with uri-only supplied" do
    before do
      stub_request(:options, 'http://example.com/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    describe "uri as a string" do
      let(:uri){'http://example.com/path'}

      it "creates an instance of URI" do
        received_arg = nil
        parsed_uri = URI.parse(uri)
        URI.stub(:parse, ->(arg){received_arg = arg; parsed_uri}) do
          response = HTTP.options(uri)
          _(received_arg).must_equal(uri)
          _(response.success?).must_equal(true)
        end
      end

      it "creates a new Net::HTTP object" do
        received_args = nil
        parsed_uri = URI.parse(uri)
        net_http_object = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
        Net::HTTP.stub(:new, ->(*args){received_args = args; net_http_object}) do
          response = HTTP.options(uri)
          _(received_args).must_equal([parsed_uri.host, parsed_uri.port])
          _(response.success?).must_equal(true)
        end
      end
    end

    describe "uri as a URI" do
      let(:uri){URI.parse('http://example.com/path')}

      it "creates a new Net::HTTP object" do
        received_args = nil
        net_http_object = Net::HTTP.new(uri.host, uri.port)
        Net::HTTP.stub(:new, ->(*args){received_args = args; net_http_object}) do
          response = HTTP.options(uri)
          _(received_args).must_equal([uri.host, uri.port])
          _(response.success?).must_equal(true)
        end
      end
    end
  end

  describe "with args supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:options, 'http://example.com/path?a=1&b=2').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "x_www_form_urlencode's the args" do
      args = {a: 1, b: 2}
      called = false
      args.stub(:x_www_form_urlencode, ->{called = true; 'a=1&b=2'}) do
        response = HTTP.options(uri, args)
        _(called).must_equal(true)
        _(response.success?).must_equal(true)
      end
    end

    it "creates a new Net::HTTP::Options object" do
      received_arg = nil
      options_argument = parsed_uri.request_uri + '?a=1&b=2'
      request_object = Net::HTTP::Options.new(options_argument)
      Net::HTTP::Options.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.options(uri, {a: 1, b: 2})
        _(received_arg).must_equal(options_argument)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with headers supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:options, 'http://example.com/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Minitest'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the headers on the request object" do
      request_object = Net::HTTP::Options.new(parsed_uri.request_uri)
      Net::HTTP::Options.stub(:new, request_object) do
        response = HTTP.options(uri, {}, {'User-Agent' => 'Minitest'})
        _(request_object['User-Agent']).must_equal('Minitest')
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with options supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:options, 'https://example.com:80/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the use_ssl option on the Net::HTTP instance" do
      net_http_object = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
      Net::HTTP.stub(:new, net_http_object) do
        response = HTTP.options(uri, {}, {}, {use_ssl: true})
        _(net_http_object.instance_variable_get(:@use_ssl)).must_equal(true)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with block supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:options, 'http://example.com/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "yields an instance of Net::HTTPResponse" do
      yielded = nil
      HTTP.options(uri){|response| yielded = response}
      _(yielded).must_be_kind_of(Net::HTTPResponse)
    end
  end

  describe "with redirection" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}

    before do
      stub_request(:get, redirect_uri).
        to_return(status: 200, body: '', headers: {})
    end

    describe "via 301" do
      before do
        stub_request(:options, request_uri).
          to_return(status: 301, headers: {'location' => redirect_uri})
      end

      it "follows the redirect" do
        response = HTTP.options(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:options, request_uri)
        assert_requested(:get, redirect_uri)
      end
    end

    describe "via 302" do
      before do
        stub_request(:options, request_uri).
          to_return(status: 302, headers: {'location' => redirect_uri})
      end

      it "follows the redirect" do
        response = HTTP.options(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:options, request_uri)
        assert_requested(:get, redirect_uri)
      end
    end
  end

  describe "with path only redirection" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_path){'/new_path'}
    let(:redirect_uri){"http://example.com#{redirect_path}"}

    before do
      stub_request(:get, redirect_uri).
        to_return(status: 200, body: '', headers: {})
    end

    describe "via 301" do
      before do
        stub_request(:options, request_uri).
          to_return(status: 301, headers: {'location' => redirect_path})
      end

      it "resolves the relative redirect against the original URI" do
        response = HTTP.options(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:get, redirect_uri)
      end
    end

    describe "via 302" do
      before do
        stub_request(:options, request_uri).
          to_return(status: 302, headers: {'location' => redirect_path})
      end

      it "resolves the relative redirect against the original URI" do
        response = HTTP.options(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:get, redirect_uri)
      end
    end
  end

  describe "no_redirect true" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}

    describe "via 301" do
      before do
        stub_request(:options, request_uri).
          to_return(status: 301, headers: {'location' => redirect_uri})
      end

      it "returns the redirect response without following it" do
        response = HTTP.options(request_uri, {}, {}, {no_redirect: true})
        _(response.redirection?).must_equal(true)
        assert_not_requested(:get, redirect_uri)
      end
    end

    describe "via 302" do
      before do
        stub_request(:options, request_uri).
          to_return(status: 302, headers: {'location' => redirect_uri})
      end

      it "returns the redirect response without following it" do
        response = HTTP.options(request_uri, {}, {}, {no_redirect: true})
        _(response.redirection?).must_equal(true)
        assert_not_requested(:get, redirect_uri)
      end
    end
  end
end

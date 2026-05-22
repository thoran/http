# test/HTTP/put_test.rb

require_relative '../helper'

describe ".put" do
  describe "with uri-only supplied" do
    before do
      stub_request(:put, 'http://example.com/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    describe "uri as a string" do
      let(:uri){'http://example.com/path'}

      it "creates an instance of URI" do
        received_arg = nil
        parsed_uri = URI.parse(uri)
        URI.stub(:parse, ->(arg){received_arg = arg; parsed_uri}) do
          response = HTTP.put(uri)
          _(received_arg).must_equal(uri)
          _(response.success?).must_equal(true)
        end
      end

      it "creates a new Net::HTTP object" do
        received_args = nil
        parsed_uri = URI.parse(uri)
        net_http_object = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
        Net::HTTP.stub(:new, ->(*args){received_args = args; net_http_object}) do
          response = HTTP.put(uri)
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
          response = HTTP.put(uri)
          _(received_args).must_equal([uri.host, uri.port])
          _(response.success?).must_equal(true)
        end
      end
    end
  end

  describe "with form data supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:args){{a: 1, b: 2}}
    let(:headers){{'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}}
    let(:encoded_form_data){args.x_www_form_urlencode}

    before do
      stub_request(:put, 'http://example.com/path').
        with(body: encoded_form_data, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the form data" do
      request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
      Net::HTTP::Put.stub(:new, request_object) do
        response = HTTP.put(uri, args, headers)
        _(request_object.body).must_equal(encoded_form_data)
        _(response.success?).must_equal(true)
      end
    end

    it "creates a new Net::HTTP::Put object" do
      received_arg = nil
      request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
      Net::HTTP::Put.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.put(uri, args, headers)
        _(received_arg).must_equal(parsed_uri.request_uri)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with raw form data supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:args){{a: 1, b: 2}.x_www_form_urlencode}
    let(:headers){{'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}}

    before do
      stub_request(:put, 'http://example.com/path').
        with(body: args, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the form data" do
      request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
      Net::HTTP::Put.stub(:new, request_object) do
        response = HTTP.put(uri, args, headers)
        _(request_object.body).must_equal(args)
        _(response.success?).must_equal(true)
      end
    end

    it "creates a new Net::HTTP::Put object" do
      received_arg = nil
      request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
      Net::HTTP::Put.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.put(uri, args, headers)
        _(received_arg).must_equal(parsed_uri.request_uri)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with JSON data supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:args){{a: 1, b: 2}}
    let(:headers){{'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby'}}
    let(:json_data){JSON.dump(args)}

    before do
      stub_request(:put, 'http://example.com/path').
        with(body: json_data, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the body" do
      request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
      Net::HTTP::Put.stub(:new, request_object) do
        response = HTTP.put(uri, args, headers)
        _(request_object.body).must_equal(json_data)
        _(response.success?).must_equal(true)
      end
    end

    it "creates a new Net::HTTP::Put object" do
      received_arg = nil
      request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
      Net::HTTP::Put.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.put(uri, args, headers)
        _(received_arg).must_equal(parsed_uri.request_uri)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with raw JSON data supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:args){JSON.dump({a: 1, b: 2})}
    let(:headers){{'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Ruby'}}

    before do
      stub_request(:put, 'http://example.com/path').
        with(body: args, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the body" do
      request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
      Net::HTTP::Put.stub(:new, request_object) do
        response = HTTP.put(uri, args, headers)
        _(request_object.body).must_equal(args)
        _(response.success?).must_equal(true)
      end
    end

    it "creates a new Net::HTTP::Put object" do
      received_arg = nil
      request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
      Net::HTTP::Put.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.put(uri, args, headers)
        _(received_arg).must_equal(parsed_uri.request_uri)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with headers supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:put, 'http://example.com/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Minitest'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the headers on the request object" do
      request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
      Net::HTTP::Put.stub(:new, request_object) do
        response = HTTP.put(uri, {}, {'User-Agent' => 'Minitest'})
        _(request_object['User-Agent']).must_equal('Minitest')
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "when different content-type header key cases are supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:args){{a: 1, b: 2}}

    before do
      stub_request(:put, 'http://example.com/path').
        with(headers: {'Content-Type' => 'application/json'}).
          to_return(status: 200, body: '', headers: {})
    end

    describe "title-cased" do
      it "detects the content type" do
        request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
        Net::HTTP::Put.stub(:new, request_object) do
          HTTP.put(uri, args, {'Content-Type' => 'application/json'})
          _(request_object['Content-Type']).must_equal('application/json')
          _(request_object.body).must_equal(JSON.dump(args))
        end
      end
    end

    describe "title-case only at the start" do
      it "detects the content type" do
        request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
        Net::HTTP::Put.stub(:new, request_object) do
          HTTP.put(uri, args, {'Content-type' => 'application/json'})
          _(request_object['Content-Type']).must_equal('application/json')
          _(request_object.body).must_equal(JSON.dump(args))
        end
      end
    end

    describe "lowercase" do
      it "detects the content type" do
        request_object = Net::HTTP::Put.new(parsed_uri.request_uri)
        Net::HTTP::Put.stub(:new, request_object) do
          HTTP.put(uri, args, {'content-type' => 'application/json'})
          _(request_object['Content-Type']).must_equal('application/json')
          _(request_object.body).must_equal(JSON.dump(args))
        end
      end
    end
  end

  describe "with options supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:put, 'https://example.com:80/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the use_ssl option on the Net::HTTP instance" do
      net_http_object = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
      Net::HTTP.stub(:new, net_http_object) do
        response = HTTP.put(uri, {}, {}, {use_ssl: true})
        _(net_http_object.instance_variable_get(:@use_ssl)).must_equal(true)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with block supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:put, 'http://example.com/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "yields an instance of Net::HTTPResponse" do
      yielded = nil
      HTTP.put(uri){|response| yielded = response}
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
        stub_request(:put, request_uri).
          to_return(status: 301, headers: {'location' => redirect_uri})
      end

      it "follows the redirect with GET" do
        response = HTTP.put(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:put, request_uri)
        assert_requested(:get, redirect_uri)
      end
    end

    describe "via 302" do
      before do
        stub_request(:put, request_uri).
          to_return(status: 302, headers: {'location' => redirect_uri})
      end

      it "follows the redirect with GET" do
        response = HTTP.put(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:put, request_uri)
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
        stub_request(:put, request_uri).
          to_return(status: 301, headers: {'location' => redirect_path})
      end

      it "resolves the relative redirect against the original URI" do
        response = HTTP.put(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:get, redirect_uri)
      end
    end

    describe "via 302" do
      before do
        stub_request(:put, request_uri).
          to_return(status: 302, headers: {'location' => redirect_path})
      end

      it "resolves the relative redirect against the original URI" do
        response = HTTP.put(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:get, redirect_uri)
      end
    end
  end

  describe "with verb-preserving redirection via 307" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}

    before do
      stub_request(:put, request_uri).
        to_return(status: 307, headers: {'location' => redirect_uri})
      stub_request(:put, redirect_uri).
        to_return(status: 200, body: '', headers: {})
    end

    it "preserves the verb" do
      response = HTTP.put(request_uri)
      _(response.success?).must_equal(true)
      assert_requested(:put, request_uri)
      assert_requested(:put, redirect_uri)
    end
  end

  describe "no_redirect true" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}

    describe "via 301" do
      before do
        stub_request(:put, request_uri).
          to_return(status: 301, headers: {'location' => redirect_uri})
      end

      it "returns the redirect response without following it" do
        response = HTTP.put(request_uri, {}, {}, {no_redirect: true})
        _(response.redirection?).must_equal(true)
        assert_not_requested(:get, redirect_uri)
      end
    end

    describe "via 302" do
      before do
        stub_request(:put, request_uri).
          to_return(status: 302, headers: {'location' => redirect_uri})
      end

      it "returns the redirect response without following it" do
        response = HTTP.put(request_uri, {}, {}, {no_redirect: true})
        _(response.redirection?).must_equal(true)
        assert_not_requested(:get, redirect_uri)
      end
    end
  end
end

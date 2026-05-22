# test/HTTP/post_test.rb

require_relative '../helper'

describe ".post" do
  describe "with uri-only supplied" do
    before do
      stub_request(:post, 'http://example.com/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    describe "uri as a string" do
      let(:uri){'http://example.com/path'}

      it "creates an instance of URI" do
        received_arg = nil
        parsed_uri = URI.parse(uri)
        URI.stub(:parse, ->(arg){received_arg = arg; parsed_uri}) do
          response = HTTP.post(uri)
          _(received_arg).must_equal(uri)
          _(response.success?).must_equal(true)
        end
      end

      it "creates a new Net::HTTP object" do
        received_args = nil
        parsed_uri = URI.parse(uri)
        net_http_object = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
        Net::HTTP.stub(:new, ->(*args){received_args = args; net_http_object}) do
          response = HTTP.post(uri)
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
          response = HTTP.post(uri)
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
      stub_request(:post, 'http://example.com/path').
        with(body: encoded_form_data, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the form data" do
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, request_object) do
        response = HTTP.post(uri, args, headers)
        _(request_object.body).must_equal(encoded_form_data)
        _(response.success?).must_equal(true)
      end
    end

    it "creates a new Net::HTTP::Post object" do
      received_arg = nil
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.post(uri, args, headers)
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
      stub_request(:post, 'http://example.com/path').
        with(body: args, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the form data" do
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, request_object) do
        response = HTTP.post(uri, args, headers)
        _(request_object.body).must_equal(args)
        _(response.success?).must_equal(true)
      end
    end

    it "creates a new Net::HTTP::Post object" do
      received_arg = nil
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.post(uri, args, headers)
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
      stub_request(:post, 'http://example.com/path').
        with(body: json_data, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the body" do
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, request_object) do
        response = HTTP.post(uri, args, headers)
        _(request_object.body).must_equal(json_data)
        _(response.success?).must_equal(true)
      end
    end

    it "creates a new Net::HTTP::Post object" do
      received_arg = nil
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.post(uri, args, headers)
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
      stub_request(:post, 'http://example.com/path').
        with(body: args, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the body" do
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, request_object) do
        response = HTTP.post(uri, args, headers)
        _(request_object.body).must_equal(args)
        _(response.success?).must_equal(true)
      end
    end

    it "creates a new Net::HTTP::Post object" do
      received_arg = nil
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, ->(arg){received_arg = arg; request_object}) do
        response = HTTP.post(uri, args, headers)
        _(received_arg).must_equal(parsed_uri.request_uri)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with headers supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}

    before do
      stub_request(:post, 'http://example.com/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Minitest'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the headers on the request object" do
      request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
      Net::HTTP::Post.stub(:new, request_object) do
        response = HTTP.post(uri, {}, {'User-Agent' => 'Minitest'})
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
      stub_request(:post, 'http://example.com/path').
        with(headers: {'Content-Type' => 'application/json'}).
          to_return(status: 200, body: '', headers: {})
    end

    describe "title-cased" do
      it "detects the content type" do
        request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
        Net::HTTP::Post.stub(:new, request_object) do
          HTTP.post(uri, args, {'Content-Type' => 'application/json'})
          _(request_object['Content-Type']).must_equal('application/json')
          _(request_object.body).must_equal(JSON.dump(args))
        end
      end
    end

    describe "title-case only at the start" do
      it "detects the content type" do
        request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
        Net::HTTP::Post.stub(:new, request_object) do
          HTTP.post(uri, args, {'Content-type' => 'application/json'})
          _(request_object['Content-Type']).must_equal('application/json')
          _(request_object.body).must_equal(JSON.dump(args))
        end
      end
    end

    describe "lowercase" do
      it "detects the content type" do
        request_object = Net::HTTP::Post.new(parsed_uri.request_uri)
        Net::HTTP::Post.stub(:new, request_object) do
          HTTP.post(uri, args, {'content-type' => 'application/json'})
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
      stub_request(:post, 'https://example.com:80/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the use_ssl option on the Net::HTTP instance" do
      net_http_object = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
      Net::HTTP.stub(:new, net_http_object) do
        response = HTTP.post(uri, {}, {}, {use_ssl: true})
        _(net_http_object.instance_variable_get(:@use_ssl)).must_equal(true)
        _(response.success?).must_equal(true)
      end
    end
  end

  describe "with block supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:post, 'http://example.com/path').
        with(headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "yields an instance of Net::HTTPResponse" do
      yielded = nil
      HTTP.post(uri){|response| yielded = response}
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
        stub_request(:post, request_uri).
          to_return(status: 301, headers: {'location' => redirect_uri})
      end

      it "follows the redirect with GET" do
        response = HTTP.post(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:post, request_uri)
        assert_requested(:get, redirect_uri)
      end
    end

    describe "via 302" do
      before do
        stub_request(:post, request_uri).
          to_return(status: 302, headers: {'location' => redirect_uri})
      end

      it "follows the redirect with GET" do
        response = HTTP.post(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:post, request_uri)
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
        stub_request(:post, request_uri).
          to_return(status: 301, headers: {'location' => redirect_path})
      end

      it "resolves the relative redirect against the original URI" do
        response = HTTP.post(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:get, redirect_uri)
      end
    end

    describe "via 302" do
      before do
        stub_request(:post, request_uri).
          to_return(status: 302, headers: {'location' => redirect_path})
      end

      it "resolves the relative redirect against the original URI" do
        response = HTTP.post(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:get, redirect_uri)
      end
    end
  end

  describe "with verb-preserving redirection" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}

    before do
      stub_request(:post, redirect_uri).
        to_return(status: 200, body: '', headers: {})
    end

    describe "via 307" do
      before do
        stub_request(:post, request_uri).
          to_return(status: 307, headers: {'location' => redirect_uri})
      end

      it "preserves the verb" do
        response = HTTP.post(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:post, request_uri)
        assert_requested(:post, redirect_uri)
      end
    end

    describe "via 308" do
      before do
        stub_request(:post, request_uri).
          to_return(status: 308, headers: {'location' => redirect_uri})
      end

      it "preserves the verb" do
        response = HTTP.post(request_uri)
        _(response.success?).must_equal(true)
        assert_requested(:post, request_uri)
        assert_requested(:post, redirect_uri)
      end
    end
  end

  describe "with body-preserving redirection via 307" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}
    let(:args){{a: 1, b: 2}}
    let(:encoded_form_data){args.x_www_form_urlencode}

    before do
      stub_request(:post, request_uri).
        with(body: encoded_form_data).
          to_return(status: 307, headers: {'location' => redirect_uri})
      stub_request(:post, redirect_uri).
        with(body: encoded_form_data).
          to_return(status: 200, body: '', headers: {})
    end

    it "preserves the body" do
      response = HTTP.post(request_uri, args)
      _(response.success?).must_equal(true)
    end
  end

  describe "no_redirect true" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}

    describe "via 301" do
      before do
        stub_request(:post, request_uri).
          to_return(status: 301, headers: {'location' => redirect_uri})
      end

      it "returns the redirect response without following it" do
        response = HTTP.post(request_uri, {}, {}, {no_redirect: true})
        _(response.redirection?).must_equal(true)
        assert_not_requested(:get, redirect_uri)
      end
    end

    describe "via 302" do
      before do
        stub_request(:post, request_uri).
          to_return(status: 302, headers: {'location' => redirect_uri})
      end

      it "returns the redirect response without following it" do
        response = HTTP.post(request_uri, {}, {}, {no_redirect: true})
        _(response.redirection?).must_equal(true)
        assert_not_requested(:get, redirect_uri)
      end
    end
  end
end

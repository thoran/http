# spec/HTTP/post_spec.rb

require_relative '../spec_helper'
require 'http'

describe ".post" do
  context "with uri-only supplied" do
    before do
      stub_request(:post, 'http://example.com/path').
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    context "uri as a string" do
      let(:uri){'http://example.com/path'}
      let(:parsed_uri){URI.parse(uri)}
      let(:net_http_object){Net::HTTP.new(parsed_uri.host, parsed_uri.port)}

      it "creates an instance of URI" do
        expect(URI).to receive(:parse).with(uri).and_return(parsed_uri)
        response = HTTP.post(uri)
        expect(response.success?).to eq(true)
      end

      it "creates a new Net::HTTP object" do
        expect(Net::HTTP).to receive(:new).with(parsed_uri.host, parsed_uri.port).and_return(net_http_object)
        response = HTTP.post(uri)
        expect(response.success?).to eq(true)
      end
    end

    context "uri as a URI" do
      let(:uri_string){'http://example.com/path'}
      let(:uri){URI.parse(uri_string)}
      let(:net_http_object){Net::HTTP.new(uri.host, uri.port)}

      it "returns an instance of URI" do
        expect(uri).to eq(uri)
        response = HTTP.post(uri)
        expect(response.success?).to eq(true)
      end

      it "creates a new Net::HTTP object" do
        expect(Net::HTTP).to receive(:new).with(uri.host, uri.port).and_return(net_http_object)
        response = HTTP.post(uri)
        expect(response.success?).to eq(true)
      end
    end
  end

  context "with form data supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:args) do; {a: 1, b: 2}; end
    let(:headers) do; {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}; end
    let(:encoded_form_data){args.x_www_form_urlencode}
    let(:request_uri){parsed_uri.request_uri}
    let(:request_object){Net::HTTP::Post.new(request_uri)}

    before do
      stub_request(:post, "http://example.com/path").
        with(body: encoded_form_data, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the form data" do
      allow(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
      response = HTTP.post(uri, args, headers)
      expect(request_object.body).to eq(encoded_form_data)
      expect(response.success?).to eq(true)
    end

    it "creates a new Net::HTTP::Post object" do
      expect(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
      response = HTTP.post(uri, args, headers)
      expect(response.success?).to eq(true)
    end
  end

  context "with raw form data supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:args) do; {a: 1, b: 2}.x_www_form_urlencode; end
    let(:headers) do; {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}; end
    let(:encoded_form_data){args}
    let(:request_uri){parsed_uri.request_uri}
    let(:request_object){Net::HTTP::Post.new(request_uri)}

    before do
      stub_request(:post, "http://example.com/path").
        with(body: encoded_form_data, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the form data" do
      allow(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
      response = HTTP.post(uri, args, headers)
      expect(request_object.body).to eq(encoded_form_data)
      expect(response.success?).to eq(true)
    end

    it "creates a new Net::HTTP::Post object" do
      expect(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
      response = HTTP.post(uri, args, headers)
      expect(response.success?).to eq(true)
    end
  end

  context "with JSON data supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:args) do; {a: 1, b: 2}; end
    let(:headers) do; {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}; end
    let(:json_data){JSON.dump(args)}
    let(:request_uri){parsed_uri.request_uri}
    let(:request_object){Net::HTTP::Post.new(request_uri)}

    before do
      stub_request(:post, "http://example.com/path").
        with(body: json_data, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the body" do
      allow(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
      response = HTTP.post(uri, args, headers)
      expect(request_object.body).to eq(json_data)
      expect(response.success?).to eq(true)
    end

    it "creates a new Net::HTTP::Post object" do
      expect(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
      response = HTTP.post(uri, args, headers)
      expect(response.success?).to eq(true)
    end
  end

  context "with raw JSON data supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:args) do; JSON.dump({a: 1, b: 2}); end
    let(:headers) do; {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}; end
    let(:json_data){args}
    let(:request_uri){parsed_uri.request_uri}
    let(:request_object){Net::HTTP::Post.new(request_uri)}

    before do
      stub_request(:post, "http://example.com/path").
        with(body: json_data, headers: headers).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the body" do
      allow(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
      response = HTTP.post(uri, args, headers)
      expect(request_object.body).to eq(json_data)
      expect(response.success?).to eq(true)
    end

    it "creates a new Net::HTTP::Post object" do
      expect(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
      response = HTTP.post(uri, args, headers)
      expect(response.success?).to eq(true)
    end
  end

  context "with headers supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:headers) do; {'User-Agent' => 'Rspec'}; end
    let(:request_uri){parsed_uri.request_uri}
    let(:request_object){Net::HTTP::Post.new(request_uri)}

    before do
      stub_request(:post, 'http://example.com/path').
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Rspec'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the headers on the request object" do
      allow(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
      response = HTTP.post(uri, {}, headers)
      expect(request_object['User-Agent']).to eq('Rspec')
      expect(response.success?).to eq(true)
    end
  end

  context "when different content-type header key cases are supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:headers) do; {content_type_key => 'application/json'}; end
    let(:request_uri){parsed_uri.request_uri}
    let(:request_object){Net::HTTP::Post.new(request_uri)}
    let(:args)do; {a: 1, b: 2}; end

    before do
      stub_request(:post, 'http://example.com/path').
        with(headers: {'Content-Type'=>'application/json'}).
          to_return(status: 200, body: '', headers: {})
    end

    context "title-cased" do
      let(:content_type_key){'Content-Type'}

      it "detects the content type" do
        allow(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
        response = HTTP.post(uri, args, headers)
        expect(request_object['Content-Type']).to eq('application/json') # The request object doesn't care about the case of the content-type key.
        expect(request_object.body).to eq(JSON.dump(args))
      end
    end

    context "title-case only at the start" do
      let(:content_type_key){'Content-type'}

      it "detects the content type" do
        allow(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
        response = HTTP.post(uri, args, headers)
        expect(request_object['Content-Type']).to eq('application/json') # The request object doesn't care about the case of the content-type key.
        expect(request_object.body).to eq(JSON.dump(args))
      end
    end

    context "lowercase" do
      let(:content_type_key){'content-type'}

      it "detects the content type" do
        allow(Net::HTTP::Post).to receive(:new).with(request_uri).and_return(request_object)
        response = HTTP.post(uri, args, headers)
        expect(request_object['Content-Type']).to eq('application/json') # The request object doesn't care about the case of the content-type key.
        expect(request_object.body).to eq(JSON.dump(args))
      end
    end
  end

  context "with options supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:net_http_object){Net::HTTP.new(parsed_uri.host, parsed_uri.port)}
    let(:options) do; {use_ssl: true}; end

    before do
      stub_request(:post, 'https://example.com:80/path').
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the use_ssl option on the Net::HTTP instance" do
      allow(Net::HTTP).to receive(:new).with(parsed_uri.host, parsed_uri.port).and_return(net_http_object)
      response = HTTP.post(uri, {}, {}, options)
      expect(net_http_object.instance_variable_get(:@use_ssl)).to be_truthy
      expect(response.success?).to eq(true)
    end
  end

  context "with block supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:post, 'http://example.com/path').
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "yields an instance of Net::HTTPResponse" do
      expect{|b| HTTP.post(uri, &b)}.to yield_with_args(Net::HTTPResponse)
    end
  end

  context "with redirection" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}

    before do
      stub_request(:get, redirect_uri).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    context "via 301" do
      before do
        stub_request(:post, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 301, body: '', headers: {'location' => redirect_uri})
      end

      it "does a redirect" do
        expect(HTTP).to receive(:post).once.with(request_uri).and_call_original
        expect(HTTP).to receive(:get).once.with(redirect_uri, {}, {}, {use_ssl: false, verify_mode: 0}).and_call_original
        response = HTTP.post(request_uri)
        expect(response.success?).to eq(true)
      end
    end

    context "via 302" do
      before do
        stub_request(:post, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 302, body: '', headers: {'location' => redirect_uri})
      end

      it "does a redirect" do
        expect(HTTP).to receive(:post).once.with(request_uri).and_call_original
        expect(HTTP).to receive(:get).once.with(redirect_uri, {}, {}, {use_ssl: false, verify_mode: 0}).and_call_original
        response = HTTP.post(request_uri)
        expect(response.success?).to eq(true)
      end
    end
  end

  context "with path only redirection" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_path){'/new_path'}
    let(:redirect_uri){"http://example.com:80#{redirect_path}"}

    before do
      stub_request(:get, redirect_uri).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    context "via 301" do
      before do
        stub_request(:post, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 301, body: '', headers: {'location' => redirect_path})
      end

      it "does a redirect" do
        expect(HTTP).to receive(:post).once.with(request_uri).and_call_original
        expect(HTTP).to receive(:get).once.with(redirect_uri, {}, {}, {use_ssl: false, verify_mode: 0}).and_call_original
        response = HTTP.post(request_uri)
        expect(response.success?).to eq(true)
      end
    end

    context "via 302" do
      before do
        stub_request(:post, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
            to_return(status: 302, body: '', headers: {'location' => redirect_path})
      end

      it "does a redirect" do
        expect(HTTP).to receive(:post).once.with(request_uri).and_call_original
        expect(HTTP).to receive(:get).once.with(redirect_uri, {}, {}, {use_ssl: false, verify_mode: 0}).and_call_original
        response = HTTP.post(request_uri)
        expect(response.success?).to eq(true)
      end
    end
  end

  context "no_redirect true" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}

    context "via 301" do
      before do
        stub_request(:post, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 301, body: '', headers: {'location' => redirect_uri})
      end

      it "doesn't redirect" do
        expect(HTTP).to receive(:post).once.with(request_uri, {}, {}, {no_redirect: true}).and_call_original
        response = HTTP.post(request_uri, {}, {}, {no_redirect: true})
        expect(response.redirection?).to eq(true)
      end
    end

    context "via 302" do
      before do
        stub_request(:post, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 302, body: '', headers: {'location' => redirect_uri})
      end

      it "doesn't redirect" do
        expect(HTTP).to receive(:post).once.with(request_uri, {}, {}, {no_redirect: true}).and_call_original
        response = HTTP.post(request_uri, {}, {}, {no_redirect: true})
        expect(response.redirection?).to eq(true)
      end
    end
  end
end

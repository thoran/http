# spec/HTTP/trace_spec.rb

require_relative '../spec_helper'
require 'http'

describe ".trace" do
  context "with uri-only supplied" do
    before do
      stub_request(:trace, 'http://example.com/path').
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    context "uri as a string" do
      let(:uri){'http://example.com/path'}
      let(:parsed_uri){URI.parse(uri)}
      let(:net_http_object){Net::HTTP.new(parsed_uri.host, parsed_uri.port)}

      it "creates an instance of URI" do
        expect(URI).to receive(:parse).with(uri).and_return(parsed_uri)
        response = HTTP.trace(uri)
        expect(response.success?).to eq(true)
      end

      it "creates a new Net::HTTP object" do
        expect(Net::HTTP).to receive(:new).with(parsed_uri.host, parsed_uri.port).and_return(net_http_object)
        response = HTTP.trace(uri)
        expect(response.success?).to eq(true)
      end
    end

    context "uri as a URI" do
      let(:uri_string){'http://example.com/path'}
      let(:uri){URI.parse(uri_string)}
      let(:net_http_object){Net::HTTP.new(uri.host, uri.port)}

      it "returns an instance of URI" do
        expect(uri).to eq(uri)
        HTTP.trace(uri)
      end

      it "creates a new Net::HTTP object" do
        expect(Net::HTTP).to receive(:new).with(uri.host, uri.port).and_return(net_http_object)
        response = HTTP.trace(uri)
        expect(response.success?).to eq(true)
      end
    end
  end

  context "with args supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:args) do; {a: 1, b: 2}; end
    let(:x_www_form_urlencoded_arguments) do; args.x_www_form_urlencode; end
    let(:trace_argument){parsed_uri.request_uri + '?' + x_www_form_urlencoded_arguments}
    let(:request_object){Net::HTTP::Trace.new(trace_argument)}

    before do
      stub_request(:trace, 'http://example.com/path?a=1&b=2').
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "x_www_form_urlencode's the args" do
      expect(args).to receive(:x_www_form_urlencode).and_return(x_www_form_urlencoded_arguments)
      response = HTTP.trace(uri, args)
      expect(response.success?).to eq(true)
    end

    it "creates a new Net::HTTP::Trace object" do
      expect(Net::HTTP::Trace).to receive(:new).with(trace_argument).and_return(request_object)
      response = HTTP.trace(uri, args)
      expect(response.success?).to eq(true)
    end
  end

  context "with headers supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:headers) do; {'User-Agent' => 'Rspec'}; end
    let(:trace_argument){parsed_uri.request_uri}
    let(:request_object){Net::HTTP::Trace.new(trace_argument)}

    before do
      stub_request(:trace, 'http://example.com/path').
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Rspec'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the headers on the request object" do
      allow(Net::HTTP::Trace).to receive(:new).with(trace_argument).and_return(request_object)
      response = HTTP.trace(uri, {}, headers)
      expect(request_object['User-Agent']).to eq('Rspec')
      expect(response.success?).to eq(true)
    end
  end

  context "with options supplied" do
    let(:uri){'http://example.com/path'}
    let(:parsed_uri){URI.parse(uri)}
    let(:net_http_object){Net::HTTP.new(parsed_uri.host, parsed_uri.port)}
    let(:options) do; {use_ssl: true}; end

    before do
      stub_request(:trace, 'https://example.com:80/path').
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "sets the use_ssl option on the Net::HTTP instance" do
      allow(Net::HTTP).to receive(:new).with(parsed_uri.host, parsed_uri.port).and_return(net_http_object)
      response = HTTP.trace(uri, {}, {}, options)
      expect(net_http_object.instance_variable_get(:@use_ssl)).to be_truthy
      expect(response.success?).to eq(true)
    end
  end

  context "with block supplied" do
    let(:uri){'http://example.com/path'}

    before do
      stub_request(:trace, 'http://example.com/path').
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    it "yields an instance of Net::HTTPResponse" do
      expect{|b| HTTP.trace(uri, &b)}.to yield_with_args(Net::HTTPResponse)
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
        stub_request(:trace, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 301, body: '', headers: {'location' => redirect_uri})
      end

      it "does a redirect" do
        expect(HTTP).to receive(:trace).once.with(request_uri).and_call_original
        expect(HTTP).to receive(:get).once.with(redirect_uri, {}, {}, {use_ssl: false, verify_mode: OpenSSL::SSL::VERIFY_PEER}).and_call_original
        response = HTTP.trace(request_uri)
        expect(response.success?).to eq(true)
      end
    end

    context "via 302" do
      before do
        stub_request(:trace, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 302, body: '', headers: {'location' => redirect_uri})
      end

      it "does a redirect" do
        expect(HTTP).to receive(:trace).once.with(request_uri).and_call_original
        expect(HTTP).to receive(:get).once.with(redirect_uri, {}, {}, {use_ssl: false, verify_mode: OpenSSL::SSL::VERIFY_PEER}).and_call_original
        response = HTTP.trace(request_uri)
        expect(response.success?).to eq(true)
      end
    end
  end

  context "with path only redirection" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_path){'/new_path'}
    let(:redirect_uri){"http://example.com#{redirect_path}"}

    before do
      stub_request(:get, redirect_uri).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(status: 200, body: '', headers: {})
    end

    context "via 301" do
      before do
        stub_request(:trace, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 301, body: '', headers: {'location' => redirect_path})
      end

      it "does a redirect" do
        expect(HTTP).to receive(:trace).once.with(request_uri).and_call_original
        expect(HTTP).to receive(:get).once.with(redirect_uri, {}, {}, {use_ssl: false, verify_mode: OpenSSL::SSL::VERIFY_PEER}).and_call_original
        response = HTTP.trace(request_uri)
        expect(response.success?).to eq(true)
      end
    end

    context "via 302" do
      before do
        stub_request(:trace, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 302, body: '', headers: {'location' => redirect_path})
      end

      it "does a redirect" do
        expect(HTTP).to receive(:trace).once.with(request_uri).and_call_original
        expect(HTTP).to receive(:get).once.with(redirect_uri, {}, {}, {use_ssl: false, verify_mode: OpenSSL::SSL::VERIFY_PEER}).and_call_original
        response = HTTP.trace(request_uri)
        expect(response.success?).to eq(true)
      end
    end
  end

  context "no_redirect true" do
    let(:request_uri){'http://example.com/path'}
    let(:redirect_uri){'http://redirected.com'}

    context "via 301" do
      before do
        stub_request(:trace, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 301, body: '', headers: {'location' => redirect_uri})
      end

      it "doesn't redirect" do
        expect(HTTP).to receive(:trace).once.with(request_uri, {}, {}, {no_redirect: true}).and_call_original
        response = HTTP.trace(request_uri, {}, {}, {no_redirect: true})
        expect(response.redirection?).to eq(true)
      end
    end

    context "via 302" do
      before do
        stub_request(:trace, request_uri).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(status: 302, body: '', headers: {'location' => redirect_uri})
      end

      it "doesn't redirect" do
        expect(HTTP).to receive(:trace).once.with(request_uri, {}, {}, {no_redirect: true}).and_call_original
        response = HTTP.trace(request_uri, {}, {}, {no_redirect: true})
        expect(response.redirection?).to eq(true)
      end
    end
  end
end

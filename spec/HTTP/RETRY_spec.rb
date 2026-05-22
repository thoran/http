# spec/HTTP/RETRY_spec.rb

require_relative '../spec_helper'
require 'http'

describe "retry behaviour" do
  let(:uri){'http://example.com/path'}

  before do
    allow(HTTP::RETRY).to receive(:sleep)
  end

  describe "defaults" do
    it "does not retry by default" do
      stub_request(:get, uri).to_return(status: 503)
      response = HTTP.get(uri)
      expect(response.code.to_i).to eq(503)
      expect(WebMock).to have_requested(:get, uri).times(1)
    end

    it "does not retry on a transient exception by default" do
      stub_request(:get, uri).to_raise(Errno::ECONNRESET)
      expect{HTTP.get(uri)}.to raise_error(Errno::ECONNRESET)
      expect(WebMock).to have_requested(:get, uri).times(1)
    end
  end

  describe "retry on transient exception" do
    it "retries and succeeds when the failure is transient" do
      stub_request(:get, uri).
        to_raise(Errno::ECONNRESET).then.
        to_raise(Errno::ECONNRESET).then.
        to_return(status: 200, body: '')
      response = HTTP.get(uri, {}, {}, {retries: 3})
      expect(response.success?).to eq(true)
      expect(WebMock).to have_requested(:get, uri).times(3)
    end

    it "re-raises the exception after retries are exhausted" do
      stub_request(:get, uri).to_raise(Errno::ECONNRESET)
      expect{HTTP.get(uri, {}, {}, {retries: 2})}.to raise_error(Errno::ECONNRESET)
      expect(WebMock).to have_requested(:get, uri).times(3)
    end

    it "retries on SocketError (DNS failure)" do
      stub_request(:get, uri).
        to_raise(SocketError).then.
        to_return(status: 200, body: '')
      response = HTTP.get(uri, {}, {}, {retries: 3})
      expect(response.success?).to eq(true)
      expect(WebMock).to have_requested(:get, uri).times(2)
    end

    it "does not retry on a non-listed exception" do
      stub_request(:get, uri).to_raise(OpenSSL::SSL::SSLError)
      expect{HTTP.get(uri, {}, {}, {retries: 3})}.to raise_error(OpenSSL::SSL::SSLError)
      expect(WebMock).to have_requested(:get, uri).times(1)
    end
  end

  describe "retry on status code" do
    it "retries on 503 then succeeds" do
      stub_request(:get, uri).
        to_return({status: 503}, {status: 503}, {status: 200, body: ''})
      response = HTTP.get(uri, {}, {}, {retries: 3})
      expect(response.success?).to eq(true)
      expect(WebMock).to have_requested(:get, uri).times(3)
    end

    it "retries on 502" do
      stub_request(:get, uri).to_return({status: 502}, {status: 200, body: ''})
      response = HTTP.get(uri, {}, {}, {retries: 3})
      expect(response.success?).to eq(true)
      expect(WebMock).to have_requested(:get, uri).times(2)
    end

    it "retries on 504" do
      stub_request(:get, uri).to_return({status: 504}, {status: 200, body: ''})
      response = HTTP.get(uri, {}, {}, {retries: 3})
      expect(response.success?).to eq(true)
      expect(WebMock).to have_requested(:get, uri).times(2)
    end

    it "does not retry on 500 by default" do
      stub_request(:get, uri).to_return(status: 500)
      response = HTTP.get(uri, {}, {}, {retries: 3})
      expect(response.code.to_i).to eq(500)
      expect(WebMock).to have_requested(:get, uri).times(1)
    end

    it "does not retry on 404" do
      stub_request(:get, uri).to_return(status: 404)
      response = HTTP.get(uri, {}, {}, {retries: 3})
      expect(response.code.to_i).to eq(404)
      expect(WebMock).to have_requested(:get, uri).times(1)
    end

    it "returns the last response when retries are exhausted" do
      stub_request(:get, uri).to_return(status: 503)
      response = HTTP.get(uri, {}, {}, {retries: 2})
      expect(response.code.to_i).to eq(503)
      expect(WebMock).to have_requested(:get, uri).times(3)
    end
  end

  describe "Retry-After header" do
    it "honours integer Retry-After on 429" do
      stub_request(:get, uri).
        to_return({status: 429, headers: {'Retry-After' => '2'}}, {status: 200, body: ''})
      expect(HTTP::RETRY).to receive(:sleep).with(2)
      response = HTTP.get(uri, {}, {}, {retries: 3})
      expect(response.success?).to eq(true)
    end

    it "honours integer Retry-After on 503" do
      stub_request(:get, uri).
        to_return({status: 503, headers: {'Retry-After' => '5'}}, {status: 200, body: ''})
      expect(HTTP::RETRY).to receive(:sleep).with(5)
      response = HTTP.get(uri, {}, {}, {retries: 3})
      expect(response.success?).to eq(true)
    end
  end

  describe "configuration" do
    it "treats retries: 0 as no retries" do
      stub_request(:get, uri).to_return(status: 503)
      response = HTTP.get(uri, {}, {}, {retries: 0})
      expect(response.code.to_i).to eq(503)
      expect(WebMock).to have_requested(:get, uri).times(1)
    end

    it "respects a custom retry_status_codes list" do
      stub_request(:get, uri).to_return({status: 500}, {status: 200, body: ''})
      response = HTTP.get(uri, {}, {}, {retries: 3, retry_status_codes: [500]})
      expect(response.success?).to eq(true)
      expect(WebMock).to have_requested(:get, uri).times(2)
    end

    it "respects a custom retry_exceptions list" do
      stub_request(:get, uri).
        to_raise(OpenSSL::SSL::SSLError).then.
        to_return(status: 200, body: '')
      response = HTTP.get(uri, {}, {}, {retries: 3, retry_exceptions: [OpenSSL::SSL::SSLError]})
      expect(response.success?).to eq(true)
      expect(WebMock).to have_requested(:get, uri).times(2)
    end

    it "does not pass retry options through to Net::HTTP" do
      stub_request(:get, uri).to_return(status: 200, body: '')
      net_http_object = Net::HTTP.new(URI.parse(uri).host, URI.parse(uri).port)
      allow(Net::HTTP).to receive(:new).and_return(net_http_object)
      expect(net_http_object).to receive(:options=) do |opts|
        expect(opts).not_to include(:retries, :retry_delay, :retry_status_codes, :retry_exceptions, :retry_verbs)
      end
      HTTP.get(uri, {}, {}, {
        retries: 3,
        retry_delay: 0.1,
        retry_status_codes: [500],
        retry_exceptions: [Errno::ECONNRESET],
        retry_verbs: %i{get}
      })
    end
  end

  describe "backoff timing" do
    it "increases the delay between successive retries" do
      delays = []
      allow(HTTP::RETRY).to receive(:sleep){|d| delays << d}
      stub_request(:get, uri).to_return(status: 503)
      HTTP.get(uri, {}, {}, {retries: 3, retry_delay: 1.0})
      expect(delays.length).to eq(3)
      expect(delays[1]).to be > delays[0] * 0.8
      expect(delays[2]).to be > delays[1] * 0.8
    end
  end

  describe "verb-based retry default" do
    it "does not retry POST by default even when retries are enabled" do
      stub_request(:post, uri).to_return(status: 503)
      HTTP.post(uri, {}, {}, {retries: 3})
      expect(WebMock).to have_requested(:post, uri).times(1)
    end

    it "does not retry PATCH by default" do
      stub_request(:patch, uri).to_return(status: 503)
      HTTP.patch(uri, {}, {}, {retries: 3})
      expect(WebMock).to have_requested(:patch, uri).times(1)
    end

    it "retries PUT by default (idempotent)" do
      stub_request(:put, uri).to_return({status: 503}, {status: 200, body: ''})
      response = HTTP.put(uri, {}, {}, {retries: 3})
      expect(response.success?).to eq(true)
      expect(WebMock).to have_requested(:put, uri).times(2)
    end

    it "retries DELETE by default (idempotent)" do
      stub_request(:delete, uri).to_return({status: 503}, {status: 200, body: ''})
      response = HTTP.delete(uri, {}, {}, {retries: 3})
      expect(response.success?).to eq(true)
      expect(WebMock).to have_requested(:delete, uri).times(2)
    end

    it "retries POST when opted in via retry_verbs" do
      stub_request(:post, uri).to_return({status: 503}, {status: 200, body: ''})
      response = HTTP.post(uri, {}, {}, {retries: 3, retry_verbs: %i{get post}})
      expect(response.success?).to eq(true)
      expect(WebMock).to have_requested(:post, uri).times(2)
    end
  end
end

describe HTTP, ".retry_after" do
  it "returns integer seconds for a delta-seconds Retry-After header" do
    response = instance_double(Net::HTTPResponse)
    allow(response).to receive(:[]).with('Retry-After').and_return('5')
    expect(HTTP.retry_after(response)).to eq(5)
  end

  it "parses an HTTP-date Retry-After header" do
    base = Time.utc(2026, 5, 22, 12, 0, 0)
    retry_at_header = (base + 5).httpdate
    response = instance_double(Net::HTTPResponse)
    allow(response).to receive(:[]).with('Retry-After').and_return(retry_at_header)
    allow(Time).to receive(:now).and_return(base)
    expect(HTTP.retry_after(response)).to be_within(0.001).of(5.0)
  end

  it "returns nil when Retry-After is absent" do
    response = instance_double(Net::HTTPResponse)
    allow(response).to receive(:[]).with('Retry-After').and_return(nil)
    expect(HTTP.retry_after(response)).to be_nil
  end

  it "returns nil when Retry-After is malformed" do
    response = instance_double(Net::HTTPResponse)
    allow(response).to receive(:[]).with('Retry-After').and_return('not a date')
    expect(HTTP.retry_after(response)).to be_nil
  end
end

describe HTTP, ".backoff_delay" do
  it "grows exponentially with attempt number" do
    base = 1.0
    delays = (1..4).map{|attempt| HTTP.backoff_delay(base, attempt)}
    expect(delays[0]).to be_within(0.2).of(1.0)
    expect(delays[1]).to be_within(0.4).of(2.0)
    expect(delays[2]).to be_within(0.8).of(4.0)
    expect(delays[3]).to be_within(1.6).of(8.0)
  end
end

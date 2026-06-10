# test/HTTP/RETRY_test.rb

require_relative '../helper'

describe "retry behaviour" do
  let(:uri){'http://example.com/path'}

  describe "defaults" do
    it "does not retry by default" do
      stub_request(:get, uri).to_return(status: 503)
      response = HTTP.get(uri)
      _(response.code.to_i).must_equal(503)
      assert_requested(:get, uri, times: 1)
    end

    it "does not retry on a transient exception by default" do
      stub_request(:get, uri).to_raise(Errno::ECONNRESET)
      _(->{HTTP.get(uri)}).must_raise(Errno::ECONNRESET)
      assert_requested(:get, uri, times: 1)
    end
  end

  describe "retry on transient exception" do
    it "retries and succeeds when the failure is transient" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).
          to_raise(Errno::ECONNRESET).then.
          to_raise(Errno::ECONNRESET).then.
          to_return(status: 200, body: '')
        response = HTTP.get(uri, {}, {}, {retries: 3})
        _(response.success?).must_equal(true)
        assert_requested(:get, uri, times: 3)
      end
    end

    it "re-raises the exception after retries are exhausted" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).to_raise(Errno::ECONNRESET)
        _(->{HTTP.get(uri, {}, {}, {retries: 2})}).must_raise(Errno::ECONNRESET)
        assert_requested(:get, uri, times: 3)
      end
    end

    it "retries on SocketError (DNS failure)" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).
          to_raise(SocketError).then.
          to_return(status: 200, body: '')
        response = HTTP.get(uri, {}, {}, {retries: 3})
        _(response.success?).must_equal(true)
        assert_requested(:get, uri, times: 2)
      end
    end

    it "does not retry on a non-listed exception" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).to_raise(OpenSSL::SSL::SSLError)
        _(->{HTTP.get(uri, {}, {}, {retries: 3})}).must_raise(OpenSSL::SSL::SSLError)
        assert_requested(:get, uri, times: 1)
      end
    end
  end

  describe "retry on status code" do
    it "retries on 503 then succeeds" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).
          to_return({status: 503}, {status: 503}, {status: 200, body: ''})
        response = HTTP.get(uri, {}, {}, {retries: 3})
        _(response.success?).must_equal(true)
        assert_requested(:get, uri, times: 3)
      end
    end

    it "retries on 502" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).to_return({status: 502}, {status: 200, body: ''})
        response = HTTP.get(uri, {}, {}, {retries: 3})
        _(response.success?).must_equal(true)
        assert_requested(:get, uri, times: 2)
      end
    end

    it "retries on 504" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).to_return({status: 504}, {status: 200, body: ''})
        response = HTTP.get(uri, {}, {}, {retries: 3})
        _(response.success?).must_equal(true)
        assert_requested(:get, uri, times: 2)
      end
    end

    it "does not retry on 500 by default" do
      stub_request(:get, uri).to_return(status: 500)
      response = HTTP.get(uri, {}, {}, {retries: 3})
      _(response.code.to_i).must_equal(500)
      assert_requested(:get, uri, times: 1)
    end

    it "does not retry on 404" do
      stub_request(:get, uri).to_return(status: 404)
      response = HTTP.get(uri, {}, {}, {retries: 3})
      _(response.code.to_i).must_equal(404)
      assert_requested(:get, uri, times: 1)
    end

    it "returns the last response when retries are exhausted" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).to_return(status: 503)
        response = HTTP.get(uri, {}, {}, {retries: 2})
        _(response.code.to_i).must_equal(503)
        assert_requested(:get, uri, times: 3)
      end
    end
  end

  describe "Retry-After header" do
    it "honours integer Retry-After on 429" do
      received_seconds = nil
      HTTP::RETRY.stub(:sleep, ->(n){received_seconds = n}) do
        stub_request(:get, uri).
          to_return({status: 429, headers: {'Retry-After' => '2'}}, {status: 200, body: ''})
        response = HTTP.get(uri, {}, {}, {retries: 3})
        _(response.success?).must_equal(true)
        _(received_seconds).must_equal(2)
      end
    end

    it "honours integer Retry-After on 503" do
      received_seconds = nil
      HTTP::RETRY.stub(:sleep, ->(n){received_seconds = n}) do
        stub_request(:get, uri).
          to_return({status: 503, headers: {'Retry-After' => '5'}}, {status: 200, body: ''})
        response = HTTP.get(uri, {}, {}, {retries: 3})
        _(response.success?).must_equal(true)
        _(received_seconds).must_equal(5)
      end
    end
  end

  describe "configuration" do
    it "treats retries: 0 as no retries" do
      stub_request(:get, uri).to_return(status: 503)
      response = HTTP.get(uri, {}, {}, {retries: 0})
      _(response.code.to_i).must_equal(503)
      assert_requested(:get, uri, times: 1)
    end

    it "respects a custom retry_status_codes list" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).to_return({status: 500}, {status: 200, body: ''})
        response = HTTP.get(uri, {}, {}, {retries: 3, retry_status_codes: [500]})
        _(response.success?).must_equal(true)
        assert_requested(:get, uri, times: 2)
      end
    end

    it "respects a custom retry_exceptions list" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).
          to_raise(OpenSSL::SSL::SSLError).then.
          to_return(status: 200, body: '')
        response = HTTP.get(uri, {}, {}, {retries: 3, retry_exceptions: [OpenSSL::SSL::SSLError]})
        _(response.success?).must_equal(true)
        assert_requested(:get, uri, times: 2)
      end
    end

    it "does not pass retry options through to Net::HTTP" do
      stub_request(:get, uri).to_return(status: 200, body: '')
      net_http_object = Net::HTTP.new(URI.parse(uri).host, URI.parse(uri).port)
      received_opts = nil
      net_http_object.define_singleton_method(:options=){|opts| received_opts = opts}
      Net::HTTP.stub(:new, net_http_object) do
        HTTP.get(uri, {}, {}, {
          retries: 3,
          retry_delay: 0.1,
          retry_status_codes: [500],
          retry_exceptions: [Errno::ECONNRESET],
          retry_methods: %i{get},
          retry_verbs: %i{get}
        })
      end
      _(received_opts).wont_include(:retries)
      _(received_opts).wont_include(:retry_delay)
      _(received_opts).wont_include(:retry_status_codes)
      _(received_opts).wont_include(:retry_exceptions)
      _(received_opts).wont_include(:retry_methods)
      _(received_opts).wont_include(:retry_verbs)
    end
  end

  describe "backoff timing" do
    it "increases the delay between successive retries" do
      delays = []
      HTTP::RETRY.stub(:sleep, ->(d){delays << d}) do
        stub_request(:get, uri).to_return(status: 503)
        HTTP.get(uri, {}, {}, {retries: 3, retry_delay: 1.0})
      end
      _(delays.length).must_equal(3)
      _(delays[1]).must_be(:>, delays[0] * 0.8)
      _(delays[2]).must_be(:>, delays[1] * 0.8)
    end
  end

  describe "verb-based retry default" do
    it "does not retry POST by default even when retries are enabled" do
      stub_request(:post, uri).to_return(status: 503)
      HTTP.post(uri, {}, {}, {retries: 3})
      assert_requested(:post, uri, times: 1)
    end

    it "does not retry PATCH by default" do
      stub_request(:patch, uri).to_return(status: 503)
      HTTP.patch(uri, {}, {}, {retries: 3})
      assert_requested(:patch, uri, times: 1)
    end

    it "retries PUT by default (idempotent)" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:put, uri).to_return({status: 503}, {status: 200, body: ''})
        response = HTTP.put(uri, {}, {}, {retries: 3})
        _(response.success?).must_equal(true)
        assert_requested(:put, uri, times: 2)
      end
    end

    it "retries DELETE by default (idempotent)" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:delete, uri).to_return({status: 503}, {status: 200, body: ''})
        response = HTTP.delete(uri, {}, {}, {retries: 3})
        _(response.success?).must_equal(true)
        assert_requested(:delete, uri, times: 2)
      end
    end

    it "retries POST when opted in via retry_verbs" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:post, uri).to_return({status: 503}, {status: 200, body: ''})
        response = HTTP.post(uri, {}, {}, {retries: 3, retry_verbs: %i{get post}})
        _(response.success?).must_equal(true)
        assert_requested(:post, uri, times: 2)
      end
    end

    it "retries POST when opted in via retry_methods" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:post, uri).to_return({status: 503}, {status: 200, body: ''})
        response = HTTP.post(uri, {}, {}, {retries: 3, retry_methods: %i{get post}})
        _(response.success?).must_equal(true)
        assert_requested(:post, uri, times: 2)
      end
    end

    it "prefers retry_methods over retry_verbs when both are given" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:post, uri).to_return({status: 503}, {status: 200, body: ''})
        response = HTTP.post(uri, {}, {}, {retries: 3, retry_methods: %i{get post}, retry_verbs: %i{get}})
        _(response.success?).must_equal(true)
        assert_requested(:post, uri, times: 2)
      end
    end
  end
end

describe HTTP, ".retry_after" do
  it "returns integer seconds for a delta-seconds Retry-After header" do
    response = MockResponse.new(headers_hash: {'Retry-After' => '5'})
    _(HTTP.retry_after(response)).must_equal(5)
  end

  it "parses an HTTP-date Retry-After header" do
    base = Time.utc(2026, 5, 22, 12, 0, 0)
    retry_at_header = (base + 5).httpdate
    response = MockResponse.new(headers_hash: {'Retry-After' => retry_at_header})
    Time.stub(:now, base) do
      _(HTTP.retry_after(response)).must_be_close_to(5.0, 0.001)
    end
  end

  it "returns nil when Retry-After is absent" do
    response = MockResponse.new(headers_hash: {})
    _(HTTP.retry_after(response)).must_be_nil
  end

  it "returns nil when Retry-After is malformed" do
    response = MockResponse.new(headers_hash: {'Retry-After' => 'not a date'})
    _(HTTP.retry_after(response)).must_be_nil
  end

  it "clamps to 0 when the Retry-After HTTP-date is in the past" do
    base = Time.utc(2026, 5, 22, 12, 0, 0)
    retry_at_header = (base - 60).httpdate
    response = MockResponse.new(headers_hash: {'Retry-After' => retry_at_header})
    Time.stub(:now, base) do
      _(HTTP.retry_after(response)).must_equal(0)
    end
  end

  it "returns nil for a negative integer Retry-After" do
    response = MockResponse.new(headers_hash: {'Retry-After' => '-5'})
    _(HTTP.retry_after(response)).must_be_nil
  end
end

describe HTTP, ".backoff_delay" do
  it "grows exponentially with attempt number" do
    base = 1.0
    delays = (1..4).map{|attempt| HTTP.backoff_delay(base, attempt)}
    _(delays[0]).must_be_close_to(1.0, 0.2)
    _(delays[1]).must_be_close_to(2.0, 0.4)
    _(delays[2]).must_be_close_to(4.0, 0.8)
    _(delays[3]).must_be_close_to(8.0, 1.6)
  end
end

# test/HTTP/REDIRECT_test.rb

require_relative '../helper'

describe "redirect behaviour" do
  let(:uri){'http://example.com/path'}
  let(:same_origin_uri){'http://example.com/elsewhere'}
  let(:other_origin_uri){'http://redirected.com/path'}

  describe "the final URI" do
    it "is the requested URI when there is no redirect" do
      stub_request(:get, uri).to_return(status: 200)
      _(HTTP.get(uri).uri.to_s).must_equal(uri)
    end

    it "is the URI redirected to when a redirect is followed" do
      stub_request(:get, uri).to_return(status: 302, headers: {'location' => other_origin_uri})
      stub_request(:get, other_origin_uri).to_return(status: 200)
      _(HTTP.get(uri).uri.to_s).must_equal(other_origin_uri)
    end

    it "is the URI which redirected when no_redirect is set" do
      stub_request(:get, uri).to_return(status: 302, headers: {'location' => other_origin_uri})
      _(HTTP.get(uri, {}, {}, {no_redirect: true}).uri.to_s).must_equal(uri)
    end

    it "carries no embedded credentials" do
      stub_request(:get, uri).with(basic_auth: ['alice', 'secret']).to_return(status: 200)
      _(HTTP.get('http://alice:secret@example.com/path').uri.to_s).must_equal(uri)
    end
  end

  describe "headers" do
    %w{301 302 303 307 308}.each do |code|
      it "are carried through a #{code}" do
        stub_request(:get, uri).to_return(status: code.to_i, headers: {'location' => other_origin_uri})
        stub_request(:get, other_origin_uri).with(headers: {'User-Agent' => 'Redback', 'Accept' => 'text/html'}).to_return(status: 200)
        _(HTTP.get(uri, {}, {'User-Agent' => 'Redback', 'Accept' => 'text/html'}).success?).must_equal(true)
      end
    end

    it "leave Content-Type behind when a POST becomes a GET" do
      stub_request(:post, uri).to_return(status: 303, headers: {'location' => same_origin_uri})
      stub_request(:get, same_origin_uri).to_return(status: 200)
      HTTP.post(uri, {a: 1}, {'Content-Type' => 'application/json', 'User-Agent' => 'Redback'})
      assert_requested(:get, same_origin_uri){|request| !request.headers.key?('Content-Type') && request.headers['User-Agent'] == 'Redback'}
    end
  end

  describe "credentials" do
    it "are kept for the same origin" do
      stub_request(:get, uri).to_return(status: 307, headers: {'location' => same_origin_uri})
      stub_request(:get, same_origin_uri).with(headers: {'Authorization' => 'Bearer x', 'Cookie' => 'session=1'}).to_return(status: 200)
      _(HTTP.get(uri, {}, {'Authorization' => 'Bearer x', 'Cookie' => 'session=1'}).success?).must_equal(true)
    end

    %w{301 302 303 307 308}.each do |code|
      it "are dropped for another origin via #{code}" do
        stub_request(:get, uri).to_return(status: code.to_i, headers: {'location' => other_origin_uri})
        stub_request(:get, other_origin_uri).to_return(status: 200)
        HTTP.get(uri, {}, {'Authorization' => 'Bearer x', 'cookie' => 'session=1', 'User-Agent' => 'Redback'})
        assert_requested(:get, other_origin_uri){|request| !request.headers.key?('Authorization') && !request.headers.key?('Cookie') && request.headers['User-Agent'] == 'Redback'}
      end
    end

    it "are dropped for another scheme" do
      stub_request(:get, uri).to_return(status: 307, headers: {'location' => 'https://example.com/path'})
      stub_request(:get, 'https://example.com/path').to_return(status: 200)
      HTTP.get(uri, {}, {'Cookie' => 'session=1'})
      assert_requested(:get, 'https://example.com/path'){|request| !request.headers.key?('Cookie')}
    end

    it "are dropped for another port" do
      stub_request(:get, uri).to_return(status: 307, headers: {'location' => 'http://example.com:8080/path'})
      stub_request(:get, 'http://example.com:8080/path').to_return(status: 200)
      HTTP.get(uri, {}, {'Cookie' => 'session=1'})
      assert_requested(:get, 'http://example.com:8080/path'){|request| !request.headers.key?('Cookie')}
    end
  end

  describe "the options hash" do
    it "is not altered by a call" do
      stub_request(:get, uri).to_return(status: 302, headers: {'location' => same_origin_uri})
      stub_request(:get, same_origin_uri).to_return(status: 200)
      options = {no_redirect: false, max_redirects: 3, username: 'alice', password: 'secret', retries: 1}
      HTTP.get(uri, {}, {}, options)
      _(options).must_equal({no_redirect: false, max_redirects: 3, username: 'alice', password: 'secret', retries: 1})
    end

    it "keeps no_redirect for a second call" do
      stub_request(:get, uri).to_return(status: 302, headers: {'location' => other_origin_uri})
      options = {no_redirect: true}
      HTTP.get(uri, {}, {}, options)
      _(HTTP.get(uri, {}, {}, options).redirection?).must_equal(true)
      assert_not_requested(:get, other_origin_uri)
    end

    it "keeps retrying after a redirect" do
      HTTP::RETRY.stub(:sleep, nil) do
        stub_request(:get, uri).to_return(status: 302, headers: {'location' => same_origin_uri})
        stub_request(:get, same_origin_uri).to_return(status: 503).then.to_return(status: 200)
        _(HTTP.get(uri, {}, {}, {retries: 1}).success?).must_equal(true)
        assert_requested(:get, same_origin_uri, times: 2)
      end
    end
  end

  describe "basic authentication options" do
    it "are kept for the same origin" do
      stub_request(:get, uri).with(basic_auth: ['alice', 'secret']).to_return(status: 302, headers: {'location' => same_origin_uri})
      stub_request(:get, same_origin_uri).with(basic_auth: ['alice', 'secret']).to_return(status: 200)
      _(HTTP.get(uri, {}, {}, {username: 'alice', password: 'secret'}).success?).must_equal(true)
    end

    it "are dropped for another origin" do
      stub_request(:get, uri).with(basic_auth: ['alice', 'secret']).to_return(status: 307, headers: {'location' => other_origin_uri})
      stub_request(:get, other_origin_uri).to_return(status: 200)
      HTTP.get(uri, {}, {}, {username: 'alice', password: 'secret'})
      assert_requested(:get, other_origin_uri){|request| !request.headers.key?('Authorization')}
    end
  end

  describe "3xx responses which are not followed" do
    %w{300 304}.each do |code|
      it "return a #{code} as it is" do
        stub_request(:get, uri).to_return(status: code.to_i, headers: {'location' => other_origin_uri})
        _(HTTP.get(uri).code).must_equal(code)
        assert_not_requested(:get, other_origin_uri)
      end
    end

    it "return a redirect without a Location as it is" do
      stub_request(:get, uri).to_return(status: 302)
      _(HTTP.get(uri).code).must_equal('302')
    end
  end

  describe "with a block" do
    it "yields once when a redirect is followed" do
      stub_request(:get, uri).to_return(status: 302, headers: {'location' => other_origin_uri})
      stub_request(:get, other_origin_uri).to_return(status: 200)
      yielded = []
      HTTP.get(uri){|response| yielded << response.code}
      _(yielded).must_equal(['200'])
    end

    it "yields once, with the redirect, when no_redirect is set" do
      stub_request(:get, uri).to_return(status: 302, headers: {'location' => other_origin_uri})
      yielded = []
      HTTP.get(uri, {}, {}, {no_redirect: true}){|response| yielded << response.code}
      _(yielded).must_equal(['302'])
      assert_not_requested(:get, other_origin_uri)
    end
  end

  describe "a repeated body" do
    %w{307 308}.each do |code|
      it "keeps the Content-Type form data was sent with via #{code}" do
        stub_request(:post, uri).with(headers: {'Content-Type' => 'application/x-www-form-urlencoded'}).to_return(status: code.to_i, headers: {'location' => same_origin_uri})
        stub_request(:post, same_origin_uri).with(body: 'a=1', headers: {'Content-Type' => 'application/x-www-form-urlencoded'}).to_return(status: 200)
        _(HTTP.post(uri, {a: 1}).success?).must_equal(true)
      end
    end

    it "keeps the Content-Type it was given rather than that of form data" do
      stub_request(:post, uri).to_return(status: 307, headers: {'location' => same_origin_uri})
      stub_request(:post, same_origin_uri).with(body: '{"a":1}', headers: {'Content-Type' => 'application/json'}).to_return(status: 200)
      _(HTTP.post(uri, {a: 1}, {'Content-Type' => 'application/json'}).success?).must_equal(true)
    end
  end

  describe "the method" do
    %w{301 302}.each do |code|
      describe "via #{code}" do
        it "makes a POST a GET" do
          stub_request(:post, uri).to_return(status: code.to_i, headers: {'location' => same_origin_uri})
          stub_request(:get, same_origin_uri).to_return(status: 200)
          _(HTTP.post(uri, {a: 1}).success?).must_equal(true)
        end

        it "keeps a PUT, with its body and its Content-Type" do
          stub_request(:put, uri).to_return(status: code.to_i, headers: {'location' => same_origin_uri})
          stub_request(:put, same_origin_uri).with(body: 'a=1', headers: {'Content-Type' => 'application/x-www-form-urlencoded'}).to_return(status: 200)
          _(HTTP.put(uri, {a: 1}).success?).must_equal(true)
        end

        it "keeps a DELETE" do
          stub_request(:delete, uri).to_return(status: code.to_i, headers: {'location' => same_origin_uri})
          stub_request(:delete, same_origin_uri).to_return(status: 200)
          _(HTTP.delete(uri).success?).must_equal(true)
          assert_not_requested(:get, same_origin_uri)
        end

        it "keeps a HEAD" do
          stub_request(:head, uri).to_return(status: code.to_i, headers: {'location' => same_origin_uri})
          stub_request(:head, same_origin_uri).to_return(status: 200)
          _(HTTP.head(uri).success?).must_equal(true)
          assert_not_requested(:get, same_origin_uri)
        end

        it "keeps a method without a named helper" do
          stub_request(:propfind, uri).to_return(status: code.to_i, headers: {'location' => same_origin_uri})
          stub_request(:propfind, same_origin_uri).to_return(status: 207)
          _(HTTP.request_without_body(:propfind, uri).code).must_equal('207')
        end
      end
    end

    describe "via 303" do
      %i{post put delete}.each do |request_method|
        it "makes a #{request_method.upcase} a GET" do
          stub_request(request_method, uri).to_return(status: 303, headers: {'location' => same_origin_uri})
          stub_request(:get, same_origin_uri).to_return(status: 200)
          _(HTTP.send(request_method, uri).success?).must_equal(true)
        end
      end

      it "keeps a HEAD" do
        stub_request(:head, uri).to_return(status: 303, headers: {'location' => same_origin_uri})
        stub_request(:head, same_origin_uri).to_return(status: 200)
        _(HTTP.head(uri).success?).must_equal(true)
      end
    end

    %w{307 308}.each do |code|
      describe "via #{code}" do
        it "keeps a POST, with its body" do
          stub_request(:post, uri).to_return(status: code.to_i, headers: {'location' => same_origin_uri})
          stub_request(:post, same_origin_uri).with(body: 'a=1').to_return(status: 200)
          _(HTTP.post(uri, {a: 1}).success?).must_equal(true)
        end

        it "keeps a method without a named helper" do
          stub_request(:propfind, uri).to_return(status: code.to_i, headers: {'location' => same_origin_uri})
          stub_request(:propfind, same_origin_uri).to_return(status: 207)
          _(HTTP.request_without_body(:propfind, uri).code).must_equal('207')
        end
      end
    end
  end

  describe "max_redirects" do
    before do
      stub_request(:get, 'http://example.com/0').to_return(status: 302, headers: {'location' => '/1'})
      stub_request(:get, 'http://example.com/1').to_return(status: 302, headers: {'location' => '/2'})
      stub_request(:get, 'http://example.com/2').to_return(status: 200)
    end

    it "follows as many redirects as it is allowed" do
      _(HTTP.get('http://example.com/0', {}, {}, {max_redirects: 2}).success?).must_equal(true)
    end

    it "raises TooManyRedirects, with the redirect not followed, when there are more" do
      error = _(->{HTTP.get('http://example.com/0', {}, {}, {max_redirects: 1})}).must_raise(HTTP::TooManyRedirects)
      _(error.response['location']).must_equal('/2')
      _(error.response.uri.to_s).must_equal('http://example.com/1')
      assert_not_requested(:get, 'http://example.com/2')
    end

    it "raises at the first redirect when it is 0" do
      _(->{HTTP.get('http://example.com/0', {}, {}, {max_redirects: 0})}).must_raise(HTTP::TooManyRedirects)
      assert_not_requested(:get, 'http://example.com/1')
    end

    it "gives way to no_redirect" do
      _(HTTP.get('http://example.com/0', {}, {}, {max_redirects: 0, no_redirect: true}).code).must_equal('302')
    end

    it "stops a redirect loop at the default" do
      stub_request(:get, uri).to_return(status: 302, headers: {'location' => uri})
      _(->{HTTP.get(uri)}).must_raise(HTTP::TooManyRedirects)
      assert_requested(:get, uri, times: HTTP::REDIRECT::MAX + 1)
    end

    it "is not passed through to Net::HTTP" do
      stub_request(:get, uri).to_return(status: 200)
      _(HTTP.get(uri, {}, {}, {max_redirects: 5}).success?).must_equal(true)
    end
  end
end

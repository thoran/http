# test/HTTP/REDIRECT_test.rb

require_relative '../helper'

describe "redirect behaviour" do
  let(:uri){'http://example.com/path'}
  let(:same_origin_uri){'http://example.com/elsewhere'}
  let(:other_origin_uri){'http://redirected.com/path'}

  describe "credentials" do
    it "are kept for the same origin" do
      stub_request(:get, uri).to_return(status: 307, headers: {'location' => same_origin_uri})
      stub_request(:get, same_origin_uri).with(headers: {'Authorization' => 'Bearer x', 'Cookie' => 'session=1'}).to_return(status: 200)
      _(HTTP.get(uri, {}, {'Authorization' => 'Bearer x', 'Cookie' => 'session=1'}).success?).must_equal(true)
    end

    %w{307 308}.each do |code|
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
end

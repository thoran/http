# test/Thoran/Hash/XWwwFormUrlencode/x_www_form_urlencode_test.rb

require_relative '../../../helper'

describe Thoran::Hash::XWwwFormUrlencode do
  describe "#x_www_form_urlencode" do
    it "joins encoded pairs with an ampersand" do
      _({a: 1, 'b c' => 'd/e'}.x_www_form_urlencode).must_equal('a=1&b+c=d%2Fe')
    end

    it "leaves out a nil value" do
      _({a: 1, b: nil}.x_www_form_urlencode).must_equal('a=1')
    end

    it "repeats the key for each element of an array" do
      _({tags: [1, 2], a: 3}.x_www_form_urlencode).must_equal('tags=1&tags=2&a=3')
    end

    it "leaves out an empty array" do
      _({tags: [], a: 1}.x_www_form_urlencode).must_equal('a=1')
    end

    it "leaves out a nil element of an array" do
      _({tags: [1, nil, 2]}.x_www_form_urlencode).must_equal('tags=1&tags=2')
    end

    it "encodes as URI.encode_www_form does" do
      args = {tags: ['x y', 'Ä'], a: '1&2'}
      _(args.x_www_form_urlencode).must_equal(URI.encode_www_form(args))
    end

    it "joins with the joiner given" do
      _({a: 1, tags: [2, 3]}.x_www_form_urlencode(';')).must_equal('a=1;tags=2;tags=3')
    end
  end

  describe "#x_www_form_url_encode" do
    it "is an alias of #x_www_form_urlencode" do
      _({tags: [1, 2]}.x_www_form_url_encode).must_equal('tags=1&tags=2')
    end
  end
end

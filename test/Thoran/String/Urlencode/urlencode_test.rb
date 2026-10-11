# test/Thoran/String/Urlencode/urlencode_test.rb

require_relative '../../../helper'

describe Thoran::String::Urlencode do
  describe "#urlencode" do
    it "leaves unreserved characters alone" do
      _('aZ09_.-'.urlencode).must_equal('aZ09_.-')
    end

    it "encodes a space as a plus" do
      _('a b'.urlencode).must_equal('a+b')
    end

    it "encodes reserved characters" do
      _('a/b?c=d&e'.urlencode).must_equal('a%2Fb%3Fc%3Dd%26e')
    end

    it "encodes every byte of a two byte character" do
      _('Älaskår'.urlencode).must_equal('%C3%84lask%C3%A5r')
    end

    it "encodes every byte of a three byte character" do
      _('✓'.urlencode).must_equal('%E2%9C%93')
    end

    it "encodes a binary string byte by byte" do
      _('Ä'.b.urlencode).must_equal('%C3%84')
    end

    it "does not warn on a UTF-8 string" do
      _{'Älaskår'.urlencode}.must_be_silent
    end
  end

  describe "#url_encode" do
    it "is an alias of #urlencode" do
      _('Ashër'.url_encode).must_equal('Ash%C3%ABr')
    end
  end
end

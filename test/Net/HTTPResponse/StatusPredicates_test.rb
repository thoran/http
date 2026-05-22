# test/Net/HTTPResponse/StatusPredicates_test.rb

require_relative '../../helper'

describe Net::HTTPResponse::StatusPredicates do
  let(:response_class) do
    Class.new do
      include Net::HTTPResponse::StatusPredicates
      def initialize(code); @code = code; end
    end
  end

  describe "#ok?" do
    it "returns true for 200" do
      _(response_class.new('200').ok?).must_equal(true)
    end

    it "returns false for other 2xx codes" do
      ['201', '202', '204'].each do |code|
        _(response_class.new(code).ok?).must_equal(false)
      end
    end

    it "returns false for non-2xx codes" do
      _(response_class.new('404').ok?).must_equal(false)
    end
  end
end

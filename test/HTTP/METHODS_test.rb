# test/HTTP/METHODS_test.rb

require_relative '../helper'

def without_deprecation_warnings
  original = Warning[:deprecated]
  Warning[:deprecated] = false
  yield
ensure
  Warning[:deprecated] = original
end

describe "HTTP::METHODS" do
  it "groups the methods sent without a body" do
    _(HTTP::METHODS::WITHOUT_BODY).must_equal(%i{get delete head options trace})
  end

  it "groups the methods sent with a body" do
    _(HTTP::METHODS::WITH_BODY).must_equal(%i{post put patch})
  end

  it "remains reachable under the deprecated VERBS name" do
    without_deprecation_warnings do
      _(HTTP::VERBS).must_equal(HTTP::METHODS)
    end
  end
end

describe "HTTP::RETRY::METHODS" do
  it "lists the idempotent methods retried by default" do
    _(HTTP::RETRY::METHODS).must_equal(%i{get head options put delete trace})
  end

  it "remains reachable under the deprecated VERBS name" do
    without_deprecation_warnings do
      _(HTTP::RETRY::VERBS).must_equal(HTTP::RETRY::METHODS)
    end
  end
end

# HTTP/verbs.rb
# HTTP.verb

require_relative './request_without_body'
require_relative './request_with_body'

module HTTP
  module VERBS
    WITHOUT_BODY = %i{get delete head options trace}
    WITH_BODY = %i{post put patch}
  end

  VERBS::WITHOUT_BODY.each do |verb|
    define_method(verb) do |uri, args = {}, headers = {}, options = {}, &block|
      request_without_body(verb, uri, args, headers, options, &block)
    end
    module_function verb
  end

  VERBS::WITH_BODY.each do |verb|
    define_method(verb) do |uri, data = {}, headers = {}, options = {}, &block|
      request_with_body(verb, uri, data, headers, options, &block)
    end
    module_function verb
  end
end

# HTTP/METHODS.rb
# HTTP::METHODS

require_relative './request_without_body'
require_relative './request_with_body'

module HTTP
  module METHODS
    WITHOUT_BODY = %i{get delete head options trace}
    WITH_BODY = %i{post put patch}
  end

  VERBS = METHODS # Deprecated alias for METHODS; to be removed in 2.0.0.
  deprecate_constant :VERBS

  METHODS::WITHOUT_BODY.each do |request_method|
    define_method(request_method) do |uri, args = {}, headers = {}, options = {}, &block|
      request_without_body(request_method, uri, args, headers, options, &block)
    end
    module_function request_method
  end

  METHODS::WITH_BODY.each do |request_method|
    define_method(request_method) do |uri, data = {}, headers = {}, options = {}, &block|
      request_with_body(request_method, uri, data, headers, options, &block)
    end
    module_function request_method
  end
end

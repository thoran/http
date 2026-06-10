# HTTP/verbs.rb
# HTTP.verb

require 'json'
require 'net/http'

require_relative '../Hash/x_www_form_urlencode'
require_relative './request'

module HTTP
  module VERBS
    WITHOUT_BODY = %i{get delete head options trace}
    WITH_BODY = %i{post put patch}
  end

  def request_without_body(method, uri, args = {}, headers = {}, options = {}, &block)
    uri = uri.is_a?(URI) ? uri : URI.parse(uri)
    request_uri = uri.request_uri
    unless args.empty?
      request_uri += '?' + args.x_www_form_urlencode
    end
    request_object = Net::HTTP.const_get(method.to_s.capitalize).new(request_uri)
    request(uri, request_object, headers, options, &block)
  end
  module_function :request_without_body

  def request_with_body(method, uri, data = {}, headers = {}, options = {}, &block)
    uri = uri.is_a?(URI) ? uri : URI.parse(uri)
    request_object = Net::HTTP.const_get(method.to_s.capitalize).new(uri.request_uri)
    content_type = headers.find{|k, v| k.downcase == 'content-type'}&.last.to_s
    if data.is_a?(String)
      request_object.body = data
    elsif content_type.start_with?('application/json')
      request_object.body = JSON.dump(data)
    else
      request_object.form_data = data
    end
    request(uri, request_object, headers, options, &block)
  end
  module_function :request_with_body

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

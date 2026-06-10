# HTTP/request_without_body.rb
# HTTP.request_without_body

require 'net/http'

require_relative '../Hash/x_www_form_urlencode'
require_relative './request'

module HTTP
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
end

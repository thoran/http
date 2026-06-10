# HTTP/request_with_body.rb
# HTTP.request_with_body

require 'json'
require 'net/http'

require_relative './request'

module HTTP
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
end

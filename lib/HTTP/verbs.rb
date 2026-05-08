# HTTP/verbs.rb
# HTTP.verb

require 'json'
require 'net/http'

require_relative '../Hash/x_www_form_urlencode'
require_relative './request'
require_relative '../String/to_const'

module HTTP
  module VERBS
    WITHOUT_BODY = %i{get delete head options trace}
    WITH_BODY = %i{post put patch}
  end

  VERBS::WITHOUT_BODY.each do |verb|
    define_method(verb) do |uri, args = {}, headers = {}, options = {}, &block|
      uri = uri.is_a?(URI) ? uri : URI.parse(uri)
      request_uri = uri.request_uri
      unless args.empty?
        request_uri += '?' + args.x_www_form_urlencode
      end
      request_object = "Net::HTTP::#{verb.to_s.capitalize}".to_const.new(request_uri)
      request(uri, request_object, headers, options, &block)
    end

    module_function verb
  end

  VERBS::WITH_BODY.each do |verb|
    define_method(verb) do |uri, data = {}, headers = {}, options = {}, &block|
      uri = uri.is_a?(URI) ? uri : URI.parse(uri)
      request_object = "Net::HTTP::#{verb.to_s.capitalize}".to_const.new(uri.request_uri)
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

    module_function verb
  end
end

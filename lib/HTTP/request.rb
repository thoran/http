# HTTP/request.rb
# HTTP.request

require 'net/http'
require 'openssl'
require 'uri'

require_relative '../Net/HTTP/set_options'
require_relative '../Net/HTTPRequest/set_headers'
require_relative '../Net/HTTPResponse/StatusPredicates'
require_relative '../URI/Generic/use_sslQ'

module HTTP
  def request(uri, request_object, headers = {}, options = {}, &block)
    uri = uri.is_a?(URI) ? uri : URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    no_redirect = options.delete(:no_redirect)
    options[:use_ssl] ||= uri.use_ssl?
    options[:verify_mode] ||= OpenSSL::SSL::VERIFY_NONE
    http.options = options
    request_object.headers = headers
    request_object.basic_auth(uri.user, uri.password) if uri.user
    response = http.request(request_object)
    if response.code =~ /^3/
      if block_given? && no_redirect
        yield response
      elsif no_redirect
        return response
      end
      redirect_uri = uri.merge(response.header['location'])
      if response.code =~ /^30[78]$/
        verb = request_object.method.downcase.to_sym
        data = VERBS::WITH_BODY.include?(verb) ? request_object.body : {}
        response = send(verb, redirect_uri.to_s, data, headers, options, &block)
      else
        response = get(redirect_uri.to_s, {}, {}, options, &block)
      end
    end
    if block_given?
      yield response
    else
      response
    end
  end

  module_function :request
end

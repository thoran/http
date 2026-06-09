# HTTP/request.rb
# HTTP.request

require 'net/http'
require 'openssl'
require 'uri'

require_relative '../Net/HTTP/set_options'
require_relative '../Net/HTTPRequest/set_headers'
require_relative '../Net/HTTPResponse/StatusPredicates'
require_relative '../URI/Generic/use_sslQ'
require_relative './RETRY'

module HTTP
  def request(uri, request_object, headers = {}, options = {}, &block)
    uri = uri.is_a?(URI) ? uri : URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    no_redirect = options.delete(:no_redirect)
    username = options.delete(:username)
    password = options.delete(:password)
    config = retry_config(options)
    http.options = options.merge(
      use_ssl: (options[:use_ssl] || uri.use_ssl?),
      verify_mode: (options[:verify_mode] || OpenSSL::SSL::VERIFY_PEER)
    )
    request_object.headers = headers
    if username
      request_object.basic_auth(username, password)
    elsif uri.user
      request_object.basic_auth(uri.user, uri.password)
    end
    verb = request_object.method.downcase.to_sym
    response = (
      if config[:retries] > 0 && config[:verbs].include?(verb)
        with_retries(http, request_object, config)
      else
        http.request(request_object)
      end
    )
    if response.code =~ /^3/
      if block_given? && no_redirect
        yield response
      elsif no_redirect
        return response
      end
      redirect_uri = uri.merge(response['location'])
      if response.code =~ /^30[78]$/
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

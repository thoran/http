# HTTP/request.rb
# HTTP.request

require 'net/http'
require 'openssl'
require 'uri'

require_relative '../Net/HTTP/set_options'
require_relative '../Net/HTTPRequest/set_headers'
require_relative '../Net/HTTPResponse/StatusPredicates'
require_relative '../URI/Generic/use_sslQ'
require_relative './REDIRECT'
require_relative './RETRY'

module HTTP
  def request(uri, request_object, headers = {}, options = {}, &block)
    uri = uri.is_a?(URI) ? uri : URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    given_options = options
    options = options.dup
    no_redirect = options.delete(:no_redirect)
    max_redirects = options.delete(:max_redirects) || REDIRECT::MAX
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
    request_method = request_object.method.downcase.to_sym
    response = (
      if config[:retries] > 0 && config[:methods].include?(request_method)
        with_retries(http, request_object, config)
      else
        http.request(request_object)
      end
    )
    if !no_redirect && redirect?(response)
      raise TooManyRedirects.new(response) if max_redirects < 1
      redirect_uri = uri.merge(response['location'])
      onward_options = redirect_options(given_options, uri, redirect_uri, max_redirects)
      redirect_method = redirect_method(response.code, request_method)
      if redirect_method != request_method
        return request_without_body(redirect_method, redirect_uri, {}, redirect_headers(headers, uri, redirect_uri, drop_content_type: true), onward_options, &block)
      elsif request_object.body
        return request_with_body(request_method, redirect_uri, request_object.body, redirect_headers(body_headers(headers, request_object), uri, redirect_uri), onward_options, &block)
      else
        return request_without_body(request_method, redirect_uri, {}, redirect_headers(headers, uri, redirect_uri), onward_options, &block)
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

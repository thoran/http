# HTTP/REDIRECT.rb
# HTTP::REDIRECT (redirect helpers)

module HTTP
  module REDIRECT
    CODES = %w{301 302 303 307 308}.freeze
    CREDENTIAL_HEADERS = %w{authorization cookie}.freeze
  end

  # A 300 or a 304 is an answer rather than somewhere else to go, and a 3xx without a
  # Location has nowhere to send it.
  def redirect?(response)
    REDIRECT::CODES.include?(response.code) && !response['location'].to_s.empty?
  end
  module_function :redirect?

  def same_origin?(a, b)
    [a.scheme, a.host, a.port] == [b.scheme, b.host, b.port]
  end
  module_function :same_origin?

  # Credentials are for the origin they were given to, so they go no further than it.
  # A request made into a GET has no body for a Content-Type to describe.
  def redirect_headers(headers, from_uri, to_uri, drop_content_type: false)
    headers.reject do |k, v|
      (drop_content_type && k.downcase == 'content-type') ||
        (!same_origin?(from_uri, to_uri) && REDIRECT::CREDENTIAL_HEADERS.include?(k.downcase))
    end
  end
  module_function :redirect_headers

  # A body repeated carries the type it was sent with, which form data sets upon the
  # request object rather than among the headers given.
  def body_headers(headers, request_object)
    return headers unless request_object['content-type']
    return headers if headers.any?{|k, v| k.downcase == 'content-type'}
    headers.merge('Content-Type' => request_object['content-type'])
  end
  module_function :body_headers

  def redirect_options(options, from_uri, to_uri)
    return options if same_origin?(from_uri, to_uri)
    options.reject{|k, v| %i{username password}.include?(k)}
  end
  module_function :redirect_options
end

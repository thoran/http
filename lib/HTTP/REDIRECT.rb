# HTTP/REDIRECT.rb
# HTTP::REDIRECT (redirect helpers)

module HTTP
  module REDIRECT
    CREDENTIAL_HEADERS = %w{authorization cookie}.freeze
  end

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

  def redirect_options(options, from_uri, to_uri)
    return options if same_origin?(from_uri, to_uri)
    options.reject{|k, v| %i{username password}.include?(k)}
  end
  module_function :redirect_options
end

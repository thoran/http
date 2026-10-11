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
  def redirect_headers(headers, from_uri, to_uri)
    return headers if same_origin?(from_uri, to_uri)
    headers.reject{|k, v| REDIRECT::CREDENTIAL_HEADERS.include?(k.downcase)}
  end
  module_function :redirect_headers

  def redirect_options(options, from_uri, to_uri)
    return options if same_origin?(from_uri, to_uri)
    options.reject{|k, v| %i{username password}.include?(k)}
  end
  module_function :redirect_options
end

# http

For many years this was a personal library, from around the middle of 2009 from what I can ascertain, though in various guises it may have been as early as late 2007.

Like many others before and after me with their respective libraries, I created it to simplify the heinous interface that is Net::HTTP. At the time of it's original creation I was doing a lot of a webscraping and didn't want a half-dozen line setup to make simple requests. It has stood the test of time, for me personally insofar as the interface remaining simpler than most other similar libraries, though it is also less full featured, but nevertheless for it's tiny size it packs in quite a bit.

Perhaps some will appreciate its relative simplicity, since it is much smaller and the usage simpler than any of the other 'wrapper' libraries, such that it can be read and comprehended in full in as little as a couple of minutes.  It does just enough to do most simple HTTP GET and POST requests as simply as should be.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'http.rb'
```

And then execute:

```shell
$ bundle
```

Or install it directly:

```shell
$ gem install http.rb
```

## Usage

### With just a URI

```ruby
HTTP.get('http://example.com')
```

### With arguments only

```ruby
HTTP.get('http://example.com', {a: 1, b: 2})
HTTP.post('http://example.com', {a: 1, b: 2})
```
### With JSON data

```ruby
HTTP.post('http://example.com', {a: 1, b: 2}, {'Content-type' => 'application/json'})
```

### With custom headers only

```ruby
HTTP.get('http://example.com', {}, {'User-Agent'=>'Custom'})
HTTP.post('http://example.com', {}, {'User-Agent'=>'Custom'})
```

### With options only

```ruby
HTTP.get('http://example.com', {}, {}, {use_ssl: true})
HTTP.post('http://example.com', {}, {}, {use_ssl: true})
```

### With a block

```ruby
HTTP.get('http://example.com') do |response|
  # Do stuff with a subclass of Net::HTTPResponse here...
end
```

### With the lot

```ruby
HTTP.post('http://example.com', {a: 1, b: 2}, {'User-Agent'=>'Custom'}, {use_ssl: true}) do |response|
  # Do stuff with a subclass of Net::HTTPResponse here...
end
```

### Preventing redirections

```ruby
HTTP.get('http://example.com', {}, {}, {no_redirect: true})
# => #<Net::HTTPResponse @code=3xx>
```

### Response status predicate methods

```ruby
# 1xx
response = HTTP.get('http://example.com')
response.informational?
# => true

# 2xx
response = HTTP.get('http://example.com')
response.success?
# => true

# 3xx
response = HTTP.get('http://example.com', {}, {}, {no_redirect: true})
response.redirection?
# => true
response.success?
# => false

response = HTTP.get('http://example.com', {}, {}, {no_redirect: false})
response.redirection?
# => false
response.success?
# => true

response = HTTP.get('http://example.com')
response.redirection?
# => false
response.success?
# => true

# 4xx
response = HTTP.get('http://example.com')
response.client_error?
# => true
response.error?
# => true

# 5xx
response = HTTP.get('http://example.com')
response.server_error?
# => true
response.error?
# => true
```

### Including it in a class

```ruby
class A
  include HTTP
  def a
    get('http://example.com')
  end
end
```

### Extending a class

```ruby
class A
  extend HTTP
  get('http://example.com')
end
```

## Allowed values for the options hash
#### (These pass through to Net::HTTP, except for `no_redirect`.)

```Ruby
no_redirect
    # Prevents redirection if a 3xx response is encountered.

ca_file
    # Sets path of a CA certification file in PEM format.
    #
    # The file can contain several CA certificates.

ca_path
    # Sets path of a CA certification directory containing certifications in
    # PEM format.

cert
    # Sets an OpenSSL::X509::Certificate object as client certificate.
    # (This method is appeared in Michal Rokos's OpenSSL extension).

cert_store
    # Sets the X509::Store to verify peer certificate.

ciphers
    # Sets the available ciphers.  See OpenSSL::SSL::SSLContext#ciphers=

close_on_empty_response

continue_timeout
    # Number of seconds to wait for one block to be read (via one read(2)
    # call). Any number may be used, including Floats for fractional
    # seconds. If the HTTP object cannot read data in this many seconds,
    # it raises a Net::ReadTimeout exception. The default value is 60 seconds.

keep_alive_timeout
    # Seconds to reuse the connection of the previous request.
    # If the idle time is less than this Keep-Alive Timeout,
    # Net::HTTP reuses the TCP/IP socket used by the previous communication.
    # The default value is 2 seconds.

key
    # Sets an OpenSSL::PKey::RSA or OpenSSL::PKey::DSA object.
    # (This method is appeared in Michal Rokos's OpenSSL extension.)

local_host
    # The local host used to establish the connection.

local_port
    # The local port used to establish the connection.

open_timeout
    # Number of seconds to wait for the connection to open. Any number
    # may be used, including Floats for fractional seconds. If the HTTP
    # object cannot open a connection in this many seconds, it raises a
    # Net::OpenTimeout exception. The default value is 60 seconds.

proxy_address
proxy_from_env
proxy_pass
proxy_port
proxy_user

read_timeout
    # Seconds to wait for 100 Continue response. If the HTTP object does not
    # receive a response in this many seconds it sends the request body. The
    # default value is +nil+.

ssl_timeout
    # Sets the SSL timeout seconds.

ssl_version
    # Sets the SSL version.  See OpenSSL::SSL::SSLContext#ssl_version=

use_ssl
    # Turn on/off SSL.
    # This flag must be set before starting session.
    # If you change use_ssl value after session started,
    # a Net::HTTP object raises IOError.

verify_callback
    # Sets the verify callback for the server certification verification.

verify_depth
    # Sets the maximum depth for the certificate chain verification.

verify_mode
    # Sets the flags for server the certification verification at beginning of
    # SSL/TLS session.
    #
    # OpenSSL::SSL::VERIFY_NONE or OpenSSL::SSL::VERIFY_PEER are acceptable.
```

## Contributing

1. Fork it [https://github.com/thoran/http/fork](https://github.com/thoran/http/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

## Licence

MIT

# test/helper.rb

lib_dir = File.expand_path(File.join(__FILE__, '..', '..', 'lib'))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

# webmock's http_rb adapter's require 'http' finds this gem's lib/http.rb,
# takes HTTP::VERSION for the http gem's, and crashes trying to
# monkey-patch an HTTP::Client which isn't there.
def skip_webmocks_http_rb_adapter
  gem 'webmock'

  $LOADED_FEATURES << File.join(
    Gem.loaded_specs['webmock'].full_gem_path,
    'lib/webmock/http_lib_adapters/http_rb_adapter.rb'
  )
end

skip_webmocks_http_rb_adapter

require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/spec'
require 'webmock/minitest'

require 'http'

MockResponse = Struct.new(:code, :message, :body, :headers_hash, keyword_init: true) do
  def [](key)
    headers_hash&.dig(key)
  end
end

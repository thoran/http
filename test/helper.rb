# test/helper.rb

lib_dir = File.expand_path(File.join(__FILE__, '..', '..', 'lib'))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

# Skip webmock's http_rb adapter: it auto-requires 'http', which collides
# with this gem's lib/HTTP.rb on case-insensitive filesystems and crashes
# while trying to monkey-patch the wrong HTTP module.

gem 'webmock'

$LOADED_FEATURES << File.join(
  Gem.loaded_specs['webmock'].full_gem_path,
  'lib/webmock/http_lib_adapters/http_rb_adapter.rb'
)

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

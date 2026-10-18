# test/loading_test.rb

require 'minitest/autorun'

require_relative '../lib/http'

# In its own process, since this one has loaded the file directly and so could
# not tell what requiring the gem by its own name would bring.
describe 'loading' do
  def ruby(source)
    lib = File.expand_path('../lib', __dir__)
    IO.popen(['ruby', "-I#{lib}", '-e', source], err: [:child, :out]){|io| io.read}.strip
  end

  # The gem is http.rb, so require 'http.rb' reads lib/http.rb.  A capitalised
  # load file answers that only on a case-insensitive filesystem.  Dir.entries
  # reports the name as stored, so this asks what a case-sensitive filesystem
  # would ask.
  it "carries the lowercase file the gem's name asks for" do
    _(Dir.entries(File.expand_path('../lib', __dir__))).must_include 'http.rb'
  end

  it "defines HTTP upon requiring the gem by name" do
    _(ruby('require "http.rb"; print defined?(HTTP)')).must_equal 'constant'
  end

  it "defines the version too" do
    _(ruby('require "http.rb"; print HTTP::VERSION')).must_equal HTTP::VERSION
  end
end

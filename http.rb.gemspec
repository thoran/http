require_relative './lib/HTTP/VERSION'

class Gem::Specification
  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |spec|
  spec.name = 'http.rb'
  spec.version = HTTP::VERSION

  spec.summary = "HTTP made easy."
  spec.description = "HTTP is the simplest HTTP mezzanine library for Ruby.  Supply a URI, \
    some optional query arguments, some optional headers, and some \
    Net::HTTP options, and that's it!"

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = "http://github.com/thoran/HTTP"
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.2'
  spec.require_paths = ['lib']

  spec.files = [
    'http.rb.gemspec',
    'CHANGELOG',
    'Gemfile',
    'LICENSE',
    'Rakefile',
    'README.md',
    Dir['lib/**/*.rb'],
    Dir['test/**/*.rb'],
  ].flatten

  spec.development_dependencies = [
    ['minitest', '~> 6.0'],
    'minitest-mock',
    'pry',
    'rake',
    'webmock',
  ]
end

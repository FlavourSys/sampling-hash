lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sampling-hash/version'

Gem::Specification.new do |gem|
  gem.name          = "sampling-hash"
  gem.version       = SamplingHash::VERSION
  gem.license       = 'MIT'
  gem.authors       = ['FlavourSys Technology GmbH']
  gem.email         = ['technology@flavoursys.com']
  gem.description   = %q{Calculates deterministic hashes from file samples}
  gem.summary       = %q{Sampling hash algorithm for large files}
  gem.homepage      = "http://github.com/FlavourSys/sampling-hash"

  gem.files         = Dir.glob('lib/**/*.rb')
  gem.require_paths = ['lib']

  gem.add_dependency 'xxhash', '~> 0.3'
  gem.add_development_dependency 'rake', ">= 12.3.3"
  gem.add_development_dependency 'minitest', '~> 5.5'
end

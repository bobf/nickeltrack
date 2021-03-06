# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nickeltrack/version'

def dependencies(spec)
  spec.add_dependency 'activerecord', '~> 5.2'
  spec.add_dependency 'chartkick', '~> 3.0'
  spec.add_dependency 'erubis', '~> 2.7'
  spec.add_dependency 'faraday', '~> 0.15'
  spec.add_dependency 'fuzzy_match', '~> 2.1'
  spec.add_dependency 'pg', '~> 1.1'
  spec.add_dependency 'standalone_migrations', '~> 5.2'
  spec.add_dependency 'thor', '~> 0.20'
end

def development_dependencies(spec)
  spec.add_development_dependency 'byebug', '~> 10.0'
  spec.add_development_dependency 'factory_bot', '~> 4.11'
  spec.add_development_dependency 'faker', '~> 1.9'
  spec.add_development_dependency 'rspec-rails', '~> 3.8'
  spec.add_development_dependency 'rubocop', '~> 0.60.0'
  spec.add_development_dependency 'webmock', '~> 3.4'
end

Gem::Specification.new do |spec|
  spec.name          = 'nickeltrack'
  spec.version       = Nickeltrack::VERSION
  spec.authors       = ['Bob Farrell']
  spec.email         = ['robertanthonyfarrell@gmail.com']

  spec.summary       = 'Track Nickelback Mastery'
  spec.description   = '10,000 Hours to Mastery of Nickelback'
  spec.homepage      = 'https://nickeltrack.com'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end

  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']

  dependencies(spec)
  development_dependencies(spec)
end

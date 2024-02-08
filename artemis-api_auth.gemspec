lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'artemis/api_auth/version'

Gem::Specification.new do |spec|
  spec.name = 'artemis-api_auth'
  spec.version = Artemis::ApiAuth::VERSION
  spec.authors = ['Jan Stevens']
  spec.email = ['jan@playpass.be']

  spec.summary = 'Net::HTTP adapter that adds Api Auth authentication for Artemis GraphQL Client'
  spec.description = 'Net::HTTP adapter that adds Api Auth authentication for Artemis GraphQL Client'
  spec.homepage = 'https://github.com/JanStevens/artemis-api-auth'
  spec.license = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'api-auth', '< 3'
  spec.add_dependency 'artemis', '< 2'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end

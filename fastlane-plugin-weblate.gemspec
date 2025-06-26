lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/weblate/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-weblate'
  spec.version       = Fastlane::Weblate::VERSION
  spec.author        = 'Flop Butylkin'
  spec.email         = 'sergej.khlopenov@paysera.net'

  spec.summary       = 'Weblate API inegration'
  # spec.homepage      = "https://github.com/<GITHUB_USERNAME>/fastlane-plugin-weblate"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.6'

  # Don't add a dependency to fastlane or fastlane_re

  spec.add_dependency 'weblate', '~> 0.1.1'

  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.216.0')
end

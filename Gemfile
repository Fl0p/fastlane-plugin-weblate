source('https://rubygems.org')

# Provides a consistent environment for Ruby projects by tracking and installing exact gem versions.
gem 'bundler'
# Automation tool for mobile developers.
gem 'fastlane', '>= 2.227.2'
# Provides an interactive debugging environment for Ruby.
gem 'pry'
# A simple task automation tool.
gem 'rake'
# Behavior-driven testing tool for Ruby.
gem 'rspec'
# Formatter for RSpec to generate JUnit compatible reports.
gem 'rspec_junit_formatter'
# A Ruby static code analyzer and formatter.
gem 'rubocop', '1.50.2'
# A collection of RuboCop cops for performance optimizations.
gem 'rubocop-performance'
# A RuboCop extension focused on enforcing tools.
gem 'rubocop-require_tools'
# SimpleCov is a code coverage analysis tool for Ruby.
gem 'simplecov'

gemspec

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

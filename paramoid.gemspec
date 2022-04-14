# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'paramoid/version'

Gem::Specification.new do |s|
  s.name        = 'paramoid'
  s.version     = Paramoid::VERSION
  s.date        = '2022-04-14'
  s.summary     = 'Paramoid is a gem for sanitizing parameters'
  s.description = 'Paramoid is a gem for sanitizing parameters'
  s.authors     = ['Mònade']
  s.email       = 'team@monade.io'
  s.files = Dir['lib/**/*']
  s.test_files = Dir['spec/**/*']
  s.required_ruby_version = '>= 2.7.0'
  s.homepage    = 'https://rubygems.org/gems/paramoid'
  s.license     = 'MIT'
  s.add_dependency 'activesupport', ['>= 5', '< 8']
  s.add_dependency 'actionpack', ['>= 5', '< 8']
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rubocop'
end

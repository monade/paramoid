# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'paramoid/version'

Gem::Specification.new do |s|
  s.name        = 'paramoid'
  s.version     = Paramoid::VERSION
  s.date        = '2022-05-28'
  s.summary     = 'Getting paranoid about your Rails application params? Try paramoid!'
  s.description = 'Paramoid is a gem that extends Rails Strong Parameters, allowing to declare complex params structures with a super cool DSL, supporting required params, default values, groups, arrays and more.'
  s.authors     = ['Mònade']
  s.email       = 'team@monade.io'
  s.files = Dir['lib/**/*']
  s.test_files = Dir['spec/**/*']
  s.required_ruby_version = '>= 3.0.0'
  s.homepage    = 'https://rubygems.org/gems/paramoid'
  s.license     = 'MIT'
  s.add_dependency 'actionpack', ['>= 5', '< 9']
  s.add_dependency 'activesupport', ['>= 5', '< 9']
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rubocop'
end

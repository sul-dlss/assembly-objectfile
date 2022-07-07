# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'assembly-objectfile/version'

Gem::Specification.new do |s|
  s.name        = 'assembly-objectfile'
  s.version     = Assembly::ObjectFile::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Peter Mangiafico', 'Renzo Sanchez-Silva', 'Monty Hindman', 'Tony Calavano']
  s.email       = ['pmangiafico@stanford.edu']
  s.homepage    = 'https://github.com/sul-dlss/assembly-objectfile'
  s.summary     = 'Ruby immplementation of file services needed to prepare objects to be accessioned in SULAIR digital library'
  s.description = 'Get exif data, file sizes and more.'
  s.license     = 'ALv2'
  s.metadata['rubygems_mfa_required'] = 'true'

  s.files         = `git ls-files`.split("\n")
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.0'

  s.add_dependency 'activesupport', '>= 5.2.0'
  s.add_dependency 'deprecation'
  s.add_dependency 'mime-types', '> 3'
  s.add_dependency 'mini_exiftool'
  s.add_dependency 'nokogiri'

  s.add_development_dependency 'json'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rubocop', '~> 1.25'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'simplecov'
end

$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'assembly-objectfile/version'

Gem::Specification.new do |s|
  s.name        = 'assembly-objectfile'
  s.version     = Assembly::ObjectFile::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '~> 1.8.7'
  s.authors     = ["Peter Mangiafico", "Renzo Sanchez-Silva","Monty Hindman","Tony Calavano"]
  s.email       = ["pmangiafico@stanford.edu"]
  s.homepage    = ""
  s.summary     = %q{Ruby immplementation of file services needed to prepare objects to be accessioned in SULAIR digital library}
  s.description = %q{Get exif data, file sizes and more.}

  s.rubyforge_project = 'assembly-objectfile'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'mini_exiftool', "~> 1.6"
  s.add_dependency 'mime-types'
  s.add_dependency 'nokogiri', ((RUBY_VERSION < '1.9') ? "~> 1.5.10" : "~> 1") # 1.6.x requires ruby 1.9

  s.add_development_dependency 'json'
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "lyberteam-devel", '>= 1.0.1'
  s.add_development_dependency "lyberteam-gems-devel", "> 1.0.0"
  s.add_development_dependency "yard"
  
end

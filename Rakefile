# frozen_string_literal: true

require 'bundler/gem_tasks'

desc 'Run console with irb (default), pry, etc.'
task :console, :irb do |_t, args|
  irb = args[:irb].nil? ? 'irb' : args[:irb]
  sh irb, '-r', "#{File.dirname(__FILE__)}/config/boot.rb"
end

require 'rspec/core/rake_task'

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec)

task default: :spec

# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require File.expand_path("#{File.dirname(__FILE__)}/../config/boot")
require 'pry-byebug'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = 'random'
  Kernel.srand config.seed
end

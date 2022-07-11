# frozen_string_literal: true

require 'rubygems'

project_root = File.expand_path("#{File.dirname(__FILE__)}/..")

# Load config for current environment.
$LOAD_PATH.unshift("#{project_root}/lib")

require 'assembly-objectfile'

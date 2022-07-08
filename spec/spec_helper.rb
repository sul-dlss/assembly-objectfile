# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require File.expand_path("#{File.dirname(__FILE__)}/../config/boot")
require 'pry-byebug'

RSpec.configure do |config|
  config.order = 'random'
end

TEST_DATA_DIR = File.join(Assembly::PATH_TO_GEM, 'spec', 'test_data')
TEST_INPUT_DIR       = File.join(TEST_DATA_DIR, 'input')
TEST_OUTPUT_DIR      = File.join(TEST_DATA_DIR, 'output')
TEST_TIF_INPUT_FILE  = File.join(TEST_INPUT_DIR, 'test.tif')
TEST_JPEG_INPUT_FILE = File.join(TEST_INPUT_DIR, 'test.jpg')
TEST_JP2_INPUT_FILE = File.join(TEST_INPUT_DIR, 'test.jp2')
TEST_JP2_OUTPUT_FILE = File.join(TEST_OUTPUT_DIR, 'test.jp2')

TEST_TIFF_NO_COLOR_FILE = File.join(TEST_INPUT_DIR, 'test_no_color_profile.tif')

TEST_RES1_TIF1 = File.join(TEST_INPUT_DIR, 'res1_image1.tif')
TEST_RES1_TEXT = File.join(TEST_INPUT_DIR, 'res1_textfile.txt')
TEST_RES1_PDF = File.join(TEST_INPUT_DIR, 'res1_transcript.pdf')

TEST_FILE_NO_EXIF = File.join(TEST_INPUT_DIR, 'file_with_no_exif.xml')

TEST_JSON_FILE = File.join(TEST_INPUT_DIR, 'test.json')

TEST_OBJ_FILE = File.join(TEST_INPUT_DIR, 'someobject.obj')
TEST_PLY_FILE = File.join(TEST_INPUT_DIR, 'someobject.ply')

TEST_DRUID = 'nx288wh8889'

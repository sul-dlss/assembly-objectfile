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
TEST_TIF_INPUT_FILE2  = File.join(TEST_INPUT_DIR, 'test2.tif')
TEST_JPEG_INPUT_FILE  = File.join(TEST_INPUT_DIR, 'test.jpg')
TEST_JP2_INPUT_FILE = File.join(TEST_INPUT_DIR, 'test.jp2')
TEST_JP2_INPUT_FILE2 = File.join(TEST_INPUT_DIR, 'test2.jp2')
TEST_SVG_INPUT_FILE  = File.join(TEST_INPUT_DIR, 'test.svg')
TEST_JP2_OUTPUT_FILE = File.join(TEST_OUTPUT_DIR, 'test.jp2')
TEST_PDF_FILE = File.join(TEST_INPUT_DIR, 'test.pdf')

TEST_TIFF_NO_COLOR_FILE = File.join(TEST_INPUT_DIR, 'test_no_color_profile.tif')

TEST_RES1_TIF1 = File.join(TEST_INPUT_DIR, 'res1_image1.tif')
TEST_RES1_JP1 = File.join(TEST_INPUT_DIR, 'res1_image1.jp2')
TEST_RES1_TIF2 = File.join(TEST_INPUT_DIR, 'res1_image2.tif')
TEST_RES1_JP2 = File.join(TEST_INPUT_DIR, 'res1_image2.jp2')
TEST_RES1_TEI = File.join(TEST_INPUT_DIR, 'res1_teifile.txt')
TEST_RES1_TEXT = File.join(TEST_INPUT_DIR, 'res1_textfile.txt')
TEST_RES1_PDF = File.join(TEST_INPUT_DIR, 'res1_transcript.pdf')

TEST_RES2_TIF1 = File.join(TEST_INPUT_DIR, 'res2_image1.tif')
TEST_RES2_JP1 = File.join(TEST_INPUT_DIR, 'res2_image1.jp2')
TEST_RES2_TIF2 = File.join(TEST_INPUT_DIR, 'res2_image2.tif')
TEST_RES2_JP2 = File.join(TEST_INPUT_DIR, 'res2_image2.jp2')
TEST_RES2_TEI = File.join(TEST_INPUT_DIR, 'res2_teifile.txt')
TEST_RES2_TEXT = File.join(TEST_INPUT_DIR, 'res2_textfile.txt')

TEST_RES3_TIF1 = File.join(TEST_INPUT_DIR, 'res3_image1.tif')
TEST_RES3_JP1 = File.join(TEST_INPUT_DIR, 'res3_image1.jp2')
TEST_RES3_TEI = File.join(TEST_INPUT_DIR, 'res3_teifile.txt')

TEST_FILE_NO_EXIF = File.join(TEST_INPUT_DIR, 'file_with_no_exif.xml')

TEST_JSON_FILE = File.join(TEST_INPUT_DIR, 'test.json')

TEST_OBJ_FILE = File.join(TEST_INPUT_DIR, 'someobject.obj')
TEST_PLY_FILE = File.join(TEST_INPUT_DIR, 'someobject.ply')

TEST_DRUID = 'nx288wh8889'

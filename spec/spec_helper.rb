# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

bootfile = File.expand_path("#{File.dirname(__FILE__)}/../config/boot")
require bootfile

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
TEST_JP2_OUTPUT_FILE = File.join(TEST_OUTPUT_DIR, 'test.jp2')
TEST_PDF_FILE = File.join(TEST_INPUT_DIR, 'test.pdf')

TEST_DPG_TIF = File.join(TEST_INPUT_DIR, 'oo000oo0001', '00', 'oo000oo0001_00_001.tif')
TEST_DPG_TIF2 = File.join(TEST_INPUT_DIR, 'oo000oo0001', '00', 'oo000oo0001_00_002.tif')
TEST_DPG_JP = File.join(TEST_INPUT_DIR, 'oo000oo0001', '05', 'oo000oo0001_05_001.jp2')
TEST_DPG_JP2 = File.join(TEST_INPUT_DIR, 'oo000oo0001', '05', 'oo000oo0001_05_002.jp2')
TEST_DPG_PDF = File.join(TEST_INPUT_DIR, 'oo000oo0001', '15', 'oo000oo0001_15_001.pdf')
TEST_DPG_PDF2 = File.join(TEST_INPUT_DIR, 'oo000oo0001', '15', 'oo000oo0001_15_002.pdf')
TEST_DPG_SPECIAL_PDF1 = File.join(TEST_INPUT_DIR, 'oo000oo0001', 'oo000oo0001_book.pdf')
TEST_DPG_SPECIAL_PDF2 = File.join(TEST_INPUT_DIR, 'oo000oo0001', '31', 'oo000oo0001_31_001.pdf')
TEST_DPG_SPECIAL_TIF = File.join(TEST_INPUT_DIR, 'oo000oo0001', '50', 'oo000oo0001_50_001.tif')

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

TEST_OBJ_FILE = File.join(TEST_INPUT_DIR, 'someobject.obj')
TEST_PLY_FILE = File.join(TEST_INPUT_DIR, 'someobject.ply')

TEST_DRUID = 'nx288wh8889'

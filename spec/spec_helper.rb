bootfile = File.expand_path(File.dirname(__FILE__) + '/../config/boot')
require bootfile

TEST_DATA_DIR = File.join(Assembly::PATH_TO_GEM,'spec','test_data')
TEST_INPUT_DIR       = File.join(TEST_DATA_DIR,'input')
TEST_OUTPUT_DIR      = File.join(TEST_DATA_DIR,'output')
TEST_TIF_INPUT_FILE  = File.join(TEST_INPUT_DIR,'test.tif')
TEST_TIF_INPUT_FILE2  = File.join(TEST_INPUT_DIR,'test2.tif')
TEST_JPEG_INPUT_FILE  = File.join(TEST_INPUT_DIR,'test.jpg')
TEST_JP2_INPUT_FILE  = File.join(TEST_INPUT_DIR,'test.jp2')
TEST_JP2_INPUT_FILE2  = File.join(TEST_INPUT_DIR,'test2.jp2')
TEST_JP2_OUTPUT_FILE = File.join(TEST_OUTPUT_DIR,'test.jp2')
TEST_PDF_FILE = File.join(TEST_INPUT_DIR,'test.pdf')

TEST_DPG_TIF=File.join(TEST_INPUT_DIR,'oo000oo0001','00','oo000oo0001_00_001.tif')
TEST_DPG_TIF2=File.join(TEST_INPUT_DIR,'oo000oo0001','00','oo000oo0001_00_002.tif')
TEST_DPG_JP=File.join(TEST_INPUT_DIR,'oo000oo0001','05','oo000oo0001_05_001.jp2')
TEST_DPG_JP2=File.join(TEST_INPUT_DIR,'oo000oo0001','05','oo000oo0001_05_002.jp2')
TEST_DPG_PDF=File.join(TEST_INPUT_DIR,'oo000oo0001','15','oo000oo0001_15_001.pdf')
TEST_DPG_PDF2=File.join(TEST_INPUT_DIR,'oo000oo0001','15','oo000oo0001_15_002.pdf')
TEST_DPG_SPECIAL_PDF1=File.join(TEST_INPUT_DIR,'oo000oo0001','oo000oo0001_book.pdf')
TEST_DPG_SPECIAL_PDF2=File.join(TEST_INPUT_DIR,'oo000oo0001','31','oo000oo0001_31_001.pdf')
TEST_DPG_SPECIAL_TIF=File.join(TEST_INPUT_DIR,'oo000oo0001','50','oo000oo0001_50_001.tif')

TEST_DRUID           = "nx288wh8889"

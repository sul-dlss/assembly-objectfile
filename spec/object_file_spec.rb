require 'spec_helper'

describe Assembly::ObjectFile do
  
  it "should not run if no input file is passed in" do
    @ai=Assembly::ObjectFile.new('')
    expect{@ai.filesize}.to raise_error RuntimeError
    expect{@ai.sha1}.to raise_error RuntimeError
    expect{@ai.md5}.to raise_error RuntimeError
  end

  it "should return the common directory of a set of filenames passed into it, where the common part does not terminate on a directory" do
    expect(Assembly::ObjectFile.common_path(['/Users/peter/00/test.tif','/Users/peter/05/test.jp2'])).to eq("/Users/peter/")    
  end

  it "should return the common directory of a set of filenames passed into it, where the common part does not terminate on a directory" do
    expect(Assembly::ObjectFile.common_path(['/Users/peter/00/test.tif','/Users/peter/00/test.jp2'])).to eq("/Users/peter/00/")    
  end
  
  it "should tell us if an input file is an image" do
    expect(File.exists?(TEST_TIF_INPUT_FILE)).to be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    expect(@ai.image?).to eq(true)
    expect(@ai.exif).not_to be nil
    expect(@ai.mimetype).to eq('image/tiff')
    expect(@ai.file_mimetype).to eq('image/tiff')
    expect(@ai.object_type).to eq(:image)
    expect(@ai.valid_image?).to eq(true)
    expect(@ai.jp2able?).to eq(true)
  end
  
  it "should tell us information about the input file" do
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    expect(@ai.filename).to eq("test.tif")
    expect(@ai.ext).to eq(".tif")
    expect(@ai.filename_without_ext).to eq("test")
    expect(@ai.dirname).to eq(File.dirname(TEST_TIF_INPUT_FILE))
  end

  it "should give us the mimetype of a file even if the exif information is damaged" do
    @ai = Assembly::ObjectFile.new(TEST_FILE_NO_EXIF)
    expect(@ai.filename).to eq("file_with_no_exif.xml")
    expect(@ai.ext).to eq(".xml")
    expect(['text/html','application/xml'].include?(@ai.mimetype)).to be true # we could get either of these mimetypes depending on the OS
  end

  it "should give us the DPG base name for a file" do
    test_file=File.join(TEST_INPUT_DIR,'oo000oo0001_00_001.tif')
    @ai = Assembly::ObjectFile.new(test_file)
    expect(@ai.dpg_basename).to eq("oo000oo0001_001")
  end

  it "should give us the DPG subfolder name for a file" do
    test_file=File.join(TEST_INPUT_DIR,'oo000oo0001_05_001.tif')
    @ai = Assembly::ObjectFile.new(test_file)
    expect(@ai.dpg_folder).to eq("05")
  end
  
  it "should tell us that a jp2 file is not jp2able but does have a color profile" do
    expect(File.exists?(TEST_JP2_INPUT_FILE)).to be true
    @ai = Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE)
    expect(@ai.image?).to eq(true)
    expect(@ai.object_type).to eq(:image)
    expect(@ai.valid_image?).to eq(true)
    expect(@ai.jp2able?).to eq(false)
    expect(@ai.has_color_profile?).to eq(true)
  end

  it "should tell us that a tiff file is jp2able and has a color profile" do
    expect(File.exists?(TEST_RES1_TIF1)).to be true
    @ai = Assembly::ObjectFile.new(TEST_RES1_TIF1)
    expect(@ai.image?).to eq(true)
    expect(@ai.object_type).to eq(:image)
    expect(@ai.valid_image?).to eq(true)
    expect(@ai.jp2able?).to eq(true)
    expect(@ai.has_color_profile?).to eq(true)
  end
  
  it "should tell us that a tiff file is not jp2able and is not valid since it has no profile" do
    expect(File.exists?(TEST_TIFF_NO_COLOR_FILE)).to be true
    @ai = Assembly::ObjectFile.new(TEST_TIFF_NO_COLOR_FILE)
    expect(@ai.image?).to eq(true)
    expect(@ai.object_type).to eq(:image)
    expect(@ai.valid_image?).to eq(true)
    expect(@ai.jp2able?).to eq(true)
    expect(@ai.has_color_profile?).to eq(false)
  end
    
  it "should compute checksums for an image file" do
    expect(File.exists?(TEST_TIF_INPUT_FILE)).to be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    expect(@ai.md5).to eq('a2400500acf21e43f5440d93be894101')
    expect(@ai.sha1).to eq('8d11fab63089a24c8b17063d29a4b0eac359fb41')
  end

  it "should indicate that the file is not found when a valid directory is supplied instead of a file or when an invalid file path is specified" do
    path=Assembly::PATH_TO_GEM
    @ai = Assembly::ObjectFile.new(path)
    expect(File.exists?(path)).to be true
    expect(File.directory?(path)).to be true
    expect(@ai.file_exists?).to be false
    
    path=File.join(Assembly::PATH_TO_GEM,'bogus.txt')
    @ai = Assembly::ObjectFile.new(path)
    expect(File.exists?(path)).to be false
    expect(File.directory?(path)).to be false
    expect(@ai.file_exists?).to be false    
  end
  
  it "should tell us if an input file is not an image" do
    non_image_file=File.join(Assembly::PATH_TO_GEM,'spec/object_file_spec.rb')
    expect(File.exists?(non_image_file)).to be true
    @ai = Assembly::ObjectFile.new(non_image_file)
    expect(@ai.image?).to eq(false)
    expect(@ai.object_type).not_to eq(:image)
    expect(@ai.valid_image?).to eq(false)

    non_image_file=File.join(Assembly::PATH_TO_GEM,'README.rdoc')
    expect(File.exists?(non_image_file)).to be true
    @ai = Assembly::ObjectFile.new(non_image_file)
    expect(@ai.image?).to eq(false)
    expect(@ai.object_type).to eq(:other)    
    expect(@ai.valid_image?).to eq(false)    
  end

  it "should tell us the size of an input file" do
    expect(File.exists?(TEST_TIF_INPUT_FILE)).to be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    expect(@ai.filesize).to eq(63542)
  end

  it "should tell us the mimetype and encoding of an input file" do
    expect(File.exists?(TEST_TIF_INPUT_FILE)).to be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    expect(@ai.mimetype).to eq('image/tiff')
    expect(@ai.file_mimetype).to eq('image/tiff')
    expect(@ai.encoding).to eq('binary')
  end
        
end
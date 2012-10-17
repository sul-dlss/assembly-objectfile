describe Assembly::ObjectFile do
  
  it "should not run if no input file is passed in" do
    @ai=Assembly::ObjectFile.new('')
    lambda{@ai.filesize}.should raise_error
    lambda{@ai.sha1}.should raise_error
    lambda{@ai.md5}.should raise_error
  end

  it "should return the common directory of a set of filenames passed into it, where the common part does not terminate on a directory" do
    Assembly::ObjectFile.common_path(['/Users/peter/00/test.tif','/Users/peter/05/test.jp2']).should == "/Users/peter/"    
  end

  it "should return the common directory of a set of filenames passed into it, where the common part does not terminate on a directory" do
    Assembly::ObjectFile.common_path(['/Users/peter/00/test.tif','/Users/peter/00/test.jp2']).should == "/Users/peter/00/"    
  end
  
  it "should tell us if an input file is an image" do
    File.exists?(TEST_TIF_INPUT_FILE).should be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    @ai.image?.should == true
    @ai.exif.should_not be nil
    @ai.mimetype.should == 'image/tiff'
    @ai.object_type.should == :image
    @ai.valid_image?.should == true
    @ai.jp2able?.should == true
  end

  it "should tell us information about the input file" do
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    @ai.filename.should == "test.tif"
    @ai.ext.should == ".tif"
    @ai.filename_without_ext.should == "test"
  end

  it "should give us the mimetype of a file even if the exif information is damaged" do
    @ai = Assembly::ObjectFile.new(TEST_FILE_NO_EXIF)
    @ai.filename.should == "file_with_no_exif.xml"
    @ai.ext.should == ".xml"
    ['text/html','application/xml'].include?(@ai.mimetype).should be true # we could get either of these mimetypes depending on the OS
  end

  it "should give us the DPG base name for a file" do
    test_file=File.join(TEST_INPUT_DIR,'oo000oo0001_00_001.tif')
    @ai = Assembly::ObjectFile.new(test_file)
    @ai.dpg_basename.should == "oo000oo0001_001"
  end

  it "should give us the DPG subfolder name for a file" do
    test_file=File.join(TEST_INPUT_DIR,'oo000oo0001_05_001.tif')
    @ai = Assembly::ObjectFile.new(test_file)
    @ai.dpg_folder.should == "05"
  end
  
  it "should tell us that a jp2 file not jp2able and is not valid since it has no profile" do
    File.exists?(TEST_JP2_INPUT_FILE).should be true
    @ai = Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE)
    @ai.image?.should == true
    @ai.object_type.should == :image
    @ai.valid_image?.should == true
    @ai.jp2able?.should == false
  end
    
  it "should compute checksums for an image file" do
    File.exists?(TEST_TIF_INPUT_FILE).should be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    @ai.md5.should == 'a2400500acf21e43f5440d93be894101'
    @ai.sha1.should == '8d11fab63089a24c8b17063d29a4b0eac359fb41'
  end

  it "should indicate that the file is not found when a valid directory is supplied instead of a file or when an invalid file path is specified" do
    path=Assembly::PATH_TO_GEM
    @ai = Assembly::ObjectFile.new(path)
    File.exists?(path).should be true
    File.directory?(path).should be true
    @ai.file_exists?.should be false
    
    path=File.join(Assembly::PATH_TO_GEM,'bogus.txt')
    @ai = Assembly::ObjectFile.new(path)
    File.exists?(path).should be false
    File.directory?(path).should be false
    @ai.file_exists?.should be false    
  end
  
  it "should tell us if an input file is not an image" do
    non_image_file=File.join(Assembly::PATH_TO_GEM,'spec/object_file_spec.rb')
    File.exists?(non_image_file).should be true
    @ai = Assembly::ObjectFile.new(non_image_file)
    @ai.image?.should == false
    @ai.object_type.should == :text    
    @ai.valid_image?.should == false

    non_image_file=File.join(Assembly::PATH_TO_GEM,'README.rdoc')
    File.exists?(non_image_file).should be true
    @ai = Assembly::ObjectFile.new(non_image_file)
    @ai.image?.should == false
    @ai.object_type.should == :text    
    @ai.valid_image?.should == false    
  end

  it "should tell us the size of an input file" do
    File.exists?(TEST_TIF_INPUT_FILE).should be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    @ai.filesize.should == 63542
  end

  it "should tell us the mimetype and encoding of an input file" do
    File.exists?(TEST_TIF_INPUT_FILE).should be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    @ai.mimetype.should == 'image/tiff'
    @ai.encoding.should == 'binary'
  end
        
end
describe Assembly::ObjectFile do

  it "should not run if no input file is passed in" do
    @ai=Assembly::ObjectFile.new('')
    lambda{@ai.filesize}.should raise_error
  end

  it "should tell us if an input file is an image" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    File.exists?(TEST_TIF_INPUT_FILE).should be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    @ai.image?.should == true
    @ai.object_type.should == :image
    @ai.valid_image?.should == true
  end
  
  it "should tell us if an input file is not an image" do
    non_image_file=File.join(Assembly::PATH_TO_GEM,'spec/item_spec.rb')
    File.exists?(non_image_file).should be true
    @ai = Assembly::ObjectFile.new(non_image_file)
    @ai.image?.should == false
    @ai.object_type.should == :text    
    @ai.valid_image?.should == false
  end

  it "should tell us the size of an input file" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    File.exists?(TEST_TIF_INPUT_FILE).should be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    @ai.filesize.should == 63542
  end

  it "should tell us the mimetype and encoding of an input file" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    File.exists?(TEST_TIF_INPUT_FILE).should be true
    @ai = Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    @ai.mimetype.should == 'image/tiff'
    @ai.encoding.should == 'charset=binary'
  end
        
end
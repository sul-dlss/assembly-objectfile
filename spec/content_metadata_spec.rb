describe Assembly::ContentMetadata do

  it "should generate valid content metadata with exif for a single tif and jp2 of style=simple_image" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    generate_test_image(TEST_JP2_INPUT_FILE)
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE)]
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:add_exif=>true,:add_file_attributes=>true,:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "image"
    xml.xpath("//resource").length.should be 2
    xml.xpath("//resource/file").length.should be 2
    xml.xpath("//resource/file/checksum").length.should be 4  
    xml.xpath("//resource/file/checksum")[0].text.should == "8d11fab63089a24c8b17063d29a4b0eac359fb41"
    xml.xpath("//resource/file/checksum")[1].text.should == "a2400500acf21e43f5440d93be894101"
    xml.xpath("//resource/file/checksum")[2].text.should == "b965b5787e0100ec2d43733144120feab327e88c"      
    xml.xpath("//resource/file/checksum")[3].text.should == "4eb54050d374291ece622d45e84f014d"      
    xml.xpath("//label").length.should be 2
    xml.xpath("//label")[0].text.should =~ /Image 1/
    xml.xpath("//label")[1].text.should =~ /Image 2/
    xml.xpath("//resource")[0].attributes['type'].value.should == "image"
    xml.xpath("//resource")[1].attributes['type'].value.should == "image"
    xml.xpath("//resource/file")[0].attributes['size'].value.should == "63542"
    xml.xpath("//resource/file")[0].attributes['mimetype'].value.should == "image/tiff"
    xml.xpath("//resource/file")[0].attributes['publish'].value.should == "no"
    xml.xpath("//resource/file")[0].attributes['preserve'].value.should == "yes"
    xml.xpath("//resource/file")[0].attributes['shelve'].value.should == "no"
    xml.xpath("//resource/file/imageData")[0].attributes['width'].value.should == "100"
    xml.xpath("//resource/file/imageData")[0].attributes['height'].value.should == "100"
    xml.xpath("//resource/file")[1].attributes['size'].value.should == "306"
    xml.xpath("//resource/file")[1].attributes['mimetype'].value.should == "image/jp2"
    xml.xpath("//resource/file")[1].attributes['publish'].value.should == "yes"
    xml.xpath("//resource/file")[1].attributes['preserve'].value.should == "no"
    xml.xpath("//resource/file")[1].attributes['shelve'].value.should == "yes"
    xml.xpath("//resource/file/imageData")[1].attributes['width'].value.should == "100"
    xml.xpath("//resource/file/imageData")[1].attributes['height'].value.should == "100"    
  end

  it "should generate valid content metadata for a single tif and jp2 of style=simple_image with overriding file attributes and no exif data" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    generate_test_image(TEST_JP2_INPUT_FILE)
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:add_file_attributes=>true,:file_attributes=>{'image/tiff'=>{:publish=>'no',:preserve=>'no',:shelve=>'no'},'image/jp2'=>{:publish=>'yes',:preserve=>'yes',:shelve=>'yes'}},:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "image"
    xml.xpath("//resource").length.should be 2
    xml.xpath("//resource/file").length.should be 2
    xml.xpath("//label").length.should be 2
    xml.xpath("//resource/file/imageData").length.should be 0
    xml.xpath("//label")[0].text.should =~ /Image 1/
    xml.xpath("//label")[1].text.should =~ /Image 2/
    xml.xpath("//resource")[0].attributes['type'].value.should == "image"
    xml.xpath("//resource")[1].attributes['type'].value.should == "image"
    xml.xpath("//resource/file")[0].attributes['size'].should be nil
    xml.xpath("//resource/file")[0].attributes['mimetype'].should be nil
    xml.xpath("//resource/file")[0].attributes['publish'].value.should == "no"
    xml.xpath("//resource/file")[0].attributes['preserve'].value.should == "no"
    xml.xpath("//resource/file")[0].attributes['shelve'].value.should == "no"    
    xml.xpath("//resource/file")[1].attributes['size'].should be nil
    xml.xpath("//resource/file")[1].attributes['mimetype'].should be nil
    xml.xpath("//resource/file")[1].attributes['publish'].value.should == "yes"
    xml.xpath("//resource/file")[1].attributes['preserve'].value.should == "yes"
    xml.xpath("//resource/file")[1].attributes['shelve'].value.should == "yes" 
  end

  it "should generate valid content metadata for two tifs two associated jp2s of style=simple_image using bundle=filename and no exif data" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    generate_test_image(TEST_TIF_INPUT_FILE2)
    generate_test_image(TEST_JP2_INPUT_FILE)
    generate_test_image(TEST_JP2_INPUT_FILE2)
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:filename,:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "image"
    xml.xpath("//resource").length.should be 2
    xml.xpath("//resource/file").length.should be 4
    xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value == TEST_TIF_INPUT_FILE
    xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value == TEST_JP2_INPUT_FILE
    xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value == TEST_TIF_INPUT_FILE2
    xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value == TEST_JP2_INPUT_FILE2
    xml.xpath("//label").length.should be 2
    xml.xpath("//resource/file/imageData").length.should be 0
    for i in 0..1 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 2
      xml.xpath("//label")[i].text.should == "Image #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "image"
    end
  end

  it "should generate valid content metadata for two tifs two associated jp2s of style=simple_image using bundle=dpg and no exif data" do
    test_dpg_tif=File.join(TEST_INPUT_DIR,'oo000oo0001_00_001.tif')
    test_dpg_tif2=File.join(TEST_INPUT_DIR,'oo000oo0001_00_002.tif')
    test_dpg_jp=File.join(TEST_INPUT_DIR,'oo000oo0001_05_001.jp2')
    test_dpg_jp2=File.join(TEST_INPUT_DIR,'oo000oo0001_05_002.jp2')
    generate_test_image(test_dpg_tif)
    generate_test_image(test_dpg_tif2)
    generate_test_image(test_dpg_jp)
    generate_test_image(test_dpg_jp2)
    objects=[Assembly::ObjectFile.new(test_dpg_tif),Assembly::ObjectFile.new(test_dpg_jp),Assembly::ObjectFile.new(test_dpg_tif2),Assembly::ObjectFile.new(test_dpg_jp2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:dpg,:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "image"
    xml.xpath("//resource").length.should be 2
    xml.xpath("//resource/file").length.should be 4
    xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value == test_dpg_tif
    xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value == test_dpg_jp
    xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value == test_dpg_tif2
    xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value == test_dpg_jp2
    xml.xpath("//label").length.should be 2
    xml.xpath("//resource/file/imageData").length.should be 0
    for i in 0..1 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 2
      xml.xpath("//label")[i].text.should == "Image #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "image"
    end
  end
  
  it "should generate valid content metadata for two tifs two associated jp2s of style=simple_image using bundle=none and no exif data" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    generate_test_image(TEST_TIF_INPUT_FILE2)
    generate_test_image(TEST_JP2_INPUT_FILE)
    generate_test_image(TEST_JP2_INPUT_FILE2)
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:none,:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "image"
    xml.xpath("//resource").length.should be 4
    xml.xpath("//resource/file").length.should be 4
    xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value == TEST_TIF_INPUT_FILE
    xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value == TEST_JP2_INPUT_FILE
    xml.xpath("//resource[@sequence='3']/file")[0].attributes['id'].value == TEST_TIF_INPUT_FILE2
    xml.xpath("//resource[@sequence='4']/file")[0].attributes['id'].value == TEST_JP2_INPUT_FILE2    
    xml.xpath("//label").length.should be 4
    xml.xpath("//resource/file/imageData").length.should be 0
    for i in 0..3 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 1
      xml.xpath("//label")[i].text.should == "Image #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "image"
    end
  end

  it "should generate valid content metadata for two tifs two associated jp2s of style=file" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    generate_test_image(TEST_TIF_INPUT_FILE2)
    generate_test_image(TEST_JP2_INPUT_FILE)
    generate_test_image(TEST_JP2_INPUT_FILE2)
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:file,:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "file"
    xml.xpath("//resource").length.should be 4
    xml.xpath("//resource/file").length.should be 4
    xml.xpath("//label").length.should be 4
    for i in 0..3 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 1
      xml.xpath("//label")[i].text.should == "File #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "file"
    end
  end
    
  it "should generate valid content metadata for two tifs of style=simple_book" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    generate_test_image(TEST_TIF_INPUT_FILE2)
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2)]        
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:simple_book,:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "book"
    xml.xpath("//resource").length.should be 2
    xml.xpath("//resource/file").length.should be 2
    xml.xpath("//label").length.should be 2
    xml.xpath("//label")[0].text.should =~ /Page 1/
    xml.xpath("//label")[1].text.should =~ /Page 2/
    xml.xpath("//resource/file/imageData").length.should be 0
    for i in 0..1 do
      xml.xpath("//resource/file")[i].attributes['size'].should be nil
      xml.xpath("//resource/file")[i].attributes['mimetype'].should be nil
      xml.xpath("//resource/file")[i].attributes['publish'].should be nil
      xml.xpath("//resource/file")[i].attributes['preserve'].should be nil
      xml.xpath("//resource/file")[i].attributes['shelve'].should be nil  
    end
    xml.xpath("//resource")[0].attributes['type'].value.should == "page"
    xml.xpath("//resource")[1].attributes['type'].value.should == "page"
  end

  it "should generate valid content metadata for two tifs and one pdf of style=book_with_pdf" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    generate_test_image(TEST_TIF_INPUT_FILE2)
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_PDF_FILE)]        
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:book_with_pdf,:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "book"
    xml.xpath("//resource").length.should be 3
    xml.xpath("//resource/file").length.should be 3
    xml.xpath("//label").length.should be 3
    xml.xpath("//label")[0].text.should =~ /Page 1/
    xml.xpath("//label")[1].text.should =~ /Page 2/
    xml.xpath("//label")[2].text.should =~ /File 1/
    xml.xpath("//resource/file/imageData").length.should be 0
    xml.xpath("//resource")[0].attributes['type'].value.should == "page"
    xml.xpath("//resource")[1].attributes['type'].value.should == "page"
    xml.xpath("//resource")[2].attributes['type'].value.should == "file"
  end
  
   it "should generate valid content metadata for two tifs of style=book_as_image" do
     generate_test_image(TEST_TIF_INPUT_FILE)
     generate_test_image(TEST_TIF_INPUT_FILE2)
     objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2)]             
     result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:book_as_image,:objects=>objects)
     result.class.should be String
     xml = Nokogiri::XML(result)
     xml.errors.size.should be 0
     xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "book"
     xml.xpath("//resource").length.should be 2
     xml.xpath("//resource/file").length.should be 2
     xml.xpath("//label").length.should be 2
     xml.xpath("//label")[0].text.should =~ /Image 1/
     xml.xpath("//label")[1].text.should =~ /Image 2/
     xml.xpath("//resource/file/imageData").length.should be 0
     for i in 0..1 do
       xml.xpath("//resource/file")[i].attributes['size'].should be nil
       xml.xpath("//resource/file")[i].attributes['mimetype'].should be nil
       xml.xpath("//resource/file")[i].attributes['publish'].should be nil
       xml.xpath("//resource/file")[i].attributes['preserve'].should be nil
       xml.xpath("//resource/file")[i].attributes['shelve'].should be nil  
     end    
     xml.xpath("//resource")[0].attributes['type'].value.should == "image"
     xml.xpath("//resource")[1].attributes['type'].value.should == "image"
   end

   it "should generate valid content metadata with no exif but with user supplied checksums for two tifs of style=simple_image" do
     generate_test_image(TEST_TIF_INPUT_FILE)
     generate_test_image(TEST_TIF_INPUT_FILE2)
     obj1=Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
     obj1.provider_md5='123456789'
     obj1.provider_sha1='abcdefgh'
     obj2=Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2)
     obj2.provider_md5='qwerty'
     objects=[obj1,obj2]        
     result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:simple_book,:objects=>objects)
     result.class.should be String
     xml = Nokogiri::XML(result)
     xml.errors.size.should be 0
     xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "book"
     xml.xpath("//resource").length.should be 2
     xml.xpath("//resource/file").length.should be 2
     xml.xpath("//resource/file/checksum").length.should be 3
     xml.xpath("//label").length.should be 2
     xml.xpath("//label")[0].text.should =~ /Page 1/
     xml.xpath("//label")[1].text.should =~ /Page 2/
     xml.xpath("//resource/file/imageData").length.should be 0
     xml.xpath("//resource/file/checksum")[0].text.should == "abcdefgh"
     xml.xpath("//resource/file/checksum")[1].text.should == "123456789"
     xml.xpath("//resource/file/checksum")[2].text.should == "qwerty"     
     for i in 0..1 do
       xml.xpath("//resource/file")[i].attributes['size'].should be nil
       xml.xpath("//resource/file")[i].attributes['mimetype'].should be nil
       xml.xpath("//resource/file")[i].attributes['publish'].should be nil
       xml.xpath("//resource/file")[i].attributes['preserve'].should be nil
       xml.xpath("//resource/file")[i].attributes['shelve'].should be nil  
     end
     xml.xpath("//resource")[0].attributes['type'].value.should == "page"
     xml.xpath("//resource")[1].attributes['type'].value.should == "page"
   end
   
  it "should not generate valid content metadata if not all input files exist" do
    generate_test_image(TEST_TIF_INPUT_FILE)
    File.exists?(TEST_TIF_INPUT_FILE).should be true
    File.exists?(TEST_JP2_INPUT_FILE).should be false
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE)]  
    lambda {Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:objects=>objects)}.should raise_error 
  end

  after(:each) do
    # after each test, empty out the input and output test directories
    remove_files(TEST_INPUT_DIR)
    remove_files(TEST_OUTPUT_DIR)
  end

end

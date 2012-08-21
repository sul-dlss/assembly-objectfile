describe Assembly::ContentMetadata do
  
  it "should generate valid content metadata with exif for a single tif and jp2 of style=simple_image" do
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

  it "should generate valid content metadata with exif for a single tif and jp2 of style=simple_image overriding file labels" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE,:label=>'Sample tif label!'),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE,:label=>'Sample jp2 label!')]
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
    xml.xpath("//label")[0].text.should =~ /Sample tif label!/
    xml.xpath("//label")[1].text.should =~ /Sample jp2 label!/
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
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:filename,:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "image"
    xml.xpath("//resource").length.should be 2
    xml.xpath("//resource/file").length.should be 4
    xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value.should == 'test.tif'
    xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value.should == 'test.jp2'
    xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value.should == 'test2.tif'
    xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value.should == 'test2.jp2'
    xml.xpath("//label").length.should be 2
    xml.xpath("//resource/file/imageData").length.should be 0
    for i in 0..1 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 2
      xml.xpath("//label")[i].text.should == "Image #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "image"
    end
  end

  it "should generate valid content metadata for two tifs two associated jp2s of style=simple_image using bundle=dpg and no exif data and no root xml node" do
    objects=[Assembly::ObjectFile.new(TEST_DPG_TIF),Assembly::ObjectFile.new(TEST_DPG_JP),Assembly::ObjectFile.new(TEST_DPG_TIF2),Assembly::ObjectFile.new(TEST_DPG_JP2)]    
    test_druid="#{TEST_DRUID}"
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>test_druid,:bundle=>:dpg,:objects=>objects,:include_root_xml=>false)
    result.class.should be String
    result.include?('<?xml').should be false   
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "image"
    test_druid.should == TEST_DRUID
    xml.xpath("//contentMetadata")[0].attributes['objectId'].value.should == "#{TEST_DRUID}"    
    xml.xpath("//resource").length.should be 2
    xml.xpath("//resource/file").length.should be 4
    xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value.should == "00/oo000oo0001_00_001.tif"
    xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value.should == "05/oo000oo0001_05_001.jp2"
    xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value.should == "00/oo000oo0001_00_002.tif"
    xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value.should == "05/oo000oo0001_05_002.jp2"
    xml.xpath("//label").length.should be 2
    xml.xpath("//resource/file/imageData").length.should be 0
    for i in 0..1 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 2
      xml.xpath("//label")[i].text.should == "Image #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "image"
    end
  end

  it "should generate valid content metadata for two tifs, two associated jp2s, one combined pdf and one special tif of style=simple_book using bundle=dpg and no exif data and no root xml node, flattening folder structure" do
    objects=[Assembly::ObjectFile.new(TEST_DPG_SPECIAL_PDF2),Assembly::ObjectFile.new(TEST_DPG_SPECIAL_TIF),Assembly::ObjectFile.new(TEST_DPG_TIF),Assembly::ObjectFile.new(TEST_DPG_JP),Assembly::ObjectFile.new(TEST_DPG_TIF2),Assembly::ObjectFile.new(TEST_DPG_JP2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:simple_book,:bundle=>:dpg,:objects=>objects,:include_root_xml=>false,:flatten_folder_structure=>true)
    result.class.should be String
    result.include?('<?xml').should be false 
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "book"
    xml.xpath("//contentMetadata")[0].attributes['objectId'].value.should == "#{TEST_DRUID}"    
    xml.xpath("//resource").length.should be 4
    xml.xpath("//resource/file").length.should be 6
    xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value.should == "oo000oo0001_00_001.tif"
    xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value.should == "oo000oo0001_05_001.jp2"
    xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value.should == "oo000oo0001_00_002.tif"
    xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value.should == "oo000oo0001_05_002.jp2"
    xml.xpath("//resource[@sequence='3']/file")[0].attributes['id'].value.should == "oo000oo0001_31_001.pdf"
    xml.xpath("//resource[@sequence='4']/file")[0].attributes['id'].value.should == "oo000oo0001_50_001.tif"
    xml.xpath("//label").length.should be 4
    xml.xpath("//resource/file/imageData").length.should be 0
    for i in 0..1 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 2
      xml.xpath("//label")[i].text.should == "Page #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "page"
    end
    xml.xpath("//resource[@sequence='3']/file").length.should be 1
    xml.xpath("//label")[2].text.should == "Object 1"
    xml.xpath("//resource")[2].attributes['type'].value.should == "object"
    xml.xpath("//resource[@sequence='4']/file").length.should be 1
    xml.xpath("//label")[3].text.should == "Object 2"
    xml.xpath("//resource")[3].attributes['type'].value.should == "object"
  end
  
  it "should generate valid content metadata with item having a 'druid:' prefix for two tifs,two associated jp2s,two associated pdfs, and one lingering PDF of style=simple_book using bundle=dpg, flattening folder structure" do
    objects=[Assembly::ObjectFile.new(TEST_DPG_TIF),Assembly::ObjectFile.new(TEST_DPG_JP),Assembly::ObjectFile.new(TEST_DPG_PDF),Assembly::ObjectFile.new(TEST_DPG_TIF2),Assembly::ObjectFile.new(TEST_DPG_JP2),Assembly::ObjectFile.new(TEST_DPG_PDF2),Assembly::ObjectFile.new(TEST_DPG_SPECIAL_PDF1)]    
    test_druid="druid:#{TEST_DRUID}"
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>test_druid,:bundle=>:dpg,:objects=>objects,:style=>:simple_book,:flatten_folder_structure=>true)
    result.class.should be String
    result.include?('<?xml').should be true
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "book"
    xml.xpath("//contentMetadata")[0].attributes['objectId'].value.should == "#{TEST_DRUID}"
    test_druid.should == "druid:#{TEST_DRUID}"
    xml.xpath("//resource").length.should be 3
    xml.xpath("//resource/file").length.should be 7                                  
    
    xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value.should == "oo000oo0001_00_001.tif"
    xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value.should == "oo000oo0001_05_001.jp2"
    xml.xpath("//resource[@sequence='1']/file")[2].attributes['id'].value.should == "oo000oo0001_15_001.pdf"
    xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value.should == "oo000oo0001_00_002.tif"
    xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value.should == "oo000oo0001_05_002.jp2"
    xml.xpath("//resource[@sequence='2']/file")[2].attributes['id'].value.should == "oo000oo0001_15_002.pdf"
    xml.xpath("//resource[@sequence='3']/file")[0].attributes['id'].value.should == "oo000oo0001_book.pdf"
    xml.xpath("//label").length.should be 3
    xml.xpath("//resource/file/imageData").length.should be 0
    for i in 0..1 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 3
      xml.xpath("//label")[i].text.should == "Page #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "page"
    end
    xml.xpath("//resource[@sequence='3']/file").length.should be 1
    xml.xpath("//label")[2].text.should == "Object 1"
    xml.xpath("//resource")[2].attributes['type'].value.should == "object"
  end

  it "should generate valid content metadata for two tifs,two associated jp2s,two associated pdfs, and one lingering PDF of style=book_with_pdf using bundle=dpg" do
    objects=[Assembly::ObjectFile.new(TEST_DPG_TIF),Assembly::ObjectFile.new(TEST_DPG_JP),Assembly::ObjectFile.new(TEST_DPG_PDF),Assembly::ObjectFile.new(TEST_DPG_TIF2),Assembly::ObjectFile.new(TEST_DPG_JP2),Assembly::ObjectFile.new(TEST_DPG_SPECIAL_PDF1)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:dpg,:objects=>objects,:style=>:book_with_pdf)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "book"
    xml.xpath("//resource").length.should be 3
    xml.xpath("//resource/file").length.should be 6
    xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value.should == "00/oo000oo0001_00_001.tif"
    xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value.should == "05/oo000oo0001_05_001.jp2" 
    xml.xpath("//resource[@sequence='1']/file")[2].attributes['id'].value.should == "15/oo000oo0001_15_001.pdf" 
    xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value.should == "00/oo000oo0001_00_002.tif"
    xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value.should == "05/oo000oo0001_05_002.jp2" 
    xml.xpath("//resource[@sequence='3']/file")[0].attributes['id'].value.should == "oo000oo0001_book.pdf"
    xml.xpath("//label").length.should be 3
    xml.xpath("//resource/file/imageData").length.should be 0
    xml.xpath("//resource[@sequence='1']/file").length.should be 3
    xml.xpath("//label")[0].text.should == "Object 1"
    xml.xpath("//resource")[0].attributes['type'].value.should == "object"
    xml.xpath("//resource[@sequence='2']/file").length.should be 2
    xml.xpath("//label")[1].text.should == "Page 1"
    xml.xpath("//resource")[1].attributes['type'].value.should == "page"
    xml.xpath("//resource[@sequence='3']/file").length.should be 1
    xml.xpath("//label")[2].text.should == "Object 2"
    xml.xpath("//resource")[2].attributes['type'].value.should == "object"
  end
    
  it "should generate valid content metadata for two tifs two associated jp2s of style=simple_image using bundle=default and no exif data" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:default,:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "image"
    xml.xpath("//resource").length.should be 4
    xml.xpath("//resource/file").length.should be 4  
    xml.xpath("//resource/file")[0].attributes['id'].value.should == 'test.tif'     
    xml.xpath("//resource/file")[1].attributes['id'].value.should == 'test.jp2'
    xml.xpath("//resource/file")[2].attributes['id'].value.should == 'test2.tif'
    xml.xpath("//resource/file")[3].attributes['id'].value.should == 'test2.jp2'    
    xml.xpath("//label").length.should be 4
    xml.xpath("//resource/file/imageData").length.should be 0
    for i in 0..3 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 1
      xml.xpath("//label")[i].text.should == "Image #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "image"
    end
  end

  it "should generate valid content metadata for two tifs two associated jp2s of style=simple_image using bundle=default and no exif data, preserving full paths" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:default,:objects=>objects,:preserve_common_paths=>true)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "image"
    xml.xpath("//resource").length.should be 4
    xml.xpath("//resource/file").length.should be 4
    xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value.should == TEST_TIF_INPUT_FILE
    xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value.should == TEST_JP2_INPUT_FILE
    xml.xpath("//resource[@sequence='3']/file")[0].attributes['id'].value.should == TEST_TIF_INPUT_FILE2
    xml.xpath("//resource[@sequence='4']/file")[0].attributes['id'].value.should == TEST_JP2_INPUT_FILE2   
    xml.xpath("//label").length.should be 4
    xml.xpath("//resource/file/imageData").length.should be 0
    for i in 0..3 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 1
      xml.xpath("//label")[i].text.should == "Image #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "image"
    end
  end
  
  it "should generate valid content metadata for two tifs two associated jp2s of style=file using specific content metadata paths" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    objects[0].relative_path='input/test.tif'
    objects[1].relative_path='input/test.jp2'
    objects[2].relative_path='input/test2.tif'
    objects[3].relative_path='input/test2.jp2'
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:file,:objects=>objects)
    result.class.should be String
    xml = Nokogiri::XML(result)
    xml.errors.size.should be 0
    xml.xpath("//contentMetadata")[0].attributes['type'].value.should == "file"
    xml.xpath("//resource").length.should be 4
    xml.xpath("//resource/file").length.should be 4
    xml.xpath("//label").length.should be 4
    xml.xpath("//resource/file")[0].attributes['id'].value.should == 'input/test.tif'
    xml.xpath("//resource/file")[1].attributes['id'].value.should == 'input/test.jp2'
    xml.xpath("//resource/file")[2].attributes['id'].value.should == 'input/test2.tif'
    xml.xpath("//resource/file")[3].attributes['id'].value.should == 'input/test2.jp2'
    for i in 0..3 do
      xml.xpath("//resource[@sequence='#{i+1}']/file").length.should be 1
      xml.xpath("//label")[i].text.should == "File #{i+1}"
      xml.xpath("//resource")[i].attributes['type'].value.should == "file"
    end
  end
    
  it "should generate valid content metadata for two tifs of style=simple_book" do
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
    xml.xpath("//label")[2].text.should =~ /Object 1/
    xml.xpath("//resource/file/imageData").length.should be 0
    xml.xpath("//resource")[0].attributes['type'].value.should == "page"
    xml.xpath("//resource")[1].attributes['type'].value.should == "page"
    xml.xpath("//resource")[2].attributes['type'].value.should == "object"
  end
  
   it "should generate valid content metadata for two tifs of style=book_as_image" do
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

   it "should generate valid content metadata with no exif but with user supplied checksums for two tifs of style=simple_book" do
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
    File.exists?(TEST_TIF_INPUT_FILE).should be true
    junk_file='/tmp/flim_flam_floom.jp2'
    File.exists?(junk_file).should be false
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(junk_file)]  
    lambda {Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:objects=>objects)}.should raise_error 
  end

end

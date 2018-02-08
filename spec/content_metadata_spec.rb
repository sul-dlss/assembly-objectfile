require 'spec_helper'

describe Assembly::ContentMetadata do
  
  it "should generate valid content metadata with exif for a single tif and jp2 of style=simple_image, adding file attributes" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE)]
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:add_exif=>true,:add_file_attributes=>true,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource").length).to be 2
    expect(xml.xpath("//resource/file").length).to be 2
    expect(xml.xpath("//resource/file/checksum").length).to be 4  
    expect(xml.xpath("//resource/file/checksum")[0].text).to eq("8d11fab63089a24c8b17063d29a4b0eac359fb41")
    expect(xml.xpath("//resource/file/checksum")[1].text).to eq("a2400500acf21e43f5440d93be894101")
    expect(xml.xpath("//resource/file/checksum")[2].text).to eq("b965b5787e0100ec2d43733144120feab327e88c")      
    expect(xml.xpath("//resource/file/checksum")[3].text).to eq("4eb54050d374291ece622d45e84f014d")      
    expect(xml.xpath("//label").length).to be 2
    expect(xml.xpath("//label")[0].text).to match(/Image 1/)
    expect(xml.xpath("//label")[1].text).to match(/Image 2/)
    expect(xml.xpath("//resource")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource")[1].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource/file")[0].attributes['size'].value).to eq("63542")
    expect(xml.xpath("//resource/file")[0].attributes['mimetype'].value).to eq("image/tiff")
    expect(xml.xpath("//resource/file")[0].attributes['publish'].value).to eq("no")
    expect(xml.xpath("//resource/file")[0].attributes['preserve'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[0].attributes['shelve'].value).to eq("no")
    expect(xml.xpath("//resource/file/imageData")[0].attributes['width'].value).to eq("100")
    expect(xml.xpath("//resource/file/imageData")[0].attributes['height'].value).to eq("100")
    expect(xml.xpath("//resource/file")[1].attributes['size'].value).to eq("306")
    expect(xml.xpath("//resource/file")[1].attributes['mimetype'].value).to eq("image/jp2")
    expect(xml.xpath("//resource/file")[1].attributes['publish'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[1].attributes['preserve'].value).to eq("no")
    expect(xml.xpath("//resource/file")[1].attributes['shelve'].value).to eq("yes")
    expect(xml.xpath("//resource/file/imageData")[1].attributes['width'].value).to eq("100")
    expect(xml.xpath("//resource/file/imageData")[1].attributes['height'].value).to eq("100")    
  end

  it "should generate valid content metadata with no exif for a single tif and jp2 of style=simple_image, adding specific file attributes for 2 objects, and defaults for 1 object" do
    obj1=Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    obj2=Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE)
    obj3=Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)
    obj1.file_attributes={:publish=>'no',:preserve=>'no',:shelve=>'no'}
    obj2.file_attributes={:publish=>'yes',:preserve=>'yes',:shelve=>'yes'}
    objects=[obj1,obj2,obj3]
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:add_exif=>false,:add_file_attributes=>true,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource").length).to be 3
    expect(xml.xpath("//resource/file").length).to be 3
    expect(xml.xpath("//resource/file/checksum").length).to be 0   
    expect(xml.xpath("//resource/file/imageData").length).to be 0       
    expect(xml.xpath("//label").length).to be 3
    expect(xml.xpath("//label")[0].text).to match(/Image 1/)
    expect(xml.xpath("//label")[1].text).to match(/Image 2/)
    expect(xml.xpath("//label")[2].text).to match(/Image 3/)
    expect(xml.xpath("//resource")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource")[1].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource")[2].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource/file")[0].attributes['publish'].value).to eq("no")    # specificially set in object
    expect(xml.xpath("//resource/file")[0].attributes['preserve'].value).to eq("no") # specificially set in object
    expect(xml.xpath("//resource/file")[0].attributes['shelve'].value).to eq("no") # specificially set in object
    expect(xml.xpath("//resource/file")[1].attributes['publish'].value).to eq("yes") # specificially set in object
    expect(xml.xpath("//resource/file")[1].attributes['preserve'].value).to eq("yes")  # specificially set in object
    expect(xml.xpath("//resource/file")[1].attributes['shelve'].value).to eq("yes")  # specificially set in object
    expect(xml.xpath("//resource/file")[2].attributes['publish'].value).to eq("yes") # defaults by mimetype
    expect(xml.xpath("//resource/file")[2].attributes['preserve'].value).to eq("no") # defaults by mimetype
    expect(xml.xpath("//resource/file")[2].attributes['shelve'].value).to eq("yes")    # defaults by mimetype 
  end


  it "should generate valid content metadata with exif for a single tif and jp2 of style=simple_image overriding file labels" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE,:label=>'Sample tif label!'),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE,:label=>'Sample jp2 label!')]
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:add_exif=>true,:add_file_attributes=>true,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource").length).to be 2
    expect(xml.xpath("//resource/file").length).to be 2
    expect(xml.xpath("//resource/file/checksum").length).to be 4  
    expect(xml.xpath("//resource/file/checksum")[0].text).to eq("8d11fab63089a24c8b17063d29a4b0eac359fb41")
    expect(xml.xpath("//resource/file/checksum")[1].text).to eq("a2400500acf21e43f5440d93be894101")
    expect(xml.xpath("//resource/file/checksum")[2].text).to eq("b965b5787e0100ec2d43733144120feab327e88c")      
    expect(xml.xpath("//resource/file/checksum")[3].text).to eq("4eb54050d374291ece622d45e84f014d")      
    expect(xml.xpath("//label").length).to be 2
    expect(xml.xpath("//label")[0].text).to match(/Sample tif label!/)
    expect(xml.xpath("//label")[1].text).to match(/Sample jp2 label!/)
    expect(xml.xpath("//resource")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource")[1].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource/file")[0].attributes['size'].value).to eq("63542")
    expect(xml.xpath("//resource/file")[0].attributes['mimetype'].value).to eq("image/tiff")
    expect(xml.xpath("//resource/file")[0].attributes['publish'].value).to eq("no")
    expect(xml.xpath("//resource/file")[0].attributes['preserve'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[0].attributes['shelve'].value).to eq("no")
    expect(xml.xpath("//resource/file/imageData")[0].attributes['width'].value).to eq("100")
    expect(xml.xpath("//resource/file/imageData")[0].attributes['height'].value).to eq("100")
    expect(xml.xpath("//resource/file")[1].attributes['size'].value).to eq("306")
    expect(xml.xpath("//resource/file")[1].attributes['mimetype'].value).to eq("image/jp2")
    expect(xml.xpath("//resource/file")[1].attributes['publish'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[1].attributes['preserve'].value).to eq("no")
    expect(xml.xpath("//resource/file")[1].attributes['shelve'].value).to eq("yes")
    expect(xml.xpath("//resource/file/imageData")[1].attributes['width'].value).to eq("100")
    expect(xml.xpath("//resource/file/imageData")[1].attributes['height'].value).to eq("100")    
  end

  it "should generate valid content metadata with exif for a single tif and jp2 of style=simple_image overriding file labels for one, and skipping auto labels for the others or for where the label is set but is blank" do
     objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE,:label=>'Sample tif label!'),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE,:label=>'')]
     result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:auto_labels=>false,:add_file_attributes=>true,:objects=>objects)
     expect(result.class).to be String
     xml = Nokogiri::XML(result)
     expect(xml.errors.size).to be 0
     expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
     expect(xml.xpath("//resource").length).to be 3
     expect(xml.xpath("//resource/file").length).to be 3
     expect(xml.xpath("//label").length).to be 1
     expect(xml.xpath("//label")[0].text).to match(/Sample tif label!/)
  end

  it "should generate valid content metadata for a single tif and jp2 of style=simple_image with overriding file attributes and no exif data" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:add_file_attributes=>true,:file_attributes=>{'image/tiff'=>{:publish=>'no',:preserve=>'no',:shelve=>'no'},'image/jp2'=>{:publish=>'yes',:preserve=>'yes',:shelve=>'yes'}},:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource").length).to be 2
    expect(xml.xpath("//resource/file").length).to be 2
    expect(xml.xpath("//label").length).to be 2
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    expect(xml.xpath("//label")[0].text).to match(/Image 1/)
    expect(xml.xpath("//label")[1].text).to match(/Image 2/)
    expect(xml.xpath("//resource")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource")[1].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource/file")[0].attributes['size']).to be nil
    expect(xml.xpath("//resource/file")[0].attributes['mimetype']).to be nil
    expect(xml.xpath("//resource/file")[0].attributes['publish'].value).to eq("no")
    expect(xml.xpath("//resource/file")[0].attributes['preserve'].value).to eq("no")
    expect(xml.xpath("//resource/file")[0].attributes['shelve'].value).to eq("no")    
    expect(xml.xpath("//resource/file")[1].attributes['size']).to be nil
    expect(xml.xpath("//resource/file")[1].attributes['mimetype']).to be nil
    expect(xml.xpath("//resource/file")[1].attributes['publish'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[1].attributes['preserve'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[1].attributes['shelve'].value).to eq("yes") 
  end

  it "should generate valid content metadata for a single tif and jp2 of style=simple_image with overriding file attributes, including a default value, and no exif data" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:add_file_attributes=>true,:file_attributes=>{'default'=>{:publish=>'yes',:preserve=>'no',:shelve=>'no'},'image/jp2'=>{:publish=>'yes',:preserve=>'yes',:shelve=>'yes'}},:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")    
    expect(xml.xpath("//resource/file").length).to be 2
    expect(xml.xpath("//resource/file")[0].attributes['mimetype']).to be nil
    expect(xml.xpath("//resource/file")[0].attributes['publish'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[0].attributes['preserve'].value).to eq("no")
    expect(xml.xpath("//resource/file")[0].attributes['shelve'].value).to eq("no")    
    expect(xml.xpath("//resource/file")[1].attributes['mimetype']).to be nil
    expect(xml.xpath("//resource/file")[1].attributes['publish'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[1].attributes['preserve'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[1].attributes['shelve'].value).to eq("yes") 
    for i in 0..1 do
      expect(xml.xpath("//resource[@sequence='#{i+1}']/file").length).to be 1
      expect(xml.xpath("//label")[i].text).to eq("Image #{i+1}")
      expect(xml.xpath("//resource")[i].attributes['type'].value).to eq("image")
    end    
  end

  it "should generate valid content metadata for a single tif and jp2 of style=map with overriding file attributes, including a default value, and no exif data" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE)]    
    result = Assembly::ContentMetadata.create_content_metadata(:style=>:map,:druid=>TEST_DRUID,:add_file_attributes=>true,:file_attributes=>{'default'=>{:publish=>'yes',:preserve=>'no',:shelve=>'no'},'image/jp2'=>{:publish=>'yes',:preserve=>'yes',:shelve=>'yes'}},:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("map")
    expect(xml.xpath("//resource/file").length).to be 2
    expect(xml.xpath("//resource/file")[0].attributes['mimetype']).to be nil
    expect(xml.xpath("//resource/file")[0].attributes['publish'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[0].attributes['preserve'].value).to eq("no")
    expect(xml.xpath("//resource/file")[0].attributes['shelve'].value).to eq("no")    
    expect(xml.xpath("//resource/file")[1].attributes['mimetype']).to be nil
    expect(xml.xpath("//resource/file")[1].attributes['publish'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[1].attributes['preserve'].value).to eq("yes")
    expect(xml.xpath("//resource/file")[1].attributes['shelve'].value).to eq("yes") 
    for i in 0..1 do
      expect(xml.xpath("//resource[@sequence='#{i+1}']/file").length).to be 1
      expect(xml.xpath("//label")[i].text).to eq("Image #{i+1}")
      expect(xml.xpath("//resource")[i].attributes['type'].value).to eq("image")
    end
  end

  it "should generate valid content metadata for two tifs two associated jp2s of style=simple_image using bundle=filename and no exif data" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:filename,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource").length).to be 2
    expect(xml.xpath("//resource/file").length).to be 4
    expect(xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value).to eq('test.tif')
    expect(xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value).to eq('test.jp2')
    expect(xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value).to eq('test2.tif')
    expect(xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value).to eq('test2.jp2')
    expect(xml.xpath("//label").length).to be 2
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    for i in 0..1 do
      expect(xml.xpath("//resource[@sequence='#{i+1}']/file").length).to be 2
      expect(xml.xpath("//label")[i].text).to eq("Image #{i+1}")
      expect(xml.xpath("//resource")[i].attributes['type'].value).to eq("image")
    end
  end

  it "should generate valid content metadata for two tifs two associated jp2s of style=simple_image using bundle=dpg and no exif data and no root xml node" do
    objects=[Assembly::ObjectFile.new(TEST_DPG_TIF),Assembly::ObjectFile.new(TEST_DPG_JP),Assembly::ObjectFile.new(TEST_DPG_TIF2),Assembly::ObjectFile.new(TEST_DPG_JP2)]    
    test_druid="#{TEST_DRUID}"
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>test_druid,:bundle=>:dpg,:objects=>objects,:include_root_xml=>false)
    expect(result.class).to be String
    expect(result.include?('<?xml')).to be false   
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
    expect(test_druid).to eq(TEST_DRUID)
    expect(xml.xpath("//contentMetadata")[0].attributes['objectId'].value).to eq("#{TEST_DRUID}")    
    expect(xml.xpath("//resource").length).to be 2
    expect(xml.xpath("//resource/file").length).to be 4
    expect(xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value).to eq("00/oo000oo0001_00_001.tif")
    expect(xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value).to eq("05/oo000oo0001_05_001.jp2")
    expect(xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value).to eq("00/oo000oo0001_00_002.tif")
    expect(xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value).to eq("05/oo000oo0001_05_002.jp2")
    expect(xml.xpath("//label").length).to be 2
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    for i in 0..1 do
      expect(xml.xpath("//resource[@sequence='#{i+1}']/file").length).to be 2
      expect(xml.xpath("//label")[i].text).to eq("Image #{i+1}")
      expect(xml.xpath("//resource")[i].attributes['type'].value).to eq("image")
    end
  end

  it "should generate valid content metadata for two tifs, two associated jp2s, one combined pdf and one special tif of style=simple_book using bundle=dpg and no exif data and no root xml node, flattening folder structure" do
    objects=[Assembly::ObjectFile.new(TEST_DPG_SPECIAL_PDF2),Assembly::ObjectFile.new(TEST_DPG_SPECIAL_TIF),Assembly::ObjectFile.new(TEST_DPG_TIF),Assembly::ObjectFile.new(TEST_DPG_JP),Assembly::ObjectFile.new(TEST_DPG_TIF2),Assembly::ObjectFile.new(TEST_DPG_JP2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:simple_book,:bundle=>:dpg,:objects=>objects,:include_root_xml=>false,:flatten_folder_structure=>true)
    expect(result.class).to be String
    expect(result.include?('<?xml')).to be false 
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("book")
    expect(xml.xpath("//contentMetadata")[0].attributes['objectId'].value).to eq("#{TEST_DRUID}")    
    expect(xml.xpath("//resource").length).to be 4
    expect(xml.xpath("//resource/file").length).to be 6
    expect(xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value).to eq("oo000oo0001_00_001.tif")
    expect(xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value).to eq("oo000oo0001_05_001.jp2")
    expect(xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value).to eq("oo000oo0001_00_002.tif")
    expect(xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value).to eq("oo000oo0001_05_002.jp2")
    expect(xml.xpath("//resource[@sequence='3']/file")[0].attributes['id'].value).to eq("oo000oo0001_31_001.pdf")
    expect(xml.xpath("//resource[@sequence='4']/file")[0].attributes['id'].value).to eq("oo000oo0001_50_001.tif")
    expect(xml.xpath("//label").length).to be 4
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    for i in 0..1 do
      expect(xml.xpath("//resource[@sequence='#{i+1}']/file").length).to be 2
      expect(xml.xpath("//label")[i].text).to eq("Page #{i+1}")
      expect(xml.xpath("//resource")[i].attributes['type'].value).to eq("page")
    end
    expect(xml.xpath("//resource[@sequence='3']/file").length).to be 1
    expect(xml.xpath("//label")[2].text).to eq("Object 1")
    expect(xml.xpath("//resource")[2].attributes['type'].value).to eq("object")
    expect(xml.xpath("//resource[@sequence='4']/file").length).to be 1
    expect(xml.xpath("//label")[3].text).to eq("Object 2")
    expect(xml.xpath("//resource")[3].attributes['type'].value).to eq("object")
  end
  
  it "should generate valid content metadata with item having a 'druid:' prefix for two tifs,two associated jp2s,two associated pdfs, and one lingering PDF of style=simple_book using bundle=dpg, flattening folder structure" do
    objects=[Assembly::ObjectFile.new(TEST_DPG_TIF),Assembly::ObjectFile.new(TEST_DPG_JP),Assembly::ObjectFile.new(TEST_DPG_PDF),Assembly::ObjectFile.new(TEST_DPG_TIF2),Assembly::ObjectFile.new(TEST_DPG_JP2),Assembly::ObjectFile.new(TEST_DPG_PDF2),Assembly::ObjectFile.new(TEST_DPG_SPECIAL_PDF1)]    
    test_druid="druid:#{TEST_DRUID}"
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>test_druid,:bundle=>:dpg,:objects=>objects,:style=>:simple_book,:flatten_folder_structure=>true)
    expect(result.class).to be String
    expect(result.include?('<?xml')).to be true
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("book")
    expect(xml.xpath("//contentMetadata")[0].attributes['objectId'].value).to eq(test_druid)
    expect(test_druid).to eq("druid:#{TEST_DRUID}")
    expect(xml.xpath("//resource").length).to be 3
    expect(xml.xpath("//resource/file").length).to be 7                                  
    
    expect(xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value).to eq("oo000oo0001_00_001.tif")
    expect(xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value).to eq("oo000oo0001_05_001.jp2")
    expect(xml.xpath("//resource[@sequence='1']/file")[2].attributes['id'].value).to eq("oo000oo0001_15_001.pdf")
    expect(xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value).to eq("oo000oo0001_00_002.tif")
    expect(xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value).to eq("oo000oo0001_05_002.jp2")
    expect(xml.xpath("//resource[@sequence='2']/file")[2].attributes['id'].value).to eq("oo000oo0001_15_002.pdf")
    expect(xml.xpath("//resource[@sequence='3']/file")[0].attributes['id'].value).to eq("oo000oo0001_book.pdf")
    expect(xml.xpath("//label").length).to be 3
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    for i in 0..1 do
      expect(xml.xpath("//resource[@sequence='#{i+1}']/file").length).to be 3
      expect(xml.xpath("//label")[i].text).to eq("Page #{i+1}")
      expect(xml.xpath("//resource")[i].attributes['type'].value).to eq("page")
    end
    expect(xml.xpath("//resource[@sequence='3']/file").length).to be 1
    expect(xml.xpath("//label")[2].text).to eq("Object 1")
    expect(xml.xpath("//resource")[2].attributes['type'].value).to eq("object")
  end

  it "should generate valid content metadata for two tifs,two associated jp2s,two associated pdfs, and one lingering PDF of style=book_with_pdf using bundle=dpg" do
    objects=[Assembly::ObjectFile.new(TEST_DPG_TIF),Assembly::ObjectFile.new(TEST_DPG_JP),Assembly::ObjectFile.new(TEST_DPG_PDF),Assembly::ObjectFile.new(TEST_DPG_TIF2),Assembly::ObjectFile.new(TEST_DPG_JP2),Assembly::ObjectFile.new(TEST_DPG_SPECIAL_PDF1)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:dpg,:objects=>objects,:style=>:book_with_pdf)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("book")
    expect(xml.xpath("//resource").length).to be 3
    expect(xml.xpath("//resource/file").length).to be 6
    expect(xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value).to eq("00/oo000oo0001_00_001.tif")
    expect(xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value).to eq("05/oo000oo0001_05_001.jp2") 
    expect(xml.xpath("//resource[@sequence='1']/file")[2].attributes['id'].value).to eq("15/oo000oo0001_15_001.pdf") 
    expect(xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value).to eq("00/oo000oo0001_00_002.tif")
    expect(xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value).to eq("05/oo000oo0001_05_002.jp2") 
    expect(xml.xpath("//resource[@sequence='3']/file")[0].attributes['id'].value).to eq("oo000oo0001_book.pdf")
    expect(xml.xpath("//label").length).to be 3
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    expect(xml.xpath("//resource[@sequence='1']/file").length).to be 3
    expect(xml.xpath("//label")[0].text).to eq("Object 1")
    expect(xml.xpath("//resource")[0].attributes['type'].value).to eq("object")
    expect(xml.xpath("//resource[@sequence='2']/file").length).to be 2
    expect(xml.xpath("//label")[1].text).to eq("Page 1")
    expect(xml.xpath("//resource")[1].attributes['type'].value).to eq("page")
    expect(xml.xpath("//resource[@sequence='3']/file").length).to be 1
    expect(xml.xpath("//label")[2].text).to eq("Object 2")
    expect(xml.xpath("//resource")[2].attributes['type'].value).to eq("object")
  end
    
  it "should generate valid content metadata for two tifs two associated jp2s of style=simple_image using bundle=default and no exif data" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:default,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource").length).to be 4
    expect(xml.xpath("//resource/file").length).to be 4  
    expect(xml.xpath("//resource/file")[0].attributes['id'].value).to eq('test.tif')     
    expect(xml.xpath("//resource/file")[1].attributes['id'].value).to eq('test.jp2')
    expect(xml.xpath("//resource/file")[2].attributes['id'].value).to eq('test2.tif')
    expect(xml.xpath("//resource/file")[3].attributes['id'].value).to eq('test2.jp2')    
    expect(xml.xpath("//label").length).to be 4
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    for i in 0..3 do
      expect(xml.xpath("//resource[@sequence='#{i+1}']/file").length).to be 1
      expect(xml.xpath("//label")[i].text).to eq("Image #{i+1}")
      expect(xml.xpath("//resource")[i].attributes['type'].value).to eq("image")
    end
  end

  it "should generate valid content metadata for two tifs two associated jp2s of style=simple_image using bundle=default and no exif data, preserving full paths" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:default,:objects=>objects,:preserve_common_paths=>true)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource").length).to be 4
    expect(xml.xpath("//resource/file").length).to be 4
    expect(xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value).to eq(TEST_TIF_INPUT_FILE)
    expect(xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value).to eq(TEST_JP2_INPUT_FILE)
    expect(xml.xpath("//resource[@sequence='3']/file")[0].attributes['id'].value).to eq(TEST_TIF_INPUT_FILE2)
    expect(xml.xpath("//resource[@sequence='4']/file")[0].attributes['id'].value).to eq(TEST_JP2_INPUT_FILE2)   
    expect(xml.xpath("//label").length).to be 4
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    for i in 0..3 do
      expect(xml.xpath("//resource[@sequence='#{i+1}']/file").length).to be 1
      expect(xml.xpath("//label")[i].text).to eq("Image #{i+1}")
      expect(xml.xpath("//resource")[i].attributes['type'].value).to eq("image")
    end
  end
  
  it "should generate valid content metadata for two tifs two associated jp2s of style=file using specific content metadata paths" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_JP2_INPUT_FILE2)]    
    objects[0].relative_path='input/test.tif'
    objects[1].relative_path='input/test.jp2'
    objects[2].relative_path='input/test2.tif'
    objects[3].relative_path='input/test2.jp2'
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:file,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("file")
    expect(xml.xpath("//resource").length).to be 4
    expect(xml.xpath("//resource/file").length).to be 4
    expect(xml.xpath("//label").length).to be 4
    expect(xml.xpath("//resource/file")[0].attributes['id'].value).to eq('input/test.tif')
    expect(xml.xpath("//resource/file")[1].attributes['id'].value).to eq('input/test.jp2')
    expect(xml.xpath("//resource/file")[2].attributes['id'].value).to eq('input/test2.tif')
    expect(xml.xpath("//resource/file")[3].attributes['id'].value).to eq('input/test2.jp2')
    for i in 0..3 do
      expect(xml.xpath("//resource[@sequence='#{i+1}']/file").length).to be 1
      expect(xml.xpath("//label")[i].text).to eq("File #{i+1}")
      expect(xml.xpath("//resource")[i].attributes['type'].value).to eq("file")
    end
  end
    
  it "should generate valid content metadata for two tifs of style=simple_book" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2)]        
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:simple_book,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("book")
    expect(xml.xpath("//resource").length).to be 2
    expect(xml.xpath("//resource/file").length).to be 2
    expect(xml.xpath("//label").length).to be 2
    expect(xml.xpath("//label")[0].text).to match(/Page 1/)
    expect(xml.xpath("//label")[1].text).to match(/Page 2/)
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    for i in 0..1 do
      expect(xml.xpath("//resource/file")[i].attributes['size']).to be nil
      expect(xml.xpath("//resource/file")[i].attributes['mimetype']).to be nil
      expect(xml.xpath("//resource/file")[i].attributes['publish']).to be nil
      expect(xml.xpath("//resource/file")[i].attributes['preserve']).to be nil
      expect(xml.xpath("//resource/file")[i].attributes['shelve']).to be nil  
    end
    expect(xml.xpath("//resource")[0].attributes['type'].value).to eq("page")
    expect(xml.xpath("//resource")[1].attributes['type'].value).to eq("page")
  end

  it "should generate valid content metadata for two tifs and one pdf of style=book_with_pdf" do
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2),Assembly::ObjectFile.new(TEST_PDF_FILE)]        
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:book_with_pdf,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("book")
    expect(xml.xpath("//resource").length).to be 3
    expect(xml.xpath("//resource/file").length).to be 3
    expect(xml.xpath("//label").length).to be 3
    expect(xml.xpath("//label")[0].text).to match(/Page 1/)
    expect(xml.xpath("//label")[1].text).to match(/Page 2/)
    expect(xml.xpath("//label")[2].text).to match(/Object 1/)
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    expect(xml.xpath("//resource")[0].attributes['type'].value).to eq("page")
    expect(xml.xpath("//resource")[1].attributes['type'].value).to eq("page")
    expect(xml.xpath("//resource")[2].attributes['type'].value).to eq("object")
  end
  
   it "should generate valid content metadata for two tifs of style=book_as_image" do
     objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2)]             
     result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:book_as_image,:objects=>objects)
     expect(result.class).to be String
     xml = Nokogiri::XML(result)
     expect(xml.errors.size).to be 0
     expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("book")
     expect(xml.xpath("//resource").length).to be 2
     expect(xml.xpath("//resource/file").length).to be 2
     expect(xml.xpath("//label").length).to be 2
     expect(xml.xpath("//label")[0].text).to match(/Image 1/)
     expect(xml.xpath("//label")[1].text).to match(/Image 2/)
     expect(xml.xpath("//resource/file/imageData").length).to be 0
     for i in 0..1 do
       expect(xml.xpath("//resource/file")[i].attributes['size']).to be nil
       expect(xml.xpath("//resource/file")[i].attributes['mimetype']).to be nil
       expect(xml.xpath("//resource/file")[i].attributes['publish']).to be nil
       expect(xml.xpath("//resource/file")[i].attributes['preserve']).to be nil
       expect(xml.xpath("//resource/file")[i].attributes['shelve']).to be nil  
     end    
     expect(xml.xpath("//resource")[0].attributes['type'].value).to eq("image")
     expect(xml.xpath("//resource")[1].attributes['type'].value).to eq("image")
   end

   it "should generate valid content metadata with no exif but with user supplied checksums for two tifs of style=simple_book" do
     obj1=Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
     obj1.provider_md5='123456789'
     obj1.provider_sha1='abcdefgh'
     obj2=Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE2)
     obj2.provider_md5='qwerty'
     objects=[obj1,obj2]        
     result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:style=>:simple_book,:objects=>objects)
     expect(result.class).to be String
     xml = Nokogiri::XML(result)
     expect(xml.errors.size).to be 0
     expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("book")
     expect(xml.xpath("//resource").length).to be 2
     expect(xml.xpath("//resource/file").length).to be 2
     expect(xml.xpath("//resource/file/checksum").length).to be 3
     expect(xml.xpath("//label").length).to be 2
     expect(xml.xpath("//label")[0].text).to match(/Page 1/)
     expect(xml.xpath("//label")[1].text).to match(/Page 2/)
     expect(xml.xpath("//resource/file/imageData").length).to be 0
     expect(xml.xpath("//resource/file/checksum")[0].text).to eq("abcdefgh")
     expect(xml.xpath("//resource/file/checksum")[1].text).to eq("123456789")
     expect(xml.xpath("//resource/file/checksum")[2].text).to eq("qwerty")     
     for i in 0..1 do
       expect(xml.xpath("//resource/file")[i].attributes['size']).to be nil
       expect(xml.xpath("//resource/file")[i].attributes['mimetype']).to be nil
       expect(xml.xpath("//resource/file")[i].attributes['publish']).to be nil
       expect(xml.xpath("//resource/file")[i].attributes['preserve']).to be nil
       expect(xml.xpath("//resource/file")[i].attributes['shelve']).to be nil  
     end
     expect(xml.xpath("//resource")[0].attributes['type'].value).to eq("page")
     expect(xml.xpath("//resource")[1].attributes['type'].value).to eq("page")
   end
   
  it "should not generate valid content metadata if not all input files exist" do
    expect(File.exists?(TEST_TIF_INPUT_FILE)).to be true
    junk_file='/tmp/flim_flam_floom.jp2'
    expect(File.exists?(junk_file)).to be false
    objects=[Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE),Assembly::ObjectFile.new(junk_file)]  
    expect {Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:objects=>objects)}.to raise_error(RuntimeError,"File '#{junk_file}' not found")
  end

  it "should generate valid content metadata for images and associated text files, of style=simple_image using bundle=prebundled, and no exif data" do
    files=[[TEST_RES1_TIF1,TEST_RES1_JP1,TEST_RES1_TIF2,TEST_RES1_JP2,TEST_RES1_TEI,TEST_RES1_TEXT,TEST_RES1_PDF],[TEST_RES2_TIF1,TEST_RES2_JP1,TEST_RES2_TIF2,TEST_RES2_JP2,TEST_RES2_TEI,TEST_RES2_TEXT],[TEST_RES3_TIF1,TEST_RES3_JP1,TEST_RES3_TEI]]
    objects=files.collect {|resource| resource.collect {|file| Assembly::ObjectFile.new(file)} }
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:prebundled,:style=>:simple_image,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource").length).to be 3
    expect(xml.xpath("//resource/file").length).to be 16
    expect(xml.xpath("//resource[@sequence='1']/file")[0].attributes['id'].value).to eq('res1_image1.tif')
    expect(xml.xpath("//resource[@sequence='1']/file")[1].attributes['id'].value).to eq('res1_image1.jp2')
    expect(xml.xpath("//resource[@sequence='1']/file")[2].attributes['id'].value).to eq('res1_image2.tif')
    expect(xml.xpath("//resource[@sequence='1']/file")[3].attributes['id'].value).to eq('res1_image2.jp2')
    expect(xml.xpath("//resource[@sequence='1']/file")[4].attributes['id'].value).to eq('res1_teifile.txt')
    expect(xml.xpath("//resource[@sequence='1']/file")[5].attributes['id'].value).to eq('res1_textfile.txt')
    expect(xml.xpath("//resource[@sequence='1']/file")[6].attributes['id'].value).to eq('res1_transcript.pdf')
    expect(xml.xpath("//resource[@sequence='1']/file").length).to be 7
                                                                                     
    expect(xml.xpath("//resource[@sequence='2']/file")[0].attributes['id'].value).to eq('res2_image1.tif')
    expect(xml.xpath("//resource[@sequence='2']/file")[1].attributes['id'].value).to eq('res2_image1.jp2')
    expect(xml.xpath("//resource[@sequence='2']/file")[2].attributes['id'].value).to eq('res2_image2.tif')
    expect(xml.xpath("//resource[@sequence='2']/file")[3].attributes['id'].value).to eq('res2_image2.jp2')
    expect(xml.xpath("//resource[@sequence='2']/file")[4].attributes['id'].value).to eq('res2_teifile.txt')
    expect(xml.xpath("//resource[@sequence='2']/file")[5].attributes['id'].value).to eq('res2_textfile.txt')
    expect(xml.xpath("//resource[@sequence='2']/file").length).to be 6

    expect(xml.xpath("//resource[@sequence='3']/file")[0].attributes['id'].value).to eq('res3_image1.tif')
    expect(xml.xpath("//resource[@sequence='3']/file")[1].attributes['id'].value).to eq('res3_image1.jp2')
    expect(xml.xpath("//resource[@sequence='3']/file")[2].attributes['id'].value).to eq('res3_teifile.txt')
    expect(xml.xpath("//resource[@sequence='3']/file").length).to be 3

    expect(xml.xpath("//label").length).to be 3
    expect(xml.xpath("//resource/file/imageData").length).to be 0
    for i in 0..2 do
      expect(xml.xpath("//label")[i].text).to eq("Image #{i+1}")
      expect(xml.xpath("//resource")[i].attributes['type'].value).to eq("image")
    end
  end

  it "should generate role attributes for content metadata for a tif" do
    obj1=Assembly::ObjectFile.new(TEST_TIF_INPUT_FILE)
    obj1.file_attributes={:publish=>'no',:preserve=>'no',:shelve=>'no',:role=>'master-role'}
    objects=[obj1]
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:add_exif=>false,:add_file_attributes=>true,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("image")
    expect(xml.xpath("//resource").length).to be 1
    expect(xml.xpath("//resource/file").length).to be 1
    expect(xml.xpath("//resource/file").length).to be 1
    expect(xml.xpath("//resource/file")[0].attributes['role'].value).to eq("master-role")
  end



  it "should generate content metadata even when no objects are passed in" do
    objects=[]
    result = Assembly::ContentMetadata.create_content_metadata(:druid=>TEST_DRUID,:bundle=>:prebundled,:style=>:file,:objects=>objects)
    expect(result.class).to be String
    xml = Nokogiri::XML(result)
    expect(xml.errors.size).to be 0
    expect(xml.xpath("//contentMetadata")[0].attributes['type'].value).to eq("file")
    expect(xml.xpath("//resource").length).to be 0
    expect(xml.xpath("//resource/file").length).to be 0
  end

end

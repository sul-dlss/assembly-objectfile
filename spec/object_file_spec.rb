# frozen_string_literal: true

require 'spec_helper'

describe Assembly::ObjectFile do
  it 'does not run if no input file is passed in' do
    object_file = described_class.new('')
    expect { object_file.filesize }.to raise_error(RuntimeError, 'input file  does not exist or is a directory')
    expect { object_file.sha1 }.to raise_error(RuntimeError, 'input file  does not exist or is a directory')
    expect { object_file.md5 }.to raise_error(RuntimeError, 'input file  does not exist or is a directory')
  end

  it 'returns the common directory of a set of filenames passed into it, where the common part does not terminate on a directory' do
    expect(described_class.common_path(['/Users/peter/00/test.tif', '/Users/peter/05/test.jp2'])).to eq('/Users/peter/')
  end

  it 'returns the common directory of a set of filenames passed into it, where the common part does not terminate on a directory' do
    expect(described_class.common_path(['/Users/peter/00/test.tif', '/Users/peter/00/test.jp2'])).to eq('/Users/peter/00/')
  end

  it 'tells us if an input file is an image' do
    expect(File.exist?(TEST_TIF_INPUT_FILE)).to be true
    object_file = described_class.new(TEST_TIF_INPUT_FILE)
    expect(object_file.image?).to be(true)
    expect(object_file.exif).not_to be_nil
    expect(object_file.mimetype).to eq('image/tiff')
    expect(object_file.file_mimetype).to eq('image/tiff')
    expect(object_file.extension_mimetype).to eq('image/tiff')
    expect(object_file.exif_mimetype).to eq('image/tiff')
    expect(object_file.object_type).to eq(:image)
    expect(object_file.valid_image?).to be(true)
    expect(object_file.jp2able?).to be(true)
  end

  it 'tells us information about the input file' do
    object_file = described_class.new(TEST_TIF_INPUT_FILE)
    expect(object_file.filename).to eq('test.tif')
    expect(object_file.ext).to eq('.tif')
    expect(object_file.filename_without_ext).to eq('test')
    expect(object_file.dirname).to eq(File.dirname(TEST_TIF_INPUT_FILE))
  end

  it 'sets the correct mimetype of plain/text for .txt files' do
    object_file = described_class.new(TEST_RES1_TEXT)
    expect(object_file.mimetype).to eq('text/plain')
  end

  it 'sets the correct mimetype of plain/text for .xml files' do
    object_file = described_class.new(TEST_RES1_TEXT)
    expect(object_file.mimetype).to eq('text/plain')
  end

  it 'sets the correct mimetype of plain/text for .obj 3d files' do
    object_file = described_class.new(TEST_OBJ_FILE)
    expect(object_file.mimetype).to eq('text/plain')
  end

  it 'sets a mimetype of application/x-tgif for .obj 3d files if we prefer the mimetype extension gem over unix file system command' do
    object_file = described_class.new(TEST_OBJ_FILE, mime_type_order: %i[extension file exif])
    expect(object_file.mimetype).to eq('application/x-tgif')
  end

  it 'ignores invald mimetype generation methods and still sets a mimetype of application/x-tgif for .obj 3d files if we prefer the mimetype extension gem over unix file system command' do
    object_file = described_class.new(TEST_OBJ_FILE, mime_type_order: %i[bogus extension file])
    expect(object_file.mimetype).to eq('application/x-tgif')
  end

  it 'sets the correct mimetype of plain/text for .ply 3d files' do
    object_file = described_class.new(TEST_PLY_FILE)
    expect(object_file.mimetype).to eq('text/plain')
  end

  it 'overrides the mimetype generators and uses the manual mapping to set the correct mimetype of application/json for a .json file' do
    object_file = described_class.new(TEST_JSON_FILE)
    expect(object_file.exif_mimetype).to be_nil # exif returns nil
    expect(object_file.file_mimetype).to eq('text/plain') # unix file system command returns plain text
    expect(object_file.mimetype).to eq('application/json') # but our configured mapping overrides both and returns application/json
  end

  it 'sets the correct mimetype of image/tiff for .tif files' do
    object_file = described_class.new(TEST_TIF_INPUT_FILE)
    expect(object_file.mimetype).to eq('image/tiff')
  end

  it 'sets the correct mimetype of image/jp2 for .jp2 files' do
    object_file = described_class.new(TEST_JP2_INPUT_FILE)
    expect(object_file.mimetype).to eq('image/jp2')
  end

  it 'sets the correct mimetype of application/pdf for .pdf files' do
    object_file = described_class.new(TEST_RES1_PDF)
    expect(object_file.mimetype).to eq('application/pdf')
  end

  it 'gives us the mimetype of a file even if the exif information is damaged' do
    object_file = described_class.new(TEST_FILE_NO_EXIF)
    expect(object_file.filename).to eq('file_with_no_exif.xml')
    expect(object_file.ext).to eq('.xml')
    expect(['text/html', 'application/xml'].include?(object_file.mimetype)).to be true # we could get either of these mimetypes depending on the OS
  end

  it 'gives us the DPG base name for a file' do
    test_file = File.join(TEST_INPUT_DIR, 'oo000oo0001_00_001.tif')
    object_file = described_class.new(test_file)
    expect(object_file.dpg_basename).to eq('oo000oo0001_001')
  end

  it 'gives us the DPG subfolder name for a file' do
    test_file = File.join(TEST_INPUT_DIR, 'oo000oo0001_05_001.tif')
    object_file = described_class.new(test_file)
    expect(object_file.dpg_folder).to eq('05')
  end

  it 'tells us that a jp2 file is not jp2able but does have a color profile' do
    expect(File.exist?(TEST_JP2_INPUT_FILE)).to be true
    object_file = described_class.new(TEST_JP2_INPUT_FILE)
    expect(object_file.image?).to be(true)
    expect(object_file.object_type).to eq(:image)
    expect(object_file.valid_image?).to be(true)
    expect(object_file.jp2able?).to be(false)
    expect(object_file.has_color_profile?).to be(true)
  end

  it 'tells us that a tiff file is jp2able and has a color profile' do
    expect(File.exist?(TEST_RES1_TIF1)).to be true
    object_file = described_class.new(TEST_RES1_TIF1)
    expect(object_file.image?).to be(true)
    expect(object_file.object_type).to eq(:image)
    expect(object_file.valid_image?).to be(true)
    expect(object_file.jp2able?).to be(true)
    expect(object_file.has_color_profile?).to be(true)
  end

  it 'tells us that a tiff file is not jp2able and is not valid since it has no profile' do
    expect(File.exist?(TEST_TIFF_NO_COLOR_FILE)).to be true
    object_file = described_class.new(TEST_TIFF_NO_COLOR_FILE)
    expect(object_file.image?).to be(true)
    expect(object_file.object_type).to eq(:image)
    expect(object_file.valid_image?).to be(true)
    expect(object_file.jp2able?).to be(true)
    expect(object_file.has_color_profile?).to be(false)
  end

  it 'computes checksums for an image file' do
    expect(File.exist?(TEST_TIF_INPUT_FILE)).to be true
    object_file = described_class.new(TEST_TIF_INPUT_FILE)
    expect(object_file.md5).to eq('a2400500acf21e43f5440d93be894101')
    expect(object_file.sha1).to eq('8d11fab63089a24c8b17063d29a4b0eac359fb41')
  end

  it 'indicates that the file is not found when a valid directory is supplied instead of a file or when an invalid file path is specified' do
    path = Assembly::PATH_TO_GEM
    object_file = described_class.new(path)
    expect(File.exist?(path)).to be true
    expect(File.directory?(path)).to be true
    expect(object_file.file_exists?).to be false

    path = File.join(Assembly::PATH_TO_GEM, 'bogus.txt')
    object_file = described_class.new(path)
    expect(File.exist?(path)).to be false
    expect(File.directory?(path)).to be false
    expect(object_file.file_exists?).to be false
  end

  it 'sets attributes correctly when initializing' do
    object_file = described_class.new('/some/file.txt')
    expect(object_file.path).to eq('/some/file.txt')
    expect(object_file.label).to be_nil
    expect(object_file.file_attributes).to be_nil
    expect(object_file.provider_sha1).to be_nil
    expect(object_file.provider_md5).to be_nil
    expect(object_file.relative_path).to be_nil

    object_file = described_class.new('/some/file.txt', label: 'some label', file_attributes: { 'shelve' => 'yes', 'publish' => 'yes', 'preserve' => 'no' }, relative_path: '/tmp')
    expect(object_file.path).to eq('/some/file.txt')
    expect(object_file.label).to eq('some label')
    expect(object_file.file_attributes).to eq('shelve' => 'yes', 'publish' => 'yes', 'preserve' => 'no')
    expect(object_file.provider_sha1).to be_nil
    expect(object_file.provider_md5).to be_nil
    expect(object_file.relative_path).to eq('/tmp')
  end

  it 'sets md5_provider attribute' do
    object_file = described_class.new('/some/file.txt', provider_md5: 'XYZ')
    expect(object_file.provider_md5).to eq('XYZ')
  end

  it 'tells us if an input file is not an image' do
    non_image_file = File.join(Assembly::PATH_TO_GEM, 'spec/object_file_spec.rb')
    expect(File.exist?(non_image_file)).to be true
    object_file = described_class.new(non_image_file)
    expect(object_file.image?).to be(false)
    expect(object_file.object_type).not_to eq(:image)
    expect(object_file.valid_image?).to be(false)

    non_image_file = File.join(Assembly::PATH_TO_GEM, 'spec/test_data/input/file_with_no_exif.xml')
    expect(File.exist?(non_image_file)).to be true
    object_file = described_class.new(non_image_file)
    expect(object_file.image?).to be(false)
    expect(object_file.object_type).not_to eq(:image)
    expect(object_file.valid_image?).to be(false)
  end

  it 'tells us the size of an input file' do
    expect(File.exist?(TEST_TIF_INPUT_FILE)).to be true
    object_file = described_class.new(TEST_TIF_INPUT_FILE)
    expect(object_file.filesize).to eq(63_542)
  end

  it 'tells us the mimetype and encoding of an input file' do
    expect(File.exist?(TEST_TIF_INPUT_FILE)).to be true
    @ai = described_class.new(TEST_TIF_INPUT_FILE)
    expect(@ai.mimetype).to eq('image/tiff')
    expect(@ai.file_mimetype).to eq('image/tiff')
    expect(@ai.encoding).to eq('binary')
  end

  it 'raises MiniExiftool::Error if exiftool raises one' do
    object_file = described_class.new('spec/test_data/empty.txt')
    expect { object_file.exif }.to raise_error(MiniExiftool::Error)
  end
end

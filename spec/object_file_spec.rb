require 'spec_helper'

describe Assembly::ObjectFile do
  it 'does not run if no input file is passed in' do
    @ai = described_class.new('')
    expect { @ai.filesize }.to raise_error(RuntimeError, 'input file  does not exist')
    expect { @ai.sha1 }.to raise_error(RuntimeError, 'input file  does not exist')
    expect { @ai.md5 }.to raise_error(RuntimeError, 'input file  does not exist')
  end

  it 'returns the common directory of a set of filenames passed into it, where the common part does not terminate on a directory' do
    expect(described_class.common_path(['/Users/peter/00/test.tif', '/Users/peter/05/test.jp2'])).to eq('/Users/peter/')
  end

  it 'returns the common directory of a set of filenames passed into it, where the common part does not terminate on a directory' do
    expect(described_class.common_path(['/Users/peter/00/test.tif', '/Users/peter/00/test.jp2'])).to eq('/Users/peter/00/')
  end

  it 'tells us if an input file is an image' do
    expect(File.exist?(TEST_TIF_INPUT_FILE)).to be true
    @ai = described_class.new(TEST_TIF_INPUT_FILE)
    expect(@ai.image?).to eq(true)
    expect(@ai.exif).not_to be nil
    expect(@ai.mimetype).to eq('image/tiff')
    expect(@ai.file_mimetype).to eq('image/tiff')
    expect(@ai.object_type).to eq(:image)
    expect(@ai.valid_image?).to eq(true)
    expect(@ai.jp2able?).to eq(true)
  end

  it 'tells us information about the input file' do
    @ai = described_class.new(TEST_TIF_INPUT_FILE)
    expect(@ai.filename).to eq('test.tif')
    expect(@ai.ext).to eq('.tif')
    expect(@ai.filename_without_ext).to eq('test')
    expect(@ai.dirname).to eq(File.dirname(TEST_TIF_INPUT_FILE))
  end

  it 'gives us the mimetype of a file even if the exif information is damaged' do
    @ai = described_class.new(TEST_FILE_NO_EXIF)
    expect(@ai.filename).to eq('file_with_no_exif.xml')
    expect(@ai.ext).to eq('.xml')
    expect(['text/html', 'application/xml'].include?(@ai.mimetype)).to be true # we could get either of these mimetypes depending on the OS
  end

  it 'gives us the DPG base name for a file' do
    test_file = File.join(TEST_INPUT_DIR, 'oo000oo0001_00_001.tif')
    @ai = described_class.new(test_file)
    expect(@ai.dpg_basename).to eq('oo000oo0001_001')
  end

  it 'gives us the DPG subfolder name for a file' do
    test_file = File.join(TEST_INPUT_DIR, 'oo000oo0001_05_001.tif')
    @ai = described_class.new(test_file)
    expect(@ai.dpg_folder).to eq('05')
  end

  it 'tells us that a jp2 file is not jp2able but does have a color profile' do
    expect(File.exist?(TEST_JP2_INPUT_FILE)).to be true
    @ai = described_class.new(TEST_JP2_INPUT_FILE)
    expect(@ai.image?).to eq(true)
    expect(@ai.object_type).to eq(:image)
    expect(@ai.valid_image?).to eq(true)
    expect(@ai.jp2able?).to eq(false)
    expect(@ai.has_color_profile?).to eq(true)
  end

  it 'tells us that a tiff file is jp2able and has a color profile' do
    expect(File.exist?(TEST_RES1_TIF1)).to be true
    @ai = described_class.new(TEST_RES1_TIF1)
    expect(@ai.image?).to eq(true)
    expect(@ai.object_type).to eq(:image)
    expect(@ai.valid_image?).to eq(true)
    expect(@ai.jp2able?).to eq(true)
    expect(@ai.has_color_profile?).to eq(true)
  end

  it 'tells us that a tiff file is not jp2able and is not valid since it has no profile' do
    expect(File.exist?(TEST_TIFF_NO_COLOR_FILE)).to be true
    @ai = described_class.new(TEST_TIFF_NO_COLOR_FILE)
    expect(@ai.image?).to eq(true)
    expect(@ai.object_type).to eq(:image)
    expect(@ai.valid_image?).to eq(true)
    expect(@ai.jp2able?).to eq(true)
    expect(@ai.has_color_profile?).to eq(false)
  end

  it 'computes checksums for an image file' do
    expect(File.exist?(TEST_TIF_INPUT_FILE)).to be true
    @ai = described_class.new(TEST_TIF_INPUT_FILE)
    expect(@ai.md5).to eq('a2400500acf21e43f5440d93be894101')
    expect(@ai.sha1).to eq('8d11fab63089a24c8b17063d29a4b0eac359fb41')
  end

  it 'indicates that the file is not found when a valid directory is supplied instead of a file or when an invalid file path is specified' do
    path = Assembly::PATH_TO_GEM
    @ai = described_class.new(path)
    expect(File.exist?(path)).to be true
    expect(File.directory?(path)).to be true
    expect(@ai.file_exists?).to be false

    path = File.join(Assembly::PATH_TO_GEM, 'bogus.txt')
    @ai = described_class.new(path)
    expect(File.exist?(path)).to be false
    expect(File.directory?(path)).to be false
    expect(@ai.file_exists?).to be false
  end

  it 'sets attributes correctly when initializing' do
    @ai = described_class.new('/some/file.txt')
    expect(@ai.path).to eq('/some/file.txt')
    expect(@ai.label).to be_nil
    expect(@ai.file_attributes).to be_nil
    expect(@ai.provider_sha1).to be_nil
    expect(@ai.provider_md5).to be_nil
    expect(@ai.relative_path).to be_nil

    @ai = described_class.new('/some/file.txt', label: 'some label', file_attributes: { 'shelve' => 'yes', 'publish' => 'yes', 'preserve' => 'no' }, relative_path: '/tmp')
    expect(@ai.path).to eq('/some/file.txt')
    expect(@ai.label).to eq('some label')
    expect(@ai.file_attributes).to eq('shelve' => 'yes', 'publish' => 'yes', 'preserve' => 'no')
    expect(@ai.provider_sha1).to be_nil
    expect(@ai.provider_md5).to be_nil
    expect(@ai.relative_path).to eq('/tmp')
  end

  it 'tells us if an input file is not an image' do
    non_image_file = File.join(Assembly::PATH_TO_GEM, 'spec/object_file_spec.rb')
    expect(File.exist?(non_image_file)).to be true
    @ai = described_class.new(non_image_file)
    expect(@ai.image?).to eq(false)
    expect(@ai.object_type).not_to eq(:image)
    expect(@ai.valid_image?).to eq(false)

    non_image_file = File.join(Assembly::PATH_TO_GEM, 'README.rdoc')
    expect(File.exist?(non_image_file)).to be true
    @ai = described_class.new(non_image_file)
    expect(@ai.image?).to eq(false)
    expect(@ai.object_type).to eq(:other)
    expect(@ai.valid_image?).to eq(false)
  end

  it 'tells us the size of an input file' do
    expect(File.exist?(TEST_TIF_INPUT_FILE)).to be true
    @ai = described_class.new(TEST_TIF_INPUT_FILE)
    expect(@ai.filesize).to eq(63_542)
  end

  it 'tells us the mimetype and encoding of an input file' do
    expect(File.exist?(TEST_TIF_INPUT_FILE)).to be true
    @ai = described_class.new(TEST_TIF_INPUT_FILE)
    expect(@ai.mimetype).to eq('image/tiff')
    expect(@ai.file_mimetype).to eq('image/tiff')
    expect(@ai.encoding).to eq('binary')
  end
end

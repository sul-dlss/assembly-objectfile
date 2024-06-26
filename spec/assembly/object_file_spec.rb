# frozen_string_literal: true

require 'spec_helper'

describe Assembly::ObjectFile do
  let(:root_path) { File.expand_path("#{File.dirname(__dir__)}/..") }
  let(:fixture_input_dir) { File.join(root_path, 'spec', 'fixtures', 'input') }
  let(:tif_fixture_file) { File.join(fixture_input_dir, 'test.tif') }
  let(:jp2_fixture_file) { File.join(fixture_input_dir, 'test.jp2') }
  let(:tiff_no_color_fixture_file) { File.join(fixture_input_dir, 'test_no_color_profile.tif') }
  let(:resource1_tif_fixture_file) { File.join(fixture_input_dir, 'res1_image1.tif') }
  let(:resource1_text_fixture_file) { File.join(fixture_input_dir, 'res1_textfile.txt') }
  let(:resource1_pdf_fixture_file) { File.join(fixture_input_dir, 'res1_transcript.pdf') }
  let(:no_exif_fixture_file) { File.join(fixture_input_dir, 'file_with_no_exif.xml') }
  let(:json_fixture_file) { File.join(fixture_input_dir, 'test.json') }
  let(:obj_fixture_file) { File.join(fixture_input_dir, 'someobject.obj') }
  let(:ply_fixture_file) { File.join(fixture_input_dir, 'someobject.ply') }
  let(:vtt_fixture_file) { File.join(fixture_input_dir, 'test.vtt') }

  describe '.common_path' do
    context 'when common path is 2 nodes out of 4' do
      it 'returns the common directory' do
        expect(described_class.common_path(['/Users/peter/00/test.tif',
                                            '/Users/peter/05/test.jp2'])).to eq('/Users/peter/')
      end
    end

    context 'when common path is 3 nodes out of 4' do
      it 'returns the common directory' do
        expect(described_class.common_path(['/Users/peter/00/test.tif',
                                            '/Users/peter/00/test.jp2'])).to eq('/Users/peter/00/')
      end
    end

    context 'when all in list terminate in diff directories' do
      it 'returns the common directory' do
        expect(described_class.common_path(['/Users/peter/00', '/Users/peter/05'])).to eq('/Users/peter/')
      end
    end
  end

  describe '#new' do
    context 'without params' do
      let(:object_file) { described_class.new('/some/file.txt') }

      it 'does not set attributes' do
        expect(object_file.path).to eq('/some/file.txt')
        expect(object_file.label).to be_nil
        expect(object_file.file_attributes).to be_nil
        expect(object_file.provider_md5).to be_nil
        expect(object_file.relative_path).to be_nil
      end
    end

    context 'with params' do
      let(:object_file) do
        described_class.new('/some/file.txt', label: 'some label',
                                              file_attributes: { 'shelve' => 'yes',
                                                                 'publish' => 'yes',
                                                                 'preserve' => 'no' },
                                              relative_path: '/tmp')
      end

      it 'sets attributes to passed params' do
        expect(object_file.path).to eq('/some/file.txt')
        expect(object_file.label).to eq('some label')
        expect(object_file.file_attributes).to eq('shelve' => 'yes', 'publish' => 'yes', 'preserve' => 'no')
        expect(object_file.provider_md5).to be_nil
        expect(object_file.relative_path).to eq('/tmp')
      end

      context 'with provider_md5' do
        let(:object_file) { described_class.new('/some/file.txt', provider_md5: 'XYZ') }

        it 'sets provider_md5 to passed param' do
          expect(object_file.provider_md5).to eq('XYZ')
        end
      end
    end
  end

  describe '#filename' do
    it 'returns File.basename' do
      object_file = described_class.new(tif_fixture_file)
      expect(object_file.filename).to eq('test.tif')
      expect(object_file.filename).to eq(File.basename(tif_fixture_file))
    end
  end

  describe '#ext' do
    it 'returns the file extension' do
      object_file = described_class.new(tif_fixture_file)
      expect(object_file.ext).to eq('.tif')
    end
  end

  describe '#dirname' do
    it 'returns the File.dirname' do
      object_file = described_class.new(tif_fixture_file)
      expect(object_file.dirname).to eq(File.dirname(tif_fixture_file))
    end
  end

  describe '#filename_without_ext' do
    it 'returns filename before extension' do
      object_file = described_class.new(tif_fixture_file)
      expect(object_file.filename_without_ext).to eq('test')
    end
  end

  describe '#image?' do
    subject { object_file.image? }

    context 'with tiff' do
      let(:object_file) { described_class.new(tif_fixture_file) }

      it { is_expected.to be true }
    end

    context 'with jp2' do
      let(:object_file) { described_class.new(jp2_fixture_file) }

      it { is_expected.to be true }
    end

    context 'with targa file' do
      before do
        allow(object_file).to receive_messages(exif_mimetype: nil, file_mimetype: 'image/x-tga')
      end

      let(:object_file) { described_class.new(jp2_fixture_file) }

      it { is_expected.to be false }
    end

    context 'with ruby file' do
      let(:object_file) { described_class.new(File.join(root_path, 'spec/assembly/object_file_spec.rb')) }

      it { is_expected.to be false }
    end

    context 'with xml' do
      let(:object_file) { described_class.new(File.join(fixture_input_dir, 'file_with_no_exif.xml')) }

      it { is_expected.to be false }
    end
  end

  describe '#object_type' do
    context 'with tiff' do
      it ':image' do
        object_file = described_class.new(tif_fixture_file)
        expect(object_file.object_type).to eq(:image)
      end
    end

    context 'with jp2' do
      it ':image' do
        object_file = described_class.new(jp2_fixture_file)
        expect(object_file.object_type).to eq(:image)
      end
    end

    context 'with ruby file' do
      it ':text' do
        non_image_file = File.join(root_path, 'spec/assembly/object_file_spec.rb')
        object_file = described_class.new(non_image_file)
        expect(object_file.object_type).to eq(:text)
      end
    end

    context 'with xml' do
      it ':application' do
        non_image_file = File.join(fixture_input_dir, 'file_with_no_exif.xml')
        object_file = described_class.new(non_image_file)
        expect(object_file.object_type).to eq(:application)
      end
    end
  end

  describe '#valid_image?' do
    context 'with tiff' do
      it 'true' do
        object_file = described_class.new(tif_fixture_file)
        expect(object_file.valid_image?).to be(true)
      end
    end

    context 'with tiff resolution 1' do
      it 'true' do
        object_file = described_class.new(resource1_tif_fixture_file)
        expect(object_file.valid_image?).to be(true)
      end
    end

    context 'with tiff no color' do
      it 'true' do
        object_file = described_class.new(tiff_no_color_fixture_file)
        expect(object_file.valid_image?).to be(true)
      end
    end

    context 'with jp2' do
      it 'true' do
        object_file = described_class.new(jp2_fixture_file)
        expect(object_file.valid_image?).to be(true)
      end
    end

    context 'with ruby file' do
      it 'false' do
        non_image_file = File.join(root_path, 'spec/assembly/object_file_spec.rb')
        object_file = described_class.new(non_image_file)
        expect(object_file.valid_image?).to be(false)
      end
    end

    context 'with xml' do
      it 'false' do
        non_image_file = File.join(fixture_input_dir, 'file_with_no_exif.xml')
        object_file = described_class.new(non_image_file)
        expect(object_file.valid_image?).to be(false)
      end
    end
  end

  describe '#mimetype' do
    # rubocop:disable RSpec/RepeatedExampleGroupBody
    context 'with .txt file' do
      it 'plain/text' do
        object_file = described_class.new(resource1_text_fixture_file)
        expect(object_file.mimetype).to eq('text/plain')
      end
    end

    context 'with .xml file' do
      it 'plain/text' do
        object_file = described_class.new(resource1_text_fixture_file)
        expect(object_file.mimetype).to eq('text/plain')
      end
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody

    context 'with .tif file' do
      it 'image/tiff' do
        object_file = described_class.new(tif_fixture_file)
        expect(object_file.mimetype).to eq('image/tiff')
      end
    end

    context 'with .jp2 file' do
      it 'image/jp2' do
        object_file = described_class.new(jp2_fixture_file)
        expect(object_file.mimetype).to eq('image/jp2')
      end
    end

    context 'with .pdf file' do
      it 'application/pdf' do
        object_file = described_class.new(resource1_pdf_fixture_file)
        expect(object_file.mimetype).to eq('application/pdf')
      end
    end

    context 'with .obj (3d) file' do
      context 'when default preference (unix file system command)' do
        it 'plain/text' do
          object_file = described_class.new(obj_fixture_file)
          expect(object_file.mimetype).to eq('text/plain')
        end
      end

      context 'when mimetype extension gem preferred over unix file system command' do
        it 'application/x-tgif' do
          object_file = described_class.new(obj_fixture_file, mime_type_order: %i[extension file exif])
          expect(object_file.mimetype).to eq('application/x-tgif')
        end
      end

      context 'when invalid first preference mimetype generation' do
        it 'ignores invalid mimetype generation method and respects valid method preference order' do
          object_file = described_class.new(obj_fixture_file, mime_type_order: %i[bogus extension file])
          expect(object_file.mimetype).to eq('application/x-tgif')
        end
      end
    end

    context 'with .ply 3d file' do
      it 'text/plain' do
        object_file = described_class.new(ply_fixture_file)
        expect(object_file.mimetype).to eq('text/plain')
      end
    end

    context 'when exif information is damaged' do
      it 'gives us the mimetype' do
        object_file = described_class.new(no_exif_fixture_file)
        expect(object_file.filename).to eq('file_with_no_exif.xml')
        expect(object_file.ext).to eq('.xml')
        # we could get either of these mimetypes depending on the OS
        expect(['text/html', 'application/xml'].include?(object_file.mimetype)).to be true
      end
    end

    context 'when .json file' do
      it 'uses the manual mapping to set the correct mimetype of application/json for a .json file' do
        object_file = described_class.new(json_fixture_file)
        expect(object_file.send(:exif_mimetype)).to be_nil # exif
        expect(object_file.send(:file_mimetype)).to eq('text/plain') # unix file system command
        expect(object_file.mimetype).to eq('application/json') # our configured mapping overrides both
      end
    end

    context 'when .vtt file' do
      it 'uses the manual mapping to set the correct mimetype of text/vtt for a .vtt file' do
        object_file = described_class.new(vtt_fixture_file)
        expect(object_file.send(:exif_mimetype)).to be_nil # exif
        expect(object_file.send(:file_mimetype)).to eq('text/plain') # unix file system command
        expect(object_file.mimetype).to eq('text/vtt') # our configured mapping overrides both
      end
    end
  end

  describe '#file_mimetype (unix file system command)' do
    context 'when .json file' do
      it 'text/plain' do
        object_file = described_class.new(json_fixture_file)
        expect(object_file.send(:file_mimetype)).to eq('text/plain')
      end
    end

    context 'when .tif file' do
      it 'image/tiff' do
        object_file = described_class.new(tif_fixture_file)
        expect(object_file.send(:file_mimetype)).to eq('image/tiff')
      end
    end
  end

  describe '#jp2able?' do
    context 'with jp2 file' do
      it 'false' do
        object_file = described_class.new(jp2_fixture_file)
        expect(object_file.jp2able?).to be(false)
      end
    end

    context 'with tiff resolution 1 file' do
      it 'true' do
        object_file = described_class.new(resource1_tif_fixture_file)
        expect(object_file.jp2able?).to be(true)
      end
    end

    context 'with tiff no color file' do
      it 'true' do
        object_file = described_class.new(tiff_no_color_fixture_file)
        expect(object_file.jp2able?).to be(true)
      end
    end
  end

  describe '#md5' do
    it 'computes md5 for an image file' do
      object_file = described_class.new(tif_fixture_file)
      expect(object_file.md5).to eq('a2400500acf21e43f5440d93be894101')
    end

    it 'raises RuntimeError if no input file is passed in' do
      object_file = described_class.new('')
      expect { object_file.md5 }.to raise_error(RuntimeError, 'input file  does not exist or is a directory')
    end
  end

  describe '#sha1' do
    it 'computes sha1 for an image file' do
      object_file = described_class.new(tif_fixture_file)
      expect(object_file.sha1).to eq('8d11fab63089a24c8b17063d29a4b0eac359fb41')
    end

    it 'raises RuntimeError if no input file is passed in' do
      object_file = described_class.new('')
      expect { object_file.sha1 }.to raise_error(RuntimeError, 'input file  does not exist or is a directory')
    end
  end

  describe '#file_exists?' do
    it 'false when a valid directory is specified instead of a file' do
      path = root_path
      object_file = described_class.new(path)
      expect(File.exist?(path)).to be true
      expect(File.directory?(path)).to be true
      expect(object_file.file_exists?).to be false
    end

    it 'false when a non-existent file is specified' do
      path = File.join(root_path, 'file_not_there.txt')
      object_file = described_class.new(path)
      expect(File.exist?(path)).to be false
      expect(File.directory?(path)).to be false
      expect(object_file.file_exists?).to be false
    end
  end

  describe '#filesize' do
    it 'tells us the size of an input file' do
      object_file = described_class.new(tif_fixture_file)
      expect(object_file.filesize).to eq(63_542)
    end

    it 'raises RuntimeError if no file is passed in' do
      object_file = described_class.new('')
      expect { object_file.filesize }.to raise_error(RuntimeError, 'input file  does not exist or is a directory')
    end
  end

  describe '#exif' do
    subject(:exif) { object_file.exif }

    let(:object_file) { described_class.new(tif_fixture_file) }

    it { is_expected.to be_a MiniExiftool }

    context 'when exiftool raises an error initializing the file' do
      let(:object_file) { described_class.new('spec/fixtures/empty.txt') }

      it { is_expected.to be_nil }
    end
  end

  describe '#extension_mimetype' do
    # mime-types gem, based on a file extension lookup
    context 'with .obj file' do
      it 'application/x-tgif' do
        object_file = described_class.new(obj_fixture_file)
        expect(object_file.send(:extension_mimetype)).to eq('application/x-tgif')
      end
    end

    context 'with .tif file' do
      it 'image/tiff' do
        object_file = described_class.new(tif_fixture_file)
        expect(object_file.send(:extension_mimetype)).to eq('image/tiff')
      end
    end

    context 'with .vtt file' do
      it 'text/plain' do
        object_file = described_class.new(vtt_fixture_file)
        expect(object_file.send(:extension_mimetype)).to eq('text/vtt')
      end
    end
  end

  describe '#exif_mimetype' do
    context 'with .tif file' do
      it 'image/tiff' do
        object_file = described_class.new(tif_fixture_file)
        expect(object_file.send(:exif_mimetype)).to eq('image/tiff')
      end
    end

    context 'when .json file' do
      it 'nil' do
        object_file = described_class.new(json_fixture_file)
        expect(object_file.send(:exif_mimetype)).to be_nil
      end
    end

    context 'when .vtt file' do
      it 'nil' do
        object_file = described_class.new(vtt_fixture_file)
        expect(object_file.send(:exif_mimetype)).to be_nil
      end
    end
  end
end

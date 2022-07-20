# frozen_string_literal: true

require 'mini_exiftool'
require 'mime/types'
require 'active_support/core_ext/object/blank'

module Assembly
  # This class contains generic methods to operate on any file.
  class ObjectFile
    # @param [Array] strings Array of filenames with paths
    # @return [String] longest common initial path of filenames passed in
    #
    # Example:
    #   puts Assembly::ObjectFile.common_prefix(['/Users/peter/00/test.tif','/Users/peter/05/test.jp2'])
    #   # => '/Users/peter/0'
    def self.common_path(strings)
      return nil if strings.empty?

      n = 0
      x = strings.last
      n += 1 while strings.all? { |s| s[n] && (s[n] == x[n]) }
      common_prefix = x[0...n]
      if common_prefix[-1, 1] == '/' # check if last element of the common string is the end of a directory
        common_prefix # if not, split string along directories, and reject last one
      else
        "#{common_prefix.split('/')[0..-2].join('/')}/" # if it was, then return the common prefix directly
      end
    end

    attr_accessor :file_attributes, :label, :path, :provider_md5, :provider_sha1, :relative_path, :mime_type_order

    VALID_MIMETYPE_METHODS = %i[override exif file extension].freeze

    # @param [String] path full path to the file to be worked with
    # @param [Hash<Symbol => Object>] params options used during content metadata generation
    # @option params [Hash<Symbol => ['yes', 'no']>] :file_attributes e.g.:
    #                                                {:preserve=>'yes',:shelve=>'no',:publish=>'no'},
    #                                                defaults pulled from mimetype
    # @option params [String] :label a resource label (files bundled together will just get the first
    #                                file's label attribute if set)
    # @option params [String] :provider_md5 pre-computed MD5 checksum
    # @option params [String] :provider_sha1 pre-computed SHA1 checksum
    # @option params [String] :relative_path if you want the file ids in the content metadata it can be set,
    #                                        otherwise content metadata will get the full path
    # @option params [Array] :mime_type_order can be set to the order in which you want mimetypes to be determined
    #                                          options are :override (from manual overide mapping if exists),
    #                                                      :exif (from exif if exists)
    #                                                      :extension (from file extension)
    #                                                      :file (from unix file system command)
    #                                          the default is defined in the private `default_mime_type_order` method
    #                                          but you can override to set your own order
    def initialize(path, params = {})
      @path = path
      @label = params[:label]
      @file_attributes = params[:file_attributes]
      @relative_path = params[:relative_path]
      @provider_md5 = params[:provider_md5]
      @provider_sha1 = params[:provider_sha1]
      @mime_type_order = params[:mime_type_order] || default_mime_type_order
    end

    def filename
      File.basename(path)
    end

    def dirname
      File.dirname(path)
    end

    def ext
      File.extname(path)
    end

    def filename_without_ext
      File.basename(path, ext)
    end

    # @return [MiniExiftool] exif mini_exiftool gem object wrapper for exiftool
    def exif
      @exif ||= begin
        check_for_file
        MiniExiftool.new(path, replace_invalid_chars: '?')
      rescue MiniExiftool::Error
        # MiniExiftool will throw an exception when it tries to initialize for problematic files,
        # but the exception it throws does not tell you the file that caused the problem.
        # Instead, we will raise our own exception with more context in logging/reporting upstream.
        # Note: if the file that causes the problem should NOT use exiftool to determine mimetype, add it to the skipped
        # mimetypes in Assembly::TRUSTED_MIMETYPES to bypass initialization of MiniExiftool for mimetype generation
        raise MiniExiftool::Error, "error initializing MiniExiftool for #{path}"
      end
    end

    # @return [String] computed md5 checksum
    def md5
      check_for_file unless @md5
      @md5 ||= Digest::MD5.file(path).hexdigest
    end

    # @return [String] computed sha1 checksum
    def sha1
      check_for_file unless @sha1
      @sha1 ||= Digest::SHA1.file(path).hexdigest
    end

    # Returns mimetype information for the current file based on the ordering set in default_mime_type_order
    #   We stop computing mimetypes as soon as we have a method that returns a value
    # @return [String] mimetype of the file
    def mimetype
      @mimetype ||= begin
        check_for_file
        mimetype = ''
        mime_type_order.each do |mime_type_method|
          mimetype = send("#{mime_type_method}_mimetype") if VALID_MIMETYPE_METHODS.include?(mime_type_method)
          break if mimetype.present?
        end
        mimetype
      end
    end

    # @return [Symbol] the type of object, could be :application (for PDF or Word, etc),
    #                  :audio, :image, :message, :model, :multipart, :text or :video
    def object_type
      lookup = MIME::Types[mimetype][0]
      lookup.nil? ? :other : lookup.media_type.to_sym
    end

    # @return [Boolean] true if the mime-types gem recognizes it as an image (from file extension lookup)
    def image?
      object_type == :image
    end

    # @return [Boolean] true if the mime-types gem recognizes it as an image (from file extension lookup)
    #   AND it is a jp2 or jp2able?
    def valid_image?
      return false unless image?

      mimetype == 'image/jp2' || jp2able?
    end

    # @return [Boolean] true if we can create a jp2 from the file
    def jp2able?
      return false unless exif

      Assembly::VALID_IMAGE_MIMETYPES.include?(mimetype)
    end

    # @return [Integer] file size in bytes
    def filesize
      check_for_file
      @filesize ||= File.size(path)
    end

    # @return [Boolean] file exists and is not a directory
    def file_exists?
      @file_exists ||= (File.exist?(path) && !File.directory?(path))
    end

    private

    # check for file existence before operating on it
    def check_for_file
      raise "input file #{path} does not exist or is a directory" unless file_exists?
    end

    # defines default preferred ordering of how mimetypes are determined
    def default_mime_type_order
      %i[override exif file extension]
    end

    # @return [String] mime type for supplied file using the mime-types gem (based on a file extension lookup)
    def extension_mimetype
      @extension_mimetype ||= begin
        mtype = MIME::Types.type_for(path).first
        mtype ? mtype.content_type : ''
      end
    end

    # @return [String] mime type for supplied file based on unix file system command
    def file_mimetype
      @file_mimetype ||= begin
        check_for_file
        `file --mime-type "#{path}"`.delete("\n").split(':')[1].strip # get the mimetype from the unix file command
      end
    end

    # @return [String] mimetype information for the current file based on exif data,
    #   unless mimetype is configured as one we'd rather get from the file system command
    #   (e.g. exif struggles or we get better info from file system command)
    def exif_mimetype
      @exif_mimetype ||= begin
        check_for_file
        # if it's not a "trusted" mimetype and there is exif data; get the mimetype from the exif
        prefer_exif = !Assembly::TRUSTED_MIMETYPES.include?(file_mimetype)
        exif.mimetype if prefer_exif && exif&.mimetype
      end
    end

    # Returns mimetype information using the manual override mapping (based on a file extension lookup)
    # @return [String] mime type for supplied file if a mapping exists for the file's extension
    def override_mimetype
      @override_mimetype ||= Assembly::OVERRIDE_MIMETYPES.fetch(ext.to_sym, '')
    end
  end
end

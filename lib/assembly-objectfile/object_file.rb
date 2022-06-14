# frozen_string_literal: true

require 'mini_exiftool'
require 'mime/types'

module Assembly
  # This class contains generic methods to operate on any file.
  class ObjectFile
    # Class level method that given an array of strings, return the longest common initial path.  Useful for removing a common path from a set of filenames when producing content metadata
    #
    # @param [Array] strings Array of filenames with paths to operate on
    # @return [String] longest common initial part of path of filenames passed in
    #
    # Example:
    # puts Assembly::ObjectFile.common_prefix(['/Users/peter/00/test.tif','/Users/peter/05/test.jp2'])  # '/Users/peter/0'
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
    # @option params [Hash<Symbol => ['yes', 'no']>] :file_attributes e.g. {:preserve=>'yes',:shelve=>'no',:publish=>'no'}, defaults pulled from mimetype
    # @option params [String] :label a resource label (files bundlded together will just get the first file's label attribute if set)
    # @option params [String] :provider_md5 pre-computed MD5 checksum
    # @option params [String] :provider_sha1 pre-computed SHA1 checksum
    # @option params [String] :relative_path if you want the file ids in the content metadata it can be set, otherwise content metadata will get the full path
    # @option params [Array] :mime_type_order can be set to the order in which you want mimetypes to be determined
    #                                          options are :override (from manual overide mapping if exists), :exif (from exif if exists),
    #                                                      :extension (from file extension), and :file (from unix file system command)
    #                                          the default is defined in the private `default_mime_type_order` method but you can override to set your own order
    # @example
    #   Assembly::ObjectFile.new('/input/path_to_file.tif')
    def initialize(path, params = {})
      @path = path
      @label = params[:label]
      @file_attributes = params[:file_attributes]
      @relative_path = params[:relative_path]
      @provider_md5 = params[:provider_md5]
      @provider_sha1 = params[:provider_sha1]
      @mime_type_order = params[:mime_type_order] || default_mime_type_order
    end

    # @return [String] DPG base filename, removing the extension and the '00','05', etc. placeholders
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/cy565rm7188_00_001.tif')
    #   puts source_file.dpg_basename # "cy565rm7188_001"
    def dpg_basename
      file_parts = File.basename(path, ext).split('_')
      file_parts.size == 3 ? "#{file_parts[0]}_#{file_parts[2]}" : filename_without_ext
    end

    # @return [String] DPG subfolder for the given filename, i.e. '00','05', etc.
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/cy565rm7188_00_001.tif')
    #   puts source_file.dpg_folder # "00"
    def dpg_folder
      file_parts = File.basename(path, ext).split('_')
      file_parts.size == 3 ? file_parts[1] : ''
    end

    # @return [String] base filename
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.filename # "path_to_file.tif"
    def filename
      File.basename(path)
    end

    # @return [String] base directory
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.dirname # "/input"
    def dirname
      File.dirname(path)
    end

    # @return [String] filename extension
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.ext # ".tif"
    def ext
      File.extname(path)
    end

    # @return [String] base filename without extension
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.filename # "path_to_file"
    def filename_without_ext
      File.basename(path, ext)
    end

    # @return [MiniExiftool] exif information stored as a hash and an object
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.exif # hash with exif information
    def exif
      @exif ||= begin
        check_for_file
        MiniExiftool.new(path, replace_invalid_chars: '?')
      end
    end

    # Computes md5 checksum or returns cached value
    # @return [String] md5 checksum
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.md5 # 'XXX123XXX1243XX1243'
    def md5
      check_for_file unless @md5
      @md5 ||= Digest::MD5.file(path).hexdigest
    end

    # Computes sha1 checksum or return cached value
    # @return [String] sha1 checksum
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.sha1 # 'XXX123XXX1243XX1243'
    def sha1
      check_for_file unless @sha1
      @sha1 ||= Digest::SHA1.file(path).hexdigest
    end

    # Returns mimetype information for the current file based on the ordering set in default_mime_type_order
    #   We stop computing mimetypes as soon as we have a method that returns a value
    # @return [String] mime type
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.txt')
    #   puts source_file.mimetype # 'text/plain'
    def mimetype
      @mimetype ||= begin
        check_for_file
        mimetype = ''
        mime_type_order.each do |mime_type_method|
          mimetype = public_send("#{mime_type_method}_mimetype") if VALID_MIMETYPE_METHODS.include?(mime_type_method)
          break if mimetype.present?
        end
        mimetype
      end
    end

    # Returns mimetype information using the manual override mapping (based on a file extension lookup)
    # @return [String] mime type for supplied file if a mapping exists for the file's extension
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.json')
    #   puts source_file.override_mimetype # 'application/json'
    def override_mimetype
      @override_mimetype ||= Assembly::OVERRIDE_MIMETYPES.fetch(ext.to_sym, '')
    end

    # Returns mimetype information using the mime-types gem (based on a file extension lookup)
    # @return [String] mime type for supplied file
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.txt')
    #   puts source_file.extension_mimetype # 'text/plain'
    def extension_mimetype
      @extension_mimetype ||= begin
        mtype = MIME::Types.type_for(path).first
        mtype ? mtype.content_type : ''
      end
    end

    # Returns mimetype information for the current file based on unix file system command.
    # @return [String] mime type for supplied file
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.txt')
    #   puts source_file.file_mimetype # 'text/plain'
    def file_mimetype
      @file_mimetype ||= begin
        check_for_file
        `file --mime-type "#{path}"`.delete("\n").split(':')[1].strip # first try and get the mimetype from the unix file command
      end
    end

    # Returns mimetype information for the current file based on exif data (if available and not a trusted source that we'd rather get from the file system command)
    # @return [String] mime type for supplied file
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.txt')
    #   puts source_file.exif_mimetype # 'text/plain'
    def exif_mimetype
      @exif_mimetype ||= begin
        check_for_file
        prefer_exif = !Assembly::TRUSTED_MIMETYPES.include?(file_mimetype) # if it's not a "trusted" mimetype and there is exif data; get the mimetype from the exif
        exif.mimetype if exif&.mimetype && prefer_exif
      end
    end

    # @note Uses shell call to "file", only expected to work on unix based systems
    # @return [String] encoding for supplied file
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.txt')
    #   puts source_file.encoding # 'us-ascii'
    def encoding
      @encoding ||= begin
        check_for_file
        `file --mime-encoding "#{path}"`.delete("\n").split(':')[1].strip
      end
    end

    # @return [Symbol] the type of object, could be :application (for PDF or Word, etc), :audio, :image, :message, :model, :multipart, :text or :video
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.object_type # :image
    def object_type
      lookup = MIME::Types[mimetype][0]
      lookup.nil? ? :other : lookup.media_type.to_sym
    end

    # @return [Boolean] if object is an image
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.image? # true
    def image?
      object_type == :image
    end

    # Examines the input image for validity.  Used to determine if image is a valid and useful image.
    # If image is not a jp2, also checks if it is jp2able?
    # @return [Boolean] true if image is valid, false if not.
    # @example
    #   source_img = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_img.valid_image? # true
    def valid_image?
      return false unless image?

      mimetype == 'image/jp2' || jp2able?
    end

    # @return [Boolean] true if image has a color profile, false if not.
    # @example
    #   source_img = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_img.has_color_profile? # true
    def has_color_profile?
      return false unless exif

      exif['profiledescription'] || exif['colorspace'] ? true : false
    end

    # Examines the input image for validity to create a jp2.  Same as valid_image? but also confirms the existence of a profile description and further restricts mimetypes.
    # It is used by the assembly robots to decide if a jp2 will be created and is also called before you create a jp2 using assembly-image.
    # @return [Boolean] true if image should have a jp2 created, false if not.
    # @example
    #   source_img = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_img.jp2able? # true
    def jp2able?
      return false unless exif

      Assembly::VALID_IMAGE_MIMETYPES.include?(mimetype)
    end

    # Returns file size information for the current file in bytes.
    # @return [Integer] file size in bytes
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.filesize # 1345
    def filesize
      check_for_file
      @filesize ||= File.size(path)
    end

    # Determines if the file exists (and is not a directory)
    # @return [Boolean] file exists
    # @example
    #   source_file = Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.file_exists? # true
    def file_exists?
      @file_exists ||= (File.exist?(path) && !File.directory?(path))
    end

    private

    # prive method defining default preferred ordering of how mimetypes are determined
    def default_mime_type_order
      %i[override exif file extension]
    end

    # private method to check for file existence before operating on it
    def check_for_file
      raise "input file #{path} does not exist or is a directory" unless file_exists?
    end
  end
end

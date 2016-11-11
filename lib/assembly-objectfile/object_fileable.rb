require 'mini_exiftool'
require 'mime/types'
#require 'checksum-tools'

module Assembly

  # Namespace to include common behaviors we need for other classes in the gem
  module ObjectFileable

    # path is the full path to the user provided image
    attr_accessor :path
        
    # an optional label that can be set for each file -- if provided, this will be used as a resource label when generating content metadata (files bundlded together will just get the first's files label attribute if set)
    attr_accessor :label
    
    # an optional hash that is used to set the file attributes (publish,preserve,shelve) for the given file when generating content metadata (if not supplied, mimetype defaults are used)
    # e.g. {:preserve=>'yes',:shelve=>'no',:publish=>'no'}
    attr_accessor :file_attributes
    
    # relative path is useful when generating content metadata, if you want the file ids in the content metadata to be something other than the full path, it can be set
    #  if not, content metadata will get the full path 
    attr_accessor :relative_path
    
    # provider checksums are optional checksums given by the provider used in content metadata generation
    attr_accessor :provider_md5, :provider_sha1
    
    # Initialize file from given path.
    #
    # @param [String] path full path to the file to be worked with 
    #
    # Example:
    #   Assembly::ObjectFile.new('/input/path_to_file.tif')
    def initialize(path,params={})
      @path = path
      @label = params[:label]
      @file_attributes = params[:file_attributes]
      @relative_path = params[:relative_path]
      @provider_md5 = params[:provide_md5]
      @provider_sha1 = params[:provider_sha1]
    end
    
    # Returns base DPG name for the current file.
    #
    # @return [String] DPG base filename, removing the extension and the '00','05', etc. placeholders
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/cy565rm7188_00_001.tif')
    #   puts source_file.dpg_basename # "cy565rm7188_001"
    def dpg_basename
      file_parts=File.basename(path,ext).split('_')
      file_parts.size == 3 ? "#{file_parts[0]}_#{file_parts[2]}" : filename_without_ext
    end

    # Returns DPG subfolder for the current file.
    #
    # @return [String] DPG subfolder for the given filename, i.e. '00','05', etc. 
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/cy565rm7188_00_001.tif')
    #   puts source_file.dpg_folder # "00"
    def dpg_folder
      file_parts=File.basename(path,ext).split('_')
      file_parts.size == 3 ? file_parts[1] : ''
    end

    # Returns base filename for the current file.
    #
    # @return [String] base filename
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.filename # "path_to_file.tif"
    def filename
      File.basename(path)
    end

    # Returns base directory path for the current file.
    #
    # @return [String] base directory
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.dirname # "/input"    
    def dirname
      File.dirname(path)
    end

    # Returns filename extension
    #
    # @return [String] filename extension
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.ext # ".tif"
    def ext
      File.extname(path)
    end
    
    # Returns base filename without extension for the current file.
    #
    # @return [String] base filename without extension
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.filename # "path_to_file"
    def filename_without_ext
      File.basename(path,ext)
    end
    
    # Returns exif information for the current file.
    #
    # @return [MiniExiftool] exif information stored as a hash and an object
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.exif # gives hash with exif information
    def exif
      check_for_file unless @exif
      begin
        @exif ||= MiniExiftool.new(@path,replace_invalid_chars: '?')
      rescue
        @exif = nil
      end
    end

    # Compute md5 checksum or return value if already computed
    #
    # @return [string] md5 checksum for given file
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.md5 # gives XXX123XXX1243XX1243
    def md5
      check_for_file unless @md5
      @md5 ||= Digest::MD5.file(path).hexdigest
    end

    # Compute sha1 checksum or return value if already computed
    #
    # @return [string] sha1 checksum for given file
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.sha1 # gives XXX123XXX1243XX1243    
    def sha1
      check_for_file unless @sha1
      @sha1 ||= Digest::SHA1.file(path).hexdigest
    end

    # Returns mimetype information for the current file based on file extension or exif data (if available)
    #
    # @return [string] mime type for supplied file
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.txt')
    #   puts source_file.mimetype # gives 'text/plain'
    def mimetype
      if @mimetype.nil? # if we haven't computed it yet once for this object, try and get the mimetype
        if (!exif.nil? && !exif.mimetype.nil?)  # try and get the mimetype from the exif data if it exists
          @mimetype = exif.mimetype
        else # otherwise get it from the mime-types gem (using the file extension) assuming we can find, if not, return blank     
          mimetype = MIME::Types.type_for(@path).first
          @mimetype= mimetype ? mimetype.content_type : ''
        end
      end
      return @mimetype 
    end

    
    # Returns mimetype information for the current file based on unix file system command or exif data (if available).
    #
    # @return [string] mime type for supplied file
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.txt')
    #   puts source_file.file_mimetype # gives 'text/plain'
    def file_mimetype
      check_for_file unless @file_mimetype
      if @file_mimetype.nil? # if we haven't computed it yet once for this object, try and get the mimetype
        @file_mimetype = `file --mime-type "#{@path}"`.gsub(/\n/,"").split(':')[1].strip # first try and get the mimetype from the unix file command
        @file_mimetype = exif.mimetype if (!Assembly::TRUSTED_MIMETYPES.include?(@file_mimetype) && !exif.nil? && !exif.mimetype.nil?)  # if it's not a "trusted" mimetype and there is exif data; get the mimetype from the exif
      end
      return @file_mimetype 
    end

    # Returns encoding information for the current file (only on unix based systems).
    #
    # @return [string] encoding for supplied file
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.txt')
    #   puts source_file.encoding # gives 'us-ascii'
    def encoding
      check_for_file unless @encoding
      @encoding ||= `file --mime-encoding "#{@path}"`.gsub(/\n/,"").split(':')[1].strip
    end

    # Returns a symbol with the objects type
    #
    # @return [symbol] the type of object, could be :application (for PDF or Word, etc), :audio, :image, :message, :model, :multipart, :text or :video
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.object_type # gives :image
    def object_type
      lookup=MIME::Types[mimetype][0]
      return (lookup.nil? ? "other".to_sym : lookup.media_type.to_sym)
    end
        
    # Returns if the object file is an image.
    #
    # @return [boolean] if object is an image
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.image? # gives TRUE
    def image?
      object_type == :image 
    end

    # Examines the input image for validity.  Used to determine if image is a valid and useful image.  If image is not a jp2, also checks if it is jp2able?
    #
    # @return [boolean] true if image is valid, false if not.
    #
    # Example:
    #   source_img=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_img.valid_image? # gives true
    def valid_image?  
      
      result= image? ? true : false
      result= jp2able? unless mimetype == 'image/jp2' # further checks if we are not already a jp2

      return result
      
    end

    # Examines the input image for a color profile.
    #
    # @return [boolean] true if image has a color profile, false if not.
    #
    # Example:
    #   source_img=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_img.has_color_profile? # gives true
    def has_color_profile?
      exif.nil? ? false : (!exif['profiledescription'].nil? || !exif['colorspace'].nil?) # check for existence of profile description  
    end

    # Examines the input image for validity to create a jp2.  Same as valid_image? but also confirms the existence of a profile description and further restricts mimetypes.
    # It is used by the assembly robots to decide if a jp2 will be created and is also called before you create a jp2 using assembly-image.
    # @return [boolean] true if image should have a jp2 created, false if not.
    #
    # Example:
    #   source_img=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_img.jp2able? # gives true    
    def jp2able?
      
      result=false
      unless exif.nil?
        result=(Assembly::VALID_IMAGE_MIMETYPES.include?(mimetype)) # check for allowed image mimetypes that can be converted to jp2
      end
      return result

    end
      
    # Returns file size information for the current file in bytes.
    #
    # @return [integer] file size in bytes
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.filesize # gives 1345    
    def filesize
      check_for_file
      @filesize ||= File.size @path
    end


    # Determines if the file exists (and is not a directory)
    #
    # @return [boolean] file exists
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.file_exists? # gives true
    def file_exists?
      File.exists?(@path) && !File.directory?(@path) 
    end
 
    private
    # private method to check for file existence before operating on it
    def check_for_file
      raise "input file #{path} does not exist" unless file_exists?
    end
    
  end

end
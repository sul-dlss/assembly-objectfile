require 'mini_exiftool'
require 'mime/types'

module Assembly

  module ObjectFileable

    # the full path to the input image
    attr_accessor :path

    # Inititalize file from given path.
    #
    # @param [String] path full path to the file to be worked with 
    #
    # Example:
    #   Assembly::ObjectFile.new('/input/path_to_file.tif')
    def initialize(path)
      @path = path
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
      @exif ||= MiniExiftool.new @path  
    end

    # Returns mimetype information for the current file (only on unix based systems).
    #
    # @return [string] mime type for supplied file
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.txt')
    #   puts source_file.mimetype # gives 'text/plain'
    def mimetype
      check_for_file unless @filetype
      @mimetype ||= filetype.split(';')[0].strip
    end
    
    def self.mimetype
      self.filetype.split(';')[0].strip
    end

    # Returns mimetype information for the current file (only on unix based systems).
    #
    # @return [string] mime type for supplied file
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.txt')
    #   puts source_file.mimetype # gives 'text/plain'
    def encoding
      check_for_file unless @filetype
      @encoding ||= filetype.split(';')[1].strip
    end
    
    # Returns if the object file is an image.
    #
    # @return [boolean] if object is an image
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.image? # gives TRUE
    def image?
      MIME::Types[mimetype][0].media_type=='image'
    end

    # Examines the input image for validity.  Used to determine if image is correct and if JP2 generation is likely to succeed.
    #  This method is automatically called before you create a jp2 but it can be called separately earlier as a sanity check.
    #
    # @return [boolean] true if image is valid, false if not.
    #
    # Example:
    #   source_img=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_img.valid? # gives true
    def valid_image?
      
      check_for_file
      
      # defaults to invalid, unless we pass all checks
      result=false
      
      unless exif.nil?
        result=(exif['profiledescription'] != nil) # check for existence of profile description
        result=(Assembly::VALID_IMAGE_MIMETYPES.include?(mimetype)) # check for allowed image mimetypes
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
    
    private
    # private method to use unix level file command
    def filetype
      @filetype ||= `file -Ib #{@path}`.gsub(/\n/,"")
    end
    
    # private method to check for file existence before operating on it
    def check_for_file
      raise "input file #{path} does not exist" unless File.exists?(@path)  
    end
    
  end

end
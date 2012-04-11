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
    
    def check_for_file
      raise "input file #{path} does not exist" unless File.exists?(@path)  
    end
  
    # Returns exif information for the current file.
    #
    # @return [MiniExiftool] exif information stored as a hash and an object
    #
    # Example:
    #   source_file=Assembly::ObjectFile.new('/input/path_to_file.tif')
    #   puts source_file.exif.mimetype # gives 'image/tiff'    
    def exif
      check_for_file
      @exif ||= MiniExiftool.new @path  
    end

    def image?
      Assembly::ALLOWED_IMAGE_MIMETYPES.include?(exif.mimetype) # check to see if this a known image
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
  
  end

end
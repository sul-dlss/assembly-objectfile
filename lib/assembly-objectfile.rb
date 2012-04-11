module Assembly
  
  # the path to the gem, used to access profiles stored with the gem
  PATH_TO_GEM = File.expand_path(File.dirname(__FILE__) + '/..')

  # if input image is not one of these image mime types, an error will be raised if you try image operations
  ALLOWED_IMAGE_MIMETYPES=["image/jpeg","image/tiff"] 

  # Defines actual file MIME type and the corresponding "format" attribute in the content metadata XML file.
  # See https://consul.stanford.edu/display/chimera/DOR+file+types+and+attribute+values.
  FORMATS = {
    'image/jp2'                => 'JPEG2000',
    'image/jpeg'               => 'JPEG',
    'image/tiff'               => 'TIFF',
    'image/tiff-fx'            => 'TIFF',
    'image/ief'                => 'TIFF',
    'image/gif'                => 'GIF',
    'text/plain'               => 'TEXT',
    'text/html'                => 'HTML',
    'text/csv'                 => 'CSV',
    'audio/x-aiff'             => 'AIFF',
    'audio/x-mpeg'             => 'MP3',
    'audio/x-wave'             => 'WAV',
    'video/mpeg'               => 'MP2',
    'video/quicktime'          => 'QUICKTIME',
    'video/x-msvideo'          => 'AVI',
    'application/pdf'          => 'PDF',
    'application/zip'          => 'ZIP',
    'application/xml'          => 'XML',
    'application/tei+xml'      => 'TEI',
    'application/msword'       => 'WORD',
    'application/wordperfect'  => 'WPD',
    'application/mspowerpoint' => 'PPT',
    'application/msexcel'      => 'XLS',
    'application/x-tar'        => 'TAR',
    'application/octet-stream' => 'BINARY',
  }
  
end

require 'assembly-objectfile/object_fileable'
require 'assembly-objectfile/object_file'
module Assembly
  
  # the path to the gem, used to access profiles stored with the gem
  PATH_TO_GEM = File.expand_path(File.dirname(__FILE__) + '/..')

  # if input image is not one of these mime types, it will not be regarded as a valid image
  VALID_IMAGE_MIMETYPES=["image/jpeg","image/tiff","image/jp2"]
  
  # default publish/preserve/shelve attributes used in content metadata
  FILE_ATTRIBUTES=Hash.new
  # if no mimetype specific attributes are specified for a given file, define some defaults, and override for specific mimetypes below
  FILE_ATTRIBUTES['default']={:preserve=>'yes',:shelve=>'no',:publish=>'no'}
  FILE_ATTRIBUTES['image/tif']={:preserve=>'yes',:shelve=>'no',:publish=>'no'}
  FILE_ATTRIBUTES['image/jp2']={:preserve=>'no',:shelve=>'yes',:publish=>'yes'}
  FILE_ATTRIBUTES['image/jpeg']={:preserve=>'yes',:shelve=>'no',:publish=>'no'}
  FILE_ATTRIBUTES['audio/wav']={:preserve=>'yes',:shelve=>'no',:publish=>'no'}
  FILE_ATTRIBUTES['audio/x-wav']={:preserve=>'yes',:shelve=>'no',:publish=>'no'}
  FILE_ATTRIBUTES['audio/mp3']={:preserve=>'no',:shelve=>'yes',:publish=>'yes'}
  FILE_ATTRIBUTES['audio/mpeg']={:preserve=>'no',:shelve=>'yes',:publish=>'yes'}
  FILE_ATTRIBUTES['application/pdf']={:preserve=>'yes',:shelve=>'yes',:publish=>'yes'}
  FILE_ATTRIBUTES['plain/text']={:preserve=>'yes',:shelve=>'yes',:publish=>'yes'}
  
end

require 'assembly-objectfile/object_fileable'
require 'assembly-objectfile/object_file'
require 'assembly-objectfile/version'
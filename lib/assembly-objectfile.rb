# frozen_string_literal: true

module Assembly
  # the path to the gem, used to access profiles stored with the gem
  PATH_TO_GEM = File.expand_path(File.dirname(__FILE__) + '/..')

  # if input image is not one of these mime types, it will not be regarded as a valid image for the purpose of generating a JP2 derivative
  VALID_IMAGE_MIMETYPES = ['image/jpeg', 'image/tiff', 'image/tif', 'image/png'].freeze

  # if input file has one of these extensions in a 3D object, it will get the 3d resource type
  VALID_THREE_DIMENSION_EXTENTIONS = ['.obj'].freeze

  # the list of mimetypes that will be "trusted" by the unix file command; if a mimetype other than one of these is returned
  #  by the file command, then a check will be made to see if exif data exists...if so, the mimetype returned by the exif data will be used
  #  if no exif data exists, then the mimetype returned by the unix file command will be used
  TRUSTED_MIMETYPES = ['text/plain', 'plain/text', 'application/pdf', 'text/html', 'application/xml'].freeze

  # default publish/preserve/shelve attributes used in content metadata
  # if no mimetype specific attributes are specified for a given file, define some defaults, and override for specific mimetypes below
  FILE_ATTRIBUTES = {
    'default' => { preserve: 'yes', shelve: 'no', publish: 'no' },
    'image/tif' => { preserve: 'yes', shelve: 'no', publish: 'no' },
    'image/tiff' => { preserve: 'yes', shelve: 'no', publish: 'no' },
    'image/jp2' => { preserve: 'no', shelve: 'yes', publish: 'yes' },
    'image/jpeg' => { preserve: 'yes', shelve: 'no', publish: 'no' },
    'audio/wav' => { preserve: 'yes', shelve: 'no', publish: 'no' },
    'audio/x-wav' => { preserve: 'yes', shelve: 'no', publish: 'no' },
    'audio/mp3' => { preserve: 'no', shelve: 'yes', publish: 'yes' },
    'audio/mpeg' => { preserve: 'no', shelve: 'yes', publish: 'yes' },
    'application/pdf' => { preserve: 'yes', shelve: 'yes', publish: 'yes' },
    'plain/text' => { preserve: 'yes', shelve: 'yes', publish: 'yes' },
    'text/plain' => { preserve: 'yes', shelve: 'yes', publish: 'yes' },
    'image/png' => { preserve: 'yes', shelve: 'yes', publish: 'no' },
    'application/zip' => { preserve: 'yes', shelve: 'no', publish: 'no' },
    'application/json' => { preserve: 'yes', shelve: 'yes', publish: 'yes' }
  }.freeze
end

require 'assembly-objectfile/content_metadata'
require 'assembly-objectfile/object_fileable'
require 'assembly-objectfile/object_file'
require 'assembly-objectfile/version'

# frozen_string_literal: true

module Assembly
  # the path to the gem, used to access profiles stored with the gem
  PATH_TO_GEM = File.expand_path("#{File.dirname(__FILE__)}/..")

  # if input image is not one of these mime types, it will not be regarded as a valid image for the purpose of generating a JP2 derivative
  VALID_IMAGE_MIMETYPES = ['image/jpeg', 'image/tiff', 'image/tif', 'image/png'].freeze

  # if input file has one of these extensions in a 3D object, it will get the 3d resource type
  VALID_THREE_DIMENSION_EXTENTIONS = ['.obj'].freeze

  # the list of mimetypes that will be "trusted" by the unix file command; if a mimetype other than one of these is returned
  #  by the file command, then a check will be made to see if exif data exists...if so, the mimetype returned by the exif data will be used
  #  if no exif data exists, then the mimetype returned by the unix file command will be used
  TRUSTED_MIMETYPES = ['text/plain', 'plain/text', 'application/pdf', 'text/html', 'application/xml'].freeze
end

require 'assembly-objectfile/content_metadata'
require 'assembly-objectfile/object_fileable'
require 'assembly-objectfile/object_file'
require 'assembly-objectfile/version'

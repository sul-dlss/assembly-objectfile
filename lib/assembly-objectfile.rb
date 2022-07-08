# frozen_string_literal: true

module Assembly
  # the path to the gem, used to access profiles stored with the gem
  PATH_TO_GEM = File.expand_path("#{File.dirname(__FILE__)}/..")

  # if input image is not one of these mime types, it will not be regarded as a valid image for the purpose of generating a JP2 derivative
  VALID_IMAGE_MIMETYPES = ['image/jpeg', 'image/tiff', 'image/tif', 'image/png'].freeze

  # the list of mimetypes that will be "trusted" by the unix file command; if a mimetype other than one of these is returned
  #  by the file command, then a check will be made to see if exif data exists...if so, the mimetype returned by the exif data will be used
  #  if no exif data exists, then the mimetype returned by the unix file command will be used
  TRUSTED_MIMETYPES = ['text/plain', 'plain/text', 'application/pdf', 'text/html', 'application/xml'].freeze

  # this is a manual override mapping of file extension to mimetype; if a file with the given extension is found, the mapped
  #  mimetype will be returned and no further methods will be used - this is used to force a specific mimetype to be returned for
  #  for a given file extension regardless of what exif or the unix file system command returns
  #  the mapping format is "extension with period: returned mimetype",  e.g. for any .json file, you will always get `application/json`
  OVERRIDE_MIMETYPES = {
    '.json': 'application/json'
  }.freeze
end

require 'assembly-objectfile/object_file'
require 'assembly-objectfile/version'

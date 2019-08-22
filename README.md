[<img
src="https://travis-ci.org/sul-dlss/assembly-objectfile.svg?branch=master"
alt="Build Status" />](https://travis-ci.org/sul-dlss/assembly-objectfile)
[<img
src="https://api.codeclimate.com/v1/badges/2310962acce78d78e76c/test_coverage"
/>](https://codeclimate.com/github/sul-dlss/assembly-objectfile/test_coverage)
[<img
src="https://api.codeclimate.com/v1/badges/2310962acce78d78e76c/maintainabilit
y"
/>](https://codeclimate.com/github/sul-dlss/assembly-objectfile/maintainabilit
y)

# Assembly-ObjectFile Gem

## Overview
This gem contains classes used by the Stanford University Digital Library to
perform file operations necessary for accessioning of content.  It is also
used by related gems to perform content type specific operations (such as jp2
generation).

## Releases

*   1.0.0 initial release
*   1.0.1 add in a valid_image? method
*   1.0.2 add new mimetype and encoding methods
*   1.0.3 add new object_type method
*   1.0.4 add additional configuration parameters that are used by assembly
    and other consumers of the gem
*   1.0.5 try and get mimetype from exif before resorting to unix level file
    command
*   1.1.0 add methods to compute sha1 and md5 for object using checksum-tools
    gem
*   1.1.1 change computation of mimetype and encoding to work in more
    situations
*   1.1.2 change jp2able? and image? methods so they return a file not found
    error if the file is not supplied, added a method to indicate if a file is
    found
*   1.1.3 prepare for release listing on DLSS release board
*   1.1.4 valid_image? will now return true for jp2 mimetypes
*   1.1.5 valid_image? should be false if mimetype is correct but profile is
    not found
*   1.1.6 add jp2able? method
*   1.1.7 change the behavior of jp2able? and valid_image?
*   1.1.8 update how the version number is set to allow users to see the gem
    version # more easily
*   1.1.9 switch jpeg mimetype temporarily to publish=no, preserve=yes
*   1.2.0 move content metadata generation method to this gem from
    assembly-image
*   1.2.1 allow content metadata to add user supplied checksums
*   1.2.2 allow content metadata to bundle files into resources by filename or
    DPG filename specification, add book_as_image and file style content
    metadata generation
*   1.2.3 small change to a parameter passed to content metadata generation
*   1.2.4 allow user to control how file ID paths are generated in content
    metadata by using a 'relative_path' attribute
*   1.2.5 add a class method to find the common directory between an array of
    filenames passed in
*   1.2.6 bug fix in content metadata generation, and allow book types to have
    single <file> resource nodes if they do not contain any images
*   1.2.8 remove dependency on ChecksumTools gem to make it Ruby 1.9
    compatible
*   1.2.9 automatically strip druid: prefix in content metadata generation
    method
*   1.2.10 bug fix
*   1.2.11 add ability to suppress <xml> tag from generated contentMetadata
*   1.3.0 continued refinement of content metadata generation for objects with
    download
*   1.3.1 allow the user specify a label with the ObjectFile object that is
    picked up when generating content metadata (in specifying resource labels)
*   1.3.2 allow the user to set the label on object creation
*   1.3.3 update tests to avoid dependency on kakadu; contentMetadata will now
    generate new resources of type=object when files are present in special
    DPG folders
*   1.3.4 fix rspec test to have it run on CI server
*   1.3.5 add a parameter to flatten folder structure when creating file IDs;
    increment resource labels by object type
*   1.3.6 allow user to supply default file attributes as well as by mimetype
    --- useful if file attributes should be added and are the same regardless
    of mimetype
*   1.3.7 add a new bundle style called "prebundled" which allows users to
    pass in an array of arrays
*   1.3.8 update to latest lyberteam devel gems
*   1.3.9 compute md5 and sha1 separately when needed
*   1.4.0 compute mimetype correctly even if exif information in a file is
    damaged
*   1.4.1 fix errors that could error if there was a space in the filename
*   1.4.2 Support map style content metadata; don't compute mimetype when
    generating content metadata unless its needed
*   1.4.3 object_type method should return :other if it is an unknown mimetype
*   1.4.4 produce blank content metadata if no objects are passed in
*   1.4.5 allow the user to supply optional file specific attributes for
    publish, preserve, shelve for creating content metadata
*   1.4.6 add dirname attribute to objectfile class
*   1.4.7 add an additional default mimetype for file perservation attributes
*   1.4.8 compute mimetype with file unix command by default, and then check
    for existence of mimetype in exif unless we have a "trusted" mimetype
*   1.4.9 update list of trusted mimetypes
*   1.5.0 add the ability to skip auto label generation for resources if no
    labels are supplied
*   1.5.1 Pin mini_exiftool to 1.x and Nokogiri to 1.5.x branch for Ruby
    1.8.7, added image/png and application/zip
*   1.5.2 Fix for Rails 4 and support for 'rake console'
*   1.5.3 More gemfile updates
*   1.5.4 jp2able? method now returns true even if profile description is
    missing; add new method which does a check for existing color profile in
    an image
*   1.5.5 do not allow jp2s to have jp2s derivatives generated
*   1.5.6 do a further check for alternate existence of color profile in exif
*   1.5.7 include Gemfile.lock, pin Nokogiri to 1.5.x and ActiveSupport to
    3.2.x
*   1.6.1 remove dependencies on sulgems
*   1.6.2 Added APLv2 artifacts
*   1.6.3 Integrate with TravisCI
*   1.6.4 Try and solve UTF-8 encoding issues with exif data in images
*   1.6.5 Just use mime-types extension by default to compute mimetype to
    prevent calling to shell all the time (and avoid potential memory
    problems).  A new method allows you to call out to shell if you really
    want to.
*   1.7.0 Support the `role` attribute on files
*   1.7.1 Don't produce empty XML attributes
*   1.7.2 Allow for 3d content metadata generation
*   1.8.0 Add in mime-type generation from the shell again to correctly set 3D
    and other mimetypes (if exif data does not exist)
*   1.8.1 Adds style to error message when style is invalid


## Usage

The gem currently has methods for:
*   filesize
*   exif
*   generate content metadata


## Running tests

	bundle exec rspec spec

## Releasing the gem

gem build assembly-objectfile.gemspec gem push assembly-objectfile-x.y.z.gem 
# replace x-y-z with the version number, you'll need a ruby gems account to do
this

## Generate documentation
To generate documentation into the "doc" folder:

	yard

To keep a local server running with up to date code documentation that you can
view in your browser:

	yard server --reload

## Prerequisites

1.  Exiftool

    RHEL: (RPM to install comming soon) Download latest version from: 
    http://www.sno.phy.queensu.ca/~phil/exiftool

        tar -xf Image-ExifTool-#.##.tar.gz
        cd Image-ExifTool-#.##
        perl Makefile.PL
        make test
        sudo make install

    Mac users:
        brew install exiftool



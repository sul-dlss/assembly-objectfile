[![CircleCI](https://circleci.com/gh/sul-dlss/assembly-objectfile/tree/main.svg?style=svg)](https://circleci.com/gh/sul-dlss/assembly-objectfile/tree/main)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2310962acce78d78e76c/test_coverage)](https://codeclimate.com/github/sul-dlss/assembly-objectfile/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/2310962acce78d78e76c/maintainability)](https://codeclimate.com/github/sul-dlss/assembly-objectfile/maintainability)
[![Gem Version](https://badge.fury.io/rb/assembly-objectfile.svg)](https://badge.fury.io/rb/assembly-objectfile)

# Assembly-ObjectFile Gem

## Overview
This gem contains classes used by the Stanford University Digital Library to
perform file operations necessary for accessioning of content.  It is also
used by related gems that perform content type specific operations (e.g.
assembly-image for jp2 generation).

## Usage

The gem currently has methods for:
* filesize
* mimetype
* exif - consumers use ExifTool to get file information

## Running tests

```
bundle exec spec
```

## Releasing the gem

```
rake release
```

## Prerequisites

1.  Exiftool

    RHEL: (RPM to install coming soon) Download latest version from:
    https://exiftool.org/

        tar -xf Image-ExifTool-#.##.tar.gz
        cd Image-ExifTool-#.##
        perl Makefile.PL
        make test
        sudo make install

    Mac users:
        brew install exiftool

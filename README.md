[![Build Status](https://travis-ci.org/sul-dlss/assembly-objectfile.svg?branch=master)](https://travis-ci.org/sul-dlss/assembly-objectfile)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2310962acce78d78e76c/test_coverage)](https://codeclimate.com/github/sul-dlss/assembly-objectfile/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/2310962acce78d78e76c/maintainability)](https://codeclimate.com/github/sul-dlss/assembly-objectfile/maintainability)
[![Gem Version](https://badge.fury.io/rb/assembly-objectfile.svg)](https://badge.fury.io/rb/assembly-objectfile)

# Assembly-ObjectFile Gem

## Overview
This gem contains classes used by the Stanford University Digital Library to
perform file operations necessary for accessioning of content.  It is also
used by related gems to perform content type specific operations (such as jp2
generation).

## Usage

The gem currently has methods for:
* filesize
* exif
* generate content metadata

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

    RHEL: (RPM to install comming soon) Download latest version from:
    http://www.sno.phy.queensu.ca/~phil/exiftool

        tar -xf Image-ExifTool-#.##.tar.gz
        cd Image-ExifTool-#.##
        perl Makefile.PL
        make test
        sudo make install

    Mac users:
        brew install exiftool

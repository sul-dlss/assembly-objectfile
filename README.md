[![CircleCI](https://circleci.com/gh/sul-dlss/assembly-objectfile/tree/main.svg?style=svg)](https://circleci.com/gh/sul-dlss/assembly-objectfile/tree/main)
[![Test Coverage](https://codecov.io/github/sul-dlss/assembly-objectfile/graph/badge.svg?token=N4XeeAvaSH)](https://codecov.io/github/sul-dlss/assembly-objectfile)
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

    Ubuntu/Debian:
        sudo apt install libimage-exiftool-perl

    Mac users:
        brew install exiftool

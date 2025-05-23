<h1 style="margin-top:0px;padding-top:0px">Skia</h1>

<p align="left">
  <a href="https://github.com/CuarzoSoftware/Skia/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-BSD--3-blue.svg" alt="Skia is released under the BSD-3 license." />
  </a>
  <a href="https://github.com/CuarzoSoftware/Skia">
    <img src="https://img.shields.io/badge/version-134.0.0-brightgreen" alt="Current Skia version." />
  </a>
</p>

This repository contains a script for easily installing a components build of [Skia C++](https://github.com/google/skia) on a Linux system.

## Fedora

Install a prebuilt version from the [cuarzo/software](https://copr.fedorainfracloud.org/coprs/cuarzo/software/) COPR:

```bash
$ sudo dnf copr enable cuarzo/software
$ sudo dnf install cuarzo-skia-devel
```

## Linking

Link the library using pkg-config for `Skia`.

## Manual Building

### Dependencies

- git
- wget
- tar
- python3
- gcc
- ninja
- egl
- gl
- glesv2
- harfbuzz
- fontconfig
- icu-uc
- freetype2
- zlib
- libpng
- libwebp
- libjpeg

### Build & Install

```bash
$ git clone https://github.com/CuarzoSoftware/Skia/
$ cd Skia

# Run without params to see available options
$ ./install.sh

# Build & Install
$ SK_ARCH=x64 SK_PREFIX=/ SK_LIBDIR=/usr/lib64 SK_INCDIR=/usr/include ./install.sh
```

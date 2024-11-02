
<h1 style="margin-top:0px;padding-top:0px">Skia</h1>

<p align="left">
  <a href="https://github.com/CuarzoSoftware/Skia/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-BSD--3-blue.svg" alt="Skia is released under the BSD-3 license." />
  </a>
  <a href="https://github.com/CuarzoSoftware/Skia">
    <img src="https://img.shields.io/badge/version-0.38.2-brightgreen" alt="Current Skia version." />
  </a>
</p>

This repository contains a script for easily installing a components build of [Skia C++](https://github.com/google/skia) on a Linux system.

## Fedora

Install from [ehopperdietzel/cuarzo](https://copr.fedorainfracloud.org/coprs/ehopperdietzel/cuarzo/) COPR:

```bash
$ sudo dnf copr enable ehopperdietzel/cuarzo
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

# Later...
$ ./uninstall.sh
```

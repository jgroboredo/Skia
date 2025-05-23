#!/bin/bash

ARCH_X64=("x64" "x86_64" "amd64")
ARCH_X86=("x86" "i386" "i486" "i586" "i686")
ARCH_ARM=("arm" "armel" "armhf")
ARCH_ARM64=("arm64" "aarch64")
BIN_DEPS=("git" "wget" "tar" "python3" "gcc" "g++")
LIB_DEPS=("egl" "gl" "glesv2" "harfbuzz" "icu-uc" "fontconfig" "freetype2" "zlib" "libpng" "libwebp" "libjpeg")

help() {
    echo -e "\nUsage: SK_ARCH=ARCH SK_PREFIX=PREFIX SK_LIBDIR=LIBDIR SK_INCDIR=INCDIR $0"
    echo -e "Where:"
    echo -e "- ARCH: Target CPU architecture. Supported values:"
    echo -e "    x64   or alias [x86_64, amd64]"
    echo -e "    x86   or alias [i386, i486, i586, i686]"
    echo -e "    arm   or alias [armel, armhf]"
    echo -e "    arm64 or alias [aarch64]"
    
    echo -e "- PREFIX: Install prefix path. For example SK_PREFIX=/"
    echo -e "- LIBDIR: Libraries install path relative to SK_PREFIX. For example SK_LIBDIR=/usr/lib -> final path SK_PREFIX/usr/lib"
    echo -e "- INCDIR: Headers install path relative to SK_PREFIX. For example SK_INCDIR=/usr/include -> final path SK_PREFIX/usr/include/Skia\n"

    echo -e "System default ld library search paths:"
    local ld_search_paths=$( ld --verbose | grep SEARCH_DIR | tr -s ' ;' \\012 )
    echo ""
    for path in ${ld_search_paths[@]}; do
      echo " - $path"
    done

    echo ""
    echo -e "System default pc search paths:"
    local pc_paths=$( pkg-config --variable pc_path pkg-config | tr -s ':' \\012 )
    echo ""
    for path in ${pc_paths[@]}; do
      echo " - $path"
    done
}

summary() {
	echo -e "\n**************************** SUMMARY ****************************\n"
	echo "  Skia Version:                      $SK_VERSION"
    echo "  Skia Commit:                       $SK_COMMIT"
	echo "  Target Arch:                       $SK_ARCH"
	echo "  Install Prefix:                    $SK_PREFIX"
	echo "  Final Library Install Path:        $SK_FINAL_LIBDIR"
	echo "  Final Headers Install Path:        $SK_FINAL_INCDIR"
	echo "  Final PKGCONFIG File Install Path: $SK_FINAL_PKG_DIR"  
	echo -e "\n*****************************************************************\n"
}

concat_paths() {
    local path1="$1"
    local path2="$2"
    
    # Remove any trailing slash from the first path
    path1="${path1%/}"
    
    # Remove any leading slash from the second path
    path2="${path2#/}"

    # Concatenate the paths
    echo "$path1/$path2"
}

in_array() {
    local element
    for element in "${@:2}"; do
        if [[ "$element" == "$1" ]]; then
            return 0
        fi
    done
    return 1
}

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SK_VERSION=$(cat $SCRIPT_DIR/VERSION)
SK_COMMIT=$(cat $SCRIPT_DIR/COMMIT)

if [ -z "${SK_PREFIX}" ]; then
    echo -e "\nError: Missing install prefix."
    help
    exit 1
else
    if [[ "$SK_PREFIX" != /* ]]; then
        echo -e "\nError: The install prefix must be an absolute path."
        help
        exit 1
    fi
fi

mkdir -p $SK_PREFIX

if [ -z "${SK_LIBDIR}" ]; then
    echo -e "\nError: Missing library install path."
    help
    exit 1
else
    if [[ "$SK_LIBDIR" != /* ]]; then
        echo -e "\nError: SK_LIBDIR must start with /"
        help
        exit 1
    fi
fi

if [ -z "${SK_INCDIR}" ]; then
    echo -e "\nError: Missing headers install path."
    help
    exit 1
else
    if [[ "$SK_INCDIR" != /* ]]; then
        echo -e "\nError: SK_INCDIR must start with /"
        help
        exit 1
    fi
fi

if [ -z "${SK_ARCH}" ]; then
    echo -e "\nError: Missing target CPU arch."
    help
    exit 1
else
    TEST_ARCH=""
    
    if in_array "$SK_ARCH" "${ARCH_X64[@]}"; then
        TEST_ARCH="x64"
    fi
    
    if  [ -z "$TEST_ARCH" ] && in_array "$SK_ARCH" "${ARCH_X86[@]}"; then
        TEST_ARCH="x86"
    fi
    
    if  [ -z "$TEST_ARCH" ] && in_array "$SK_ARCH" "${ARCH_ARM[@]}"; then
        TEST_ARCH="arm"
    fi
    
    if  [ -z "$TEST_ARCH" ] && in_array "$SK_ARCH" "${ARCH_ARM64[@]}"; then
        TEST_ARCH="arm64"
    fi
    
    if  [ -z "$TEST_ARCH" ]; then
        echo -e "\nError: Invalid CPU arch: $SK_ARCH."
        help
        exit 1
    fi
    
    SK_ARCH=$TEST_ARCH
fi

# Check dependencies

echo -e "\nChecking binary dependencies:"

for DEP in "${BIN_DEPS[@]}"; do
    if command -v "$DEP" > /dev/null 2>&1; then
        echo "    Found $DEP."
    else
        echo "Error: $DEP not found."
        exit 1
    fi
done

echo -e "\nChecking library dependencies:"

for DEP in "${LIB_DEPS[@]}"; do
    if pkg-config --exists "$DEP"; then
        echo "    Found $DEP."
    else
        echo "Error: $DEP not found."
        exit 1
    fi
done

# Summary
SK_FINAL_LIBDIR=$(concat_paths $SK_PREFIX  $SK_LIBDIR)
SK_FINAL_PKG_DIR=$(concat_paths $SK_FINAL_LIBDIR "/pkgconfig")
SK_FINAL_INCDIR=$(concat_paths $SK_PREFIX $SK_INCDIR)
SK_FINAL_INCDIR=$(concat_paths $SK_FINAL_INCDIR "/Skia")
mkdir -p $SK_FINAL_INCDIR
mkdir -p $SK_FINAL_LIBDIR
mkdir -p $SK_FINAL_PKG_DIR
summary

TMP_DIR=${SCRIPT_DIR}/tmp
mkdir -p ${TMP_DIR}/build
mkdir -p ${TMP_DIR}/include
cd ${TMP_DIR}/build

if [ ! -e "$TMP_DIR/build/depot_tools" ]; then
    git clone 'https://chromium.googlesource.com/chromium/tools/depot_tools.git'
else
    echo -e "\ndepot_tools already cloned, skipping..."
fi

export PATH="${PWD}/depot_tools:${PATH}"

if [ ! -e "$TMP_DIR/build/skia" ]; then
    git clone --depth 1 --single-branch --branch main https://skia.googlesource.com/skia
    cd skia
    git fetch --depth 1 origin $SK_COMMIT
    git reset --hard $SK_COMMIT
    cd ..
else
    echo -e "\nSkia repo already cloned, skipping..."
fi

cd skia

# For some reason this sometimes fails the first time

max_retries=5
attempt=0

if [ ! -e "$TMP_DIR/build/skia/bin/gn" ]; then
    until python3 tools/git-sync-deps; do
        attempt=$((attempt+1))
        if [ $attempt -ge $max_retries ]; then
            echo "tools/git-sync-deps failed after $max_retries attempts."
            break
        fi
        echo "tools/git-sync-deps failed. Retrying ($attempt/$max_retries)..."
    done
else
    echo -e "\nbin/gn already downloaded, skipping..."
fi

bin/gn gen out/Shared --args='
target_os="linux" 
target_cpu="'$SK_ARCH'" 
cc="gcc" 
cxx="g++"
is_debug=false
is_official_build=true 
is_component_build=true 

skia_compile_modules=true 
skia_compile_sksl_tests=false
skunicode_tests_enabled=false
skia_enable_skshaper_tests=false
paragraph_tests_enabled=false

skia_enable_fontmgr_empty=true

skia_enable_tools=false
skia_enable_gpu=true 
skia_enable_skshaper=true
skia_enable_svg=true 
skia_enable_pdf=false
skia_enable_skparagraph=true
skia_enable_skunicode=true

skia_use_harfbuzz=true          skia_use_system_harfbuzz=true
skia_use_icu=true               skia_use_system_icu=true 
skia_use_freetype=true          skia_use_system_freetype2=true 
skia_use_zlib=true              skia_use_system_zlib=true 

skia_use_gl=true
skia_use_egl=true                      
skia_use_libheif=true

skia_use_system_libpng=true    
skia_use_system_libwebp=true 
skia_use_system_libjpeg_turbo=true

skia_use_x11=false
skia_use_angle=false
skia_use_vulkan=false
skia_use_metal=false
skia_use_direct3d=false
skia_use_dawn=false
skia_use_expat=false
skia_use_ffmpeg=false
skia_use_sfml=false'

ninja -C out/Shared

if [ $? -ne 0 ]; then
    echo -e "Error: Skia compilation failed."
    exit 1
fi

# TODO: instead of calling sudo several times
# escalate privilegies once only
echo -e "\nInstalling libraries into $SK_FINAL_LIBDIR:"
sudo mkdir -p $SK_FINAL_LIBDIR
sudo cp -v $TMP_DIR/build/skia/out/Shared/*.a $SK_FINAL_LIBDIR
sudo cp -v $TMP_DIR/build/skia/out/Shared/*.so $SK_FINAL_LIBDIR

echo -e "\nInstalling headers into $SK_FINAL_INCDIR:"
sudo mkdir -p $SK_FINAL_INCDIR/include
sudo mkdir -p $SK_FINAL_INCDIR/modules
sudo mkdir -p $SK_FINAL_INCDIR/src
# TODO: replace cp commands by install command
cd $TMP_DIR/build/skia/include
find . -name "*.h" -exec sudo cp -v --parents {} $SK_FINAL_INCDIR/include \;
cd $TMP_DIR/build/skia/modules
find . -name "*.h" -exec sudo cp -v --parents {} $SK_FINAL_INCDIR/modules \;
cd $TMP_DIR/build/skia/src
find . -name "*.h" -exec sudo cp -v --parents {} $SK_FINAL_INCDIR/src \;

# Gen pkgconfig file
cat <<EOF > $TMP_DIR/build/skia/out/Shared/Skia.pc
includedir=$SK_INCDIR/Skia
libdir=$SK_LIBDIR

Name: Skia
Description: Skia is a complete 2D graphic library for drawing Text, Geometries, and Images.
Version: $SK_VERSION
Libs: -L$SK_LIBDIR -lskia -lskunicode_core -lskunicode_icu -lskparagraph -lcompression_utils_portable -lpathkit -lskcms -lskshaper -ldng_sdk -lpiex -lwuffs
Cflags: -I$SK_INCDIR/Skia -DSK_GL -DSK_GANESH -DSK_UNICODE_ICU_IMPLEMENTATION
EOF

echo -e "\nInstalling Skia.pc into $SK_FINAL_PKG_DIR."
sudo cp $TMP_DIR/build/skia/out/Shared/Skia.pc $SK_FINAL_PKG_DIR
cd $SCRIPT_DIR

summary
echo -e "Installation complete.\n"



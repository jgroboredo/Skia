%global basever __MAJOR__.__MINOR__.__PATCH__
%global origrel __BUILD__
%global somajor __MAJOR__

Name:           cuarzo-skia
Version:        %{basever}%{?origrel:_%{origrel}}
Release:        1%{?dist}
Summary:        Skia is a complete 2D graphic library for drawing Text, Geometries, and Images.

License:        BSD-3
URL:            https://github.com/CuarzoSoftware/Skia

BuildRequires:  git
BuildRequires:  tar
BuildRequires:  wget
BuildRequires:  gcc-c++
BuildRequires:  python3
BuildRequires:  ninja-build
BuildRequires:  pkgconfig(egl)
BuildRequires:  pkgconfig(gl)
BuildRequires:  pkgconfig(glesv2)
BuildRequires:  pkgconfig(harfbuzz)
BuildRequires:  pkgconfig(fontconfig)
BuildRequires:  pkgconfig(icu-uc)
BuildRequires:  pkgconfig(freetype2)
BuildRequires:  pkgconfig(zlib)
BuildRequires:  pkgconfig(libpng)
BuildRequires:  pkgconfig(libwebp)
BuildRequires:  pkgconfig(libjpeg)

%description
Skia is a complete 2D graphic library for drawing Text, Geometries, and Images.

%package        devel
Summary:        Development files for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.

%prep
rm -rf repo
rm -f src.tar.gz
mkdir -p repo
wget -O src.tar.gz %{url}/archive/refs/tags/v%{basever}-1.tar.gz
tar --strip-components=1 -xzvf src.tar.gz -C repo

%build
echo "Nothing to do here."

%install
pushd repo
SK_ARCH=%{_arch} SK_PREFIX=%{buildroot} SK_LIBDIR=%{_libdir} SK_INCDIR=%{_includedir} ./install.sh

%files
%license repo/LICENSE
%doc repo/BUILD repo/CHANGES repo/VERSION
%{_libdir}/libbentleyottmann.so
%{_libdir}/libskparagraph.so
%{_libdir}/libskunicode_core.so
%{_libdir}/libskia.so
%{_libdir}/libskshaper.so 
%{_libdir}/libskunicode_icu.so
%{_libdir}/libcompression_utils_portable.a 
%{_libdir}/libpathkit.a 
%{_libdir}/libskcms.a
%{_libdir}/libdng_sdk.a
%{_libdir}/libpiex.a 
%{_libdir}/libwuffs.a

%files devel
%doc repo/README.md
%{_includedir}/Skia/
%{_libdir}/pkgconfig/Skia.pc

%changelog
* __WEEK_DAY__ __MONTH__ __MONTH_DAY__ __YEAR__ Eduardo Hopperdietzel <ehopperdietzel@gmail.com> - %{basever}-%{origrel}

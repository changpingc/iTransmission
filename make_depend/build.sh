#!/bin/bash

#########################
ARCH="armv7"
SDK_VERSION="5.0"
PARALLEL_NUM=1
#########################

PKG_CONFIG_VERSION=0.25   # DO NOT USE 0.26 which has broken dependency on glib
CURL_VERSION=7.21.5
LIBEVENT_VERSION="2.0.15-stable"
ZLIB_VERSION=1.2.5
OPENSSL_VERSION=1.0.0e
TRANSMISSION_VERSION=2.41

export BUILD_DIR="$PWD/out/${ARCH}"

if [ ${ARCH} = "i386" ]
	then
	PLATFORM="iPhoneSimulator"
elif [ ${ARCH} = "armv7" ]
	then
	PLATFORM="iPhoneOS"
elif [ ${ARCH} = "armv6" ]
	then
	PLATFORM="iPhoneOS"
else
	echo "invalid arch ${ARCH} specified"
	exit
fi

function do_export {
	export DEVROOT="/Developer/Platforms/${PLATFORM}.platform/Developer"
	export SDKROOT="/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}$SDK_VERSION.sdk"
	export LD=${DEVROOT}/usr/bin/ld
	export CPP=/usr/bin/cpp
	export CXX="${DEVROOT}/usr/bin/g++ -arch ${ARCH}"
	unset AR
	unset AS
	# export AR=${DEVROOT}/usr/bin/ar
	# export AS=${DEVROOT}/usr/bin/as
	export NM=${DEVROOT}/usr/bin/nm
	export CXXCPP=/usr/bin/cpp
	export RANLIB=${DEVROOT}/usr/bin/ranlib
	export CC="${DEVROOT}/usr/bin/gcc -arch ${ARCH}"
	export CFLAGS="-I${BUILD_DIR}/include -I${SDKROOT}/usr/include -pipe -no-cpp-precomp -isysroot ${SDKROOT}"
	export CXXFLAGS="${CFLAGS}"
	export LDFLAGS=" -L${BUILD_DIR}/lib -pipe -no-cpp-precomp -L${SDKROOT}/usr/lib -L${DEVROOT}/usr/lib -isysroot ${SDKROOT} -Wl,-syslibroot $SDKROOT"
	export PREFIX_DIR="${BUILD_DIR}"
	export COMMON_OPTIONS="--prefix=${PREFIX_DIR} --disable-shared --enable-static --disable-ipv6 --disable-manual "
	
	if [ ${PLATFORM} = "iPhoneOS" ]
		then
		COMMON_OPTIONS="--host arm-apple-darwin ${COMMON_OPTIONS}"
	elif [ ${PLATFORM} = "iPhoneSimulator" ]
		then
		COMMON_OPTIONS="--host i386-apple-darwin ${COMMON_OPTIONS}"
	fi	

	if ! echo "$PATH"|grep -q "${BUILD_DIR}/tools/bin"
	then
		export PATH="${BUILD_DIR}/tools/bin:${PATH}"
	fi
	
	export PKG_CONFIG_PATH="${SDKROOT}/usr/lib/pkgconfig:${BUILD_DIR}/lib/pkgconfig"
}

function do_unset {
	unset DEVROOT
	unset SDKROOT
	unset LD
	unset CPP
	unset CXX
	unset AR
	unset AS
	unset NM
	unset CXXCPP
	unset RANLIB
	unset CC
	unset CFLAGS
	unset LDFLAGS
	unset PREFIX_DIR
	unset COMMON_OPTIONS
	export PATH=$(echo $PATH | sed -e "s;:\?${BUILD_DIR}/tools/bin;;" -e "s;${BUILD_DIR}/tools/bin:\?;;")
}

function do_pkg_config {
	if [ ! -e "pkg-config-${PKG_CONFIG_VERSION}.tar.gz" ]
	then
	  /usr/bin/curl -O "http://pkg-config.freedesktop.org/releases/pkg-config-${PKG_CONFIG_VERSION}.tar.gz"
	fi
	
	rm -rf "pkg-config-${PKG_CONFIG_VERSION}"
	tar zxvf "pkg-config-${PKG_CONFIG_VERSION}.tar.gz"
	
	pushd "pkg-config-${PKG_CONFIG_VERSION}"
	
	do_unset
	./configure --prefix="${BUILD_DIR}/tools" ${COMMON_OPTIONS}
	make -j2
	make install
	
	popd # "pkg-config-${PKG_CONFIG_VERSION}"
}

function do_openssl {
	export PACKAGE_NAME="openssl-${OPENSSL_VERSION}"
	if [ ! -e "${PACKAGE_NAME}.tar.gz" ]
	then
	  /usr/bin/curl -O "http://www.openssl.org/source/${PACKAGE_NAME}.tar.gz"
	fi
	
	rm -rf "${PACKAGE_NAME}"
	tar zxvf "${PACKAGE_NAME}.tar.gz"
	
	pushd ${PACKAGE_NAME}
	
	do_export
	
	./configure BSD-generic32 --openssldir=${BUILD_DIR} 
	
	# Patch for iOS, taken from https://github.com/st3fan/ios-openssl/blame/master/build.sh
	perl -i -pe "s|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|" ./crypto/ui/ui_openssl.c
	perl -i -pe "s|^CC= gcc|CC= ${CC}|g" Makefile
	perl -i -pe "s|^CFLAG= (.*)|CFLAG= ${CFLAGS} $1|g" Makefile
	
	if [ ${PLATFORM} = "iPhoneSimulator" ]
		then
		pushd crypto/bn
		rm -f bn_prime.h
		perl bn_prime.pl >bn_prime.h
		popd
	fi
	
	make -j ${PARALLEL_NUM}
	make install
	
	rm -rf ${BUILD_DIR}/share/man
	
	popd
	
}

function do_zlib {
	export PACKAGE_NAME="zlib-${ZLIB_VERSION}"
	if [ ! -e "${PACKAGE_NAME}.tar.gz" ]
	then
#	  /usr/bin/curl -O "http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz"	
	  /usr/bin/curl -O "http://www.gknw.de/mirror/zlib/${PACKAGE_NAME}.tar.gz"
	fi
	
	rm -rf "${PACKAGE_NAME}"
	tar zxvf "${PACKAGE_NAME}.tar.gz"
	
	pushd ${PACKAGE_NAME}
	
	do_export
	
	./configure --prefix="${BUILD_DIR}" --static
	
	# Fix installation error
	curl "http://static.ccp.li/zlib-Makefile-patch" | patch -p0
	
	make -j ${PARALLEL_NUM}
	make install
	
	rm -rf ${BUILD_DIR}/share/man
	
	popd
}

function do_curl {
	export PACKAGE_NAME="curl-${CURL_VERSION}"
	if [ ! -e "${PACKAGE_NAME}.tar.gz" ]
	then
	  # /usr/bin/curl -O "http://curl.haxx.se/download/${PACKAGE_NAME}.tar.gz"
	  /usr/bin/curl -O "http://www.execve.net/curl/${PACKAGE_NAME}.tar.gz"
	fi
	
	rm -rf "${PACKAGE_NAME}"
	tar zxvf "${PACKAGE_NAME}.tar.gz"
	
	pushd ${PACKAGE_NAME}
	
	do_export

	./configure --prefix="${BUILD_DIR}" ${COMMON_OPTIONS} --with-random=/dev/urandom --with-ssl --with-zlib LDFLAGS="${LDFLAGS}"
	
	make -j ${PARALLEL_NUM}
	make install	
	
	popd
}

function do_libevent {
	export PACKAGE_NAME="libevent-${LIBEVENT_VERSION}"
	if [ ! -e "${PACKAGE_NAME}.tar.gz" ]
	then
	  /usr/bin/curl -O "https://github.com/downloads/libevent/libevent/${PACKAGE_NAME}.tar.gz"
	fi
	
	rm -rf "${PACKAGE_NAME}"
	tar zxvf "${PACKAGE_NAME}.tar.gz"
	
	pushd ${PACKAGE_NAME}
	
	do_export
	
	./configure --prefix="${BUILD_DIR}" ${COMMON_OPTIONS}
	
	make -j ${PARALLEL_NUM}
	make install
	
	popd
}

function do_transmission {	
	export PACKAGE_NAME="transmission-${TRANSMISSION_VERSION}"
	if [ ! -e "${PACKAGE_NAME}.tar.bz2" ]
	then
	  /usr/bin/curl -O "http://transmission.cachefly.net/${PACKAGE_NAME}.tar.bz2"
	fi
	
	rm -rf "${PACKAGE_NAME}"
	tar jxvf "${PACKAGE_NAME}.tar.bz2"
	
	pushd ${PACKAGE_NAME}
	
	do_export
	
	./configure --prefix="${BUILD_DIR}" ${COMMON_OPTIONS} --enable-largefile --enable-utp --disable-nls --enable-lightweight --enable-cli --enable-daemon --disable-mac --disable-gtk --with-kqueue --enable-debug
	
	if [ ! -e "${SDKROOT}/usr/include/net/route.h" ]
		then
		mkdir -p ${BUILD_DIR}/include/net
		cp "/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator${SDK_VERSION}.sdk/usr/include/net/route.h" "${BUILD_DIR}/include/net/route.h"
	fi
	
	make -j ${PARALLEL_NUM}
	make install
	
	# Default installation doesn't copy library and header files
	mkdir -p ${BUILD_DIR}/include/libtransmission
	find ./libtransmission -name "*.h" -exec cp "{}" ${BUILD_DIR}/include/libtransmission \;
	find . -name "*.a" -exec cp "{}" ${BUILD_DIR}/lib \;
	
	popd
}

# do_pkg_config
# do_zlib
# do_openssl
# do_curl
# do_libevent
do_transmission

# do_unset

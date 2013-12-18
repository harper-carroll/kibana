#!/bin/bash
startDir=`pwd`
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty
DIST=dist
DISTDIR="$thirdPartyDir"/$DIST
protoInstallDir="$DISTDIR"/protobuf/
protoc="$protoInstallDir"/bin/protoc
PROTOBUFFER_VERSION=2.5.0
GLOBAL_CPP_FLAGS="-fPIC -L/usr/local/probe/lib -L/usr/local/probe/lib64 -Wl,-rpath -Wl,/usr/local/probe/lib64 -Wl,-rpath -Wl,/usr/local/probe/lib -Wl,-dynamic-linker -Wl,/usr/local/probe/glibc/lib/ld-linux-x86-64.so.2 -Wl,-rpath -Wl,/usr/local/probe/glibc/lib -Ofast -m64 -O3 -march=native -flto"
PATH=/usr/local/probe/bin:$PATH

rm -rf "$DISTDIR"/protobuf
rm -rf "$thirdPartyDir"/protobuf-$PROTOBUFFER_VERSION
cd "$thirdPartyDir"
tar xvjf protobuf-$PROTOBUFFER_VERSION.tar.bz2
cd protobuf-$PROTOBUFFER_VERSION
CPPFLAGS="$CPPFLAGS $GLOBAL_CPP_FLAGS" LDFLAGS=$GLOBAL_CPP_FLAGS ./configure --prefix="$DISTDIR"/protobuf
make -j
make install

cd "$startDir"

#!/bin/bash
startDir=`pwd`
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty
DIST=dist
DISTDIR="$thirdPartyDir"/$DIST
protoInstallDir="$DISTDIR"/protobuf/
protoc="$protoInstallDir"/bin/protoc
PROTOBUFFER_VERSION=2.6.1
GLOBAL_CPP_FLAGS="-fPIC -Ofast -m64 -flto "
PATH=/usr/local/probe/bin:$PATH

rm -rf "$DISTDIR"/protobuf
rm -rf "$thirdPartyDir"/protobuf-$PROTOBUFFER_VERSION
cd "$thirdPartyDir"
tar xvzf protobuf-$PROTOBUFFER_VERSION.tar.gz
cd protobuf-$PROTOBUFFER_VERSION
CPPFLAGS="$CPPFLAGS $GLOBAL_CPP_FLAGS" LDFLAGS=$GLOBAL_CPP_FLAGS ./configure --prefix="$DISTDIR"/protobuf
make -j
make install

cd "$startDir"

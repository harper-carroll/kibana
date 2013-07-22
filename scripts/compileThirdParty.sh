#!/bin/bash
startDir=`pwd`
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty
DIST=dist
DISTDIR="$thirdPartyDir"/$DIST
protoInstallDir="$DISTDIR"/protobuf/
protoc="$protoInstallDir"/bin/protoc
PROTOBUFFER_VERSION=2.4.1
GLOBAL_CPP_FLAGS="-fPIC"
PATH=/usr/local/probe/bin:$PATH

rm -rf "$DISTDIR"/protobuf
rm -rf "$thirdPartyDir"/protobuf-$PROTOBUFFER_VERSION
cd "$thirdPartyDir"
tar xvjf protobuf-$PROTOBUFFER_VERSION.tar.bz2
cd protobuf-$PROTOBUFFER_VERSION
env CPPFLAGS="$CPPFLAGS $GLOBAL_CPP_FLAGS" ./configure --prefix="$DISTDIR"/protobuf
make
make install

cd "$startDir"

#!/bin/bash
set -e

PACKAGE=protoBuffers
VERSION=2.5.0

PWD=`pwd`
PATH=/usr/local/probe/bin:$PATH


rm -rf ~/rpmbuild
rpmdev-setuptree
cp $PWD/packaging/$PACKAGE.spec ~/rpmbuild/SPECS
cp thirdParty/protobuf-$VERSION.tar.bz2 ~/rpmbuild/SOURCES
cd ~/rpmbuild
 QA_RPATHS=$[ 0x0020|0x0002 ] rpmbuild -v -bb --target=x86_64 ~/rpmbuild/SPECS/$PACKAGE.spec

sh scripts/buildProtoFiles.sh

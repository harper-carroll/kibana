#!/bin/bash
set -e
startDir=`pwd`
protoFileDir="$startDir"/protofiles
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty
DIST=dist
DISTDIR="$thirdPartyDir"/$DIST
protoInstallDir="$DISTDIR"/protobuf/
protoc="$protoInstallDir"/bin/protoc
PROTOBUFFER_VERSION=2.6.1
GLOBAL_CPP_FLAGS="-fPIC"

if [ ! -f "$protoc" ]; then
  sh "$scriptsDir"/compileThirdParty.sh
fi


export LD_LIBRARY_PATH="$protoInstallDir"/lib
gogoBaseDir="$thirdPartyDir"/github.com/gogo/
if [ ! -d "$gogoBaseDir/protobuf" ]; then
  mkdir -p "$gogoBaseDir"
  cd "$gogoBaseDir"
  git clone https://github.com/LogRhythm/protobuf.git
  cd "$startDir"
fi

mkdir -p python
cd python
for file in `ls -p "$protoFileDir" | grep -v / | grep -v DpiMsgLRproto | grep -v Applications` ; do
  "$protoc" -I="$protoFileDir":$thirdPartyDir::/usr/local/include:/usr/include --python_out=. "$protoFileDir"/$file
done
for directory in `find "$protoFileDir" -mindepth 1 -type d ` ; do
    for file in `ls "$directory"/*.proto`; do
        "$protoc" -I="$directory":$thirdPartyDir::/usr/local/include:/usr/include --python_out=. $file
    done
done
cd "$startDir"

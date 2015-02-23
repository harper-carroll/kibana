#!/bin/bash
set -e
startDir=`pwd`
javaSrcDir="$startDir"/java/src/main/java
protoFileDir="$startDir"/protofiles
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty
DIST=dist
DISTDIR="$thirdPartyDir"/$DIST
protoInstallDir="$DISTDIR"/protobuf/
protoc="$protoInstallDir"/bin/protoc
PROTOBUFFER_VERSION=2.5.0
GLOBAL_CPP_FLAGS="-fPIC"

if [ ! -f "$protoc" ]; then
  sh "$scriptsDir"/compileThirdParty.sh
fi

export LD_LIBRARY_PATH="$protoInstallDir"/lib

mkdir -p "$javaSrcDir"
cd "$javaSrcDir"
"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/BaseConfMsg.proto
# the build below will generate java code with single methods > 64k, to fix this
# we would have to enable option optimize_for = CODE_SIZE
#"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/DpiMsgLRproto.proto
for file in `ls "$protoFileDir" | grep -v DpiMsgLRproto | grep -v Applications` ; do
  "$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/$file
done
cd "$startDir"

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
PROTOBUFFER_VERSION=2.6.1
GLOBAL_CPP_FLAGS="-fPIC"

if [ ! -f "$protoc" ]; then
  sh "$scriptsDir"/compileThirdParty.sh
fi

expectedProtoCVersion="libprotoc 2.6.1"
actualProtoCVersion=`$protoc --version`
if [ "$actualProtoCVersion" != "$expectedProtoCVersion" ]
then
   echo "Expected protoc version: $expectedProtoCVersion"
   echo "Actual protoc version: $actualProtoCVersion"
   echo "You must use the install the expected version to continue"
   exit 1
fi


export LD_LIBRARY_PATH="$protoInstallDir"/lib
gogoBaseDir="$thirdPartyDir"/github.com/gogo/
if [ ! -d "$gogoBaseDir/protobuf" ]; then
  mkdir -p "$gogoBaseDir"
  cd "$gogoBaseDir"
  git clone https://github.com/LogRhythm/protobuf.git
  cd "$startDir"
fi

mkdir -p "$javaSrcDir"
cd "$javaSrcDir"
#"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/BaseConfMsg.proto
# the build below will generate java code with single methods > 64k, to fix this
# we would have to enable option optimize_for = CODE_SIZE
#"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/DpiMsgLRproto.proto
for file in `ls -p "$protoFileDir" | grep -v / | grep -v DpiMsgLRproto | grep -v Applications` ; do
  "$protoc" -I="$protoFileDir":$thirdPartyDir::/usr/local/include:/usr/include --java_out=. "$protoFileDir"/$file
done
for directory in `find "$protoFileDir" -type d -mindepth 1` ; do
    for file in `ls "$directory"/*.proto`; do
        "$protoc" -I="$directory":$thirdPartyDir::/usr/local/include:/usr/include --java_out=. $file
    done
done
cd "$startDir"

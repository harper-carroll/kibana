#!/bin/bash
startDir=`pwd`
javaSrcDir="$startDir"/java/src/main/java
cppSrcDir="$startDir"/cpp/source
phpSrcDir="$startDir"/php
protoFileDir="$startDir"/protofiles
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty
DIST=dist
DISTDIR="$thirdPartyDir"/$DIST
protoInstallDir="$DISTDIR"/protobuf/
protoc="$protoInstallDir"/bin/protoc
phpprotoc=/usr/bin/protoc-gen-php
PROTOBUFFER_VERSION=2.4.1
GLOBAL_CPP_FLAGS="-fPIC"

if [ ! -f "$protoc" ]; then
  sh "$scriptsDir"/compileThirdParty.sh
fi

if [ ! -f "$phpprotoc" ]; then
  sh "$scriptsDir"/getPhpProtobuffers.sh
fi

cp "$protoFileDir"/DpiMsgLRproto.proto "$protoFileDir"/DpiMsgLRproto.proto.orig
sh "$scriptsDir"/buildDpiMsgLRProto.sh > "$protoFileDir"/DpiMsgLRproto.proto

export LD_LIBRARY_PATH="$protoInstallDir"/lib

mkdir -p "$javaSrcDir"
cd "$javaSrcDir"
"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/BaseConfMsg.proto
# the build below will generate java code with single methods > 64k, to fix this
# we would have to enable option optimize_for = CODE_SIZE
#"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/DpiMsgLRproto.proto
"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/StatsMsg.proto
"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/StatsAggMsg.proto
"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/QosmosConfMsg.proto
"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/ConfTypeMsg.proto
"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/RestartMsg.proto
"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/VersionMsg.proto
"$protoc" -I="$protoFileDir" --java_out=. "$protoFileDir"/SyslogConfMsg.proto
cd "$startDir"

mkdir -p "$cppSrcDir"/liblrdpi "$cppSrcDir"/libstats "$cppSrcDir"/libconf
cd "$cppSrcDir"
"$protoc" -I="$protoFileDir" --cpp_out=liblrdpi  "$protoFileDir"/DpiMsgLRproto.proto
"$protoc" -I="$protoFileDir" --cpp_out=libstats  "$protoFileDir"/StatsMsg.proto
"$protoc" -I="$protoFileDir" --cpp_out=libconf  "$protoFileDir"/BaseConfMsg.proto
"$protoc" -I="$protoFileDir" --cpp_out=libconf  "$protoFileDir"/QosmosConfMsg.proto
"$protoc" -I="$protoFileDir" --cpp_out=libconf  "$protoFileDir"/ConfTypeMsg.proto
"$protoc" -I="$protoFileDir" --cpp_out=libconf  "$protoFileDir"/RestartMsg.proto
"$protoc" -I="$protoFileDir" --cpp_out=libconf  "$protoFileDir"/VersionMsg.proto
"$protoc" -I="$protoFileDir" --cpp_out=libconf  "$protoFileDir"/SyslogConfMsg.proto
mv  liblrdpi/DpiMsgLRproto.pb.cc liblrdpi/DpiMsgLRproto.pb.cpp
mv  libstats/StatsMsg.pb.cc  libstats/StatsMsg.pb.cpp
mv  libconf/BaseConfMsg.pb.cc  libconf/BaseConfMsg.pb.cpp
mv  libconf/QosmosConfMsg.pb.cc  libconf/QosmosConfMsg.pb.cpp
mv  libconf/ConfTypeMsg.pb.cc  libconf/ConfTypeMsg.pb.cpp
mv  libconf/RestartMsg.pb.cc  libconf/RestartMsg.pb.cpp
mv  libconf/VersionMsg.pb.cc  libconf/VersionMsg.pb.cpp
mv  libconf/SyslogConfMsg.pb.cc  libconf/SyslogConfMsg.pb.cpp
cd "$startDir"

mkdir -p "$phpSrcDir"
cd "$phpSrcDir"
"$phpprotoc" -i "$protoFileDir" -o . --protoc="$protoc" "$protoFileDir"/BaseConfMsg.proto
"$phpprotoc" -i "$protoFileDir" -o . --protoc="$protoc" "$protoFileDir"/QosmosConfMsg.proto
"$phpprotoc" -i "$protoFileDir" -o . --protoc="$protoc" "$protoFileDir"/ConfTypeMsg.proto
"$phpprotoc" -i "$protoFileDir" -o . --protoc="$protoc" "$protoFileDir"/RestartMsg.proto
"$phpprotoc" -i "$protoFileDir" -o . --protoc="$protoc" "$protoFileDir"/VersionMsg.proto
"$phpprotoc" -i "$protoFileDir" -o . --protoc="$protoc" "$protoFileDir"/SyslogConfMsg.proto
cd "$startDir"

#!/bin/bash
set -e
set -x
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
protoc="/usr/local/probe/bin/protoc"
phpprotoc="/usr/local/probe/bin/protoc-gen-php"
PROTOBUFFER_VERSION=2.6.1
GLOBAL_CPP_FLAGS="-fPIC"

if [ ! -d "$startDir/thirdParty/dist/protobuf/include" ]; then
  # skip a bunch of warnings. just create this directory if it doesn't already exist
  # even if it is not always used
  mkdir -p "$startDir/thirdParty/dist/protobuf/include"
fi

gogoBaseDir="$thirdPartyDir"/github.com/gogo/
if [ ! -d "$gogoBaseDir/protobuf" ]; then
  mkdir -p "$gogoBaseDir"
  cd "$gogoBaseDir"
  git clone https://github.com/LogRhythm/protobuf.git
  cd "$startDir"
fi

if [ ! -f "$protoc" ]; then
  sh "$scriptsDir"/compileThirdParty.sh
fi

if [ ! -f "$phpprotoc" ]; then
  echo "$phpprotoc not found... should be installed from thirdparty bootstrap."
  exit 1
fi

mkdir -p "$cppSrcDir"/liblrdpi "$cppSrcDir"/libstats "$cppSrcDir"/libconf $cppSrcDir/libcommand "$cppSrcDir"/libprocess "$cppSrcDir"/liblua "$cppSrcDir"/libtools "$cppSrcDir"/libfork "$cppSrcDir"/liblicense "$cppSrcDir"/libmessages

cp "$protoFileDir"/DpiMsgLRproto.proto "$protoFileDir"/DpiMsgLRproto.proto.orig
cp "$protoFileDir"/Applications.proto "$protoFileDir"/Applications.proto.orig
sh "$scriptsDir"/buildDpiMsgLRProto.sh > "$protoFileDir"/DpiMsgLRproto.proto
sh "$scriptsDir"/buildApplicationsProto.sh > "$protoFileDir"/Applications.proto
cd "$scriptsDir"/..
sh "$scriptsDir"/buildESTemplate.sh
sh "$scriptsDir"/buildUIFieldMap.sh
cd $startDir
rm "$protoFileDir"/Applications.proto.orig
rm "$protoFileDir"/DpiMsgLRproto.proto.orig
sh "$scriptsDir"/generateApplicationsCSV.sh > "$protoFileDir"/../resources/Applications.csv
sh "$scriptsDir"/mapQosMosToSyslog.sh

export LD_LIBRARY_PATH="$protoInstallDir"/lib

mkdir -p "$javaSrcDir"
cd "$javaSrcDir"
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include:$thirdPartyDir::$DISTDIR/protobuf/include:/usr/include --java_out=. "$protoFileDir"/BaseConfMsg.proto
# the build below will generate java code with single methods > 64k, to fix this
# we would have to enable option optimize_for = CODE_SIZE
#"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include:$thirdPartyDir::$DISTDIR/protobuf/include:/usr/include --java_out=. "$protoFileDir"/DpiMsgLRproto.proto
for file in `ls "$protoFileDir" | grep -v DpiMsgLRproto | grep -v Applications` ; do
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --java_out=. "$protoFileDir"/$file
done
cd "$startDir"

cd "$cppSrcDir"
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=liblrdpi "$protoFileDir"/DpiMsgLRproto.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=liblrdpi "$protoFileDir"/Applications.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libstats "$protoFileDir"/StatsMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libconf "$protoFileDir"/BaseConfMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libconf "$protoFileDir"/QosmosConfMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libconf "$protoFileDir"/ConfTypeMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libconf "$protoFileDir"/NetInterfaceMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libconf "$protoFileDir"/NtpMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libconf "$protoFileDir"/RestartMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libconf "$protoFileDir"/ShutdownMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libconf "$protoFileDir"/VersionMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libconf "$protoFileDir"/SyslogConfMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libconf "$protoFileDir"/ReaderRuleConf.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=liblua "$protoFileDir"/Rule.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libcommand "$protoFileDir"/CommandRequest.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libcommand "$protoFileDir"/CommandReply.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libprocess "$protoFileDir"/ProcessRequest.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libprocess "$protoFileDir"/ProcessReply.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libcommand "$protoFileDir"/DriveInfo.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libcommand "$protoFileDir"/LuaDefinedRule.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libcommand "$protoFileDir"/DeepScriptIOMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libcommand "$protoFileDir"/ConfigDefaults.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libcommand "$protoFileDir"/ConfigDefaultsRequest.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libfork "$protoFileDir"/ForkerReply.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libfork "$protoFileDir"/ForkerRequest.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=liblicense "$protoFileDir"/LicenseReply.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=liblicense "$protoFileDir"/LicenseRequest.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=liblicense "$protoFileDir"/License.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libmessages "$protoFileDir"/LogMessage.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libmessages "$protoFileDir"/ESDataMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libmessages "$protoFileDir"/ESDataLogMsg.proto
"$protoc" -I="$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include --cpp_out=libcommand "$protoFileDir"/PcapDownloadMsg.proto
mv  liblrdpi/DpiMsgLRproto.pb.cc liblrdpi/DpiMsgLRproto.pb.cpp
mv  liblrdpi/Applications.pb.cc liblrdpi/Applications.pb.cpp
mv  libstats/StatsMsg.pb.cc  libstats/StatsMsg.pb.cpp
mv  libconf/BaseConfMsg.pb.cc  libconf/BaseConfMsg.pb.cpp
mv  libconf/NetInterfaceMsg.pb.cc  libconf/NetInterfaceMsg.pb.cpp
mv  libconf/NtpMsg.pb.cc  libconf/NtpMsg.pb.cpp
mv  libconf/QosmosConfMsg.pb.cc  libconf/QosmosConfMsg.pb.cpp
mv  libconf/ConfTypeMsg.pb.cc  libconf/ConfTypeMsg.pb.cpp
mv  libconf/RestartMsg.pb.cc  libconf/RestartMsg.pb.cpp
mv  libconf/ShutdownMsg.pb.cc  libconf/ShutdownMsg.pb.cpp
mv  libconf/VersionMsg.pb.cc  libconf/VersionMsg.pb.cpp
mv  libconf/SyslogConfMsg.pb.cc  libconf/SyslogConfMsg.pb.cpp
mv  libconf/ReaderRuleConf.pb.cc  libconf/ReaderRuleConf.pb.cpp
mv  liblua/Rule.pb.cc  liblua/Rule.pb.cpp
mv  libcommand/CommandRequest.pb.cc  libcommand/CommandRequest.pb.cpp
mv  libcommand/CommandReply.pb.cc  libcommand/CommandReply.pb.cpp
mv  libprocess/ProcessRequest.pb.cc  libprocess/ProcessRequest.pb.cpp
mv  libprocess/ProcessReply.pb.cc  libprocess/ProcessReply.pb.cpp
mv  libcommand/DriveInfo.pb.cc  libcommand/DriveInfo.pb.cpp
mv  libcommand/LuaDefinedRule.pb.cc  libcommand/LuaDefinedRule.pb.cpp
mv  libcommand/DeepScriptIOMsg.pb.cc  libcommand/DeepScriptIOMsg.pb.cpp

mv  libcommand/ConfigDefaults.pb.cc  libcommand/ConfigDefaults.pb.cpp
mv  libcommand/ConfigDefaultsRequest.pb.cc  libcommand/ConfigDefaultsRequest.pb.cpp
mv  libfork/ForkerReply.pb.cc  libfork/ForkerReply.pb.cpp
mv  libfork/ForkerRequest.pb.cc  libfork/ForkerRequest.pb.cpp
mv  liblicense/LicenseReply.pb.cc  liblicense/LicenseReply.pb.cpp
mv  liblicense/LicenseRequest.pb.cc  liblicense/LicenseRequest.pb.cpp
mv  liblicense/License.pb.cc  liblicense/License.pb.cpp
mv  libmessages/LogMessage.pb.cc  libmessages/LogMessage.pb.cpp
mv  libmessages/ESDataMsg.pb.cc  libmessages/ESDataMsg.pb.cpp
mv  libmessages/ESDataLogMsg.pb.cc  libmessages/ESDataLogMsg.pb.cpp
mv  libcommand/PcapDownloadMsg.pb.cc  libcommand/PcapDownloadMsg.pb.cpp
cd "$startDir"

mkdir -p "$phpSrcDir"
cd "$phpSrcDir"
for file in `ls "$protoFileDir"` ; do
  "$phpprotoc" -o . --protoc="$protoc -I "$protoFileDir":$thirdPartyDir:/usr/include:$DISTDIR/protobuf/include" "$protoFileDir"/$file
done
cd "$startDir"

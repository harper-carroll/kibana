#!/bin/bash
set -e
if [ -z "$GOPATH" ]; then export GOPATH=~/go; fi
if [ -z "$GOBIN" ]; then export GOBIN=$GOPATH/bin; fi
if [ -z "$GOROOT" ]; then export GOROOT=/usr/local/go; fi
startDir=`pwd`
goSrc=$GOPATH/src/github.schq.secious.com/Logrhythm/GoMessaging/
goLR=$GOPATH/src/github.schq.secious.com/Logrhythm
protoFileDir="$startDir"/protofiles
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty

go get github.com/gogo/protobuf/proto
go get github.com/gogo/protobuf/protoc-gen-gogo
go get github.com/gogo/protobuf/gogoproto

mkdir -p $goSrc
if [ ! -d "$goSrc" ]; then
   cd $goLR
   git clone git@github.schq.secious.com:Logrhythm/GoMessaging.git
   cd $startDir
fi


cd $goSrc
#protoc --gogo_out=/Users/ben.aldrich/go/src/ -I=/Users/ben.aldrich/go/src/:/Users/ben.aldrich/go/src/github.com/gogo/protobuf/protobuf/ --proto_path=/Users/ben.aldrich/go/src/github.schq.secious.com/Ben-Aldrich/goforkyourself/fork/ /Users/ben.aldrich/go/src/github.schq.secious.com/Ben-Aldrich/goforkyourself/fork/*.proto
# the build below will generate java code with single methods > 64k, to fix this
# we would have to enable option optimize_for = CODE_SIZE
#"$protoc" -I="$protoFileDir" --gogo_out=. "$protoFileDir"/DpiMsgLRproto.proto
for file in `ls "$protoFileDir" | grep -v DpiMsgLRproto | grep -v Applications` ; do
  protoc -I="$protoFileDir":"$GOPATH"/src/github.com/gogo/protobuf/protobuf/ --gogo_out=. "$protoFileDir"/$file
done
cd "$startDir"

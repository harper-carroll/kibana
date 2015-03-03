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
for file in `ls "$protoFileDir" | grep -v DpiMsgLRproto | grep -v Applications | grep -v BaseConfMsg` ; do
  protoc -I="$protoFileDir":"$GOPATH"/src/:/usr/local/include:/usr/include --gogo_out=. "$protoFileDir"/$file 
done
cd "$startDir"

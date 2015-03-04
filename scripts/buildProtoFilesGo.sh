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
rm "$goSrc"/*.proto
cp `ls "$protoFileDir"/* | grep -v Config | grep -v ESData | grep -v RuleConf | grep -v DpiMsgLRproto | grep -v Applications | grep -v BaseConfMsg `  "$goSrc"/
cd $goSrc
protoc -I="$GOPATH"/src/:/usr/local/include:/usr/include:$goSrc/ --gogo_out=$GOPATH/src/ $goSrc/*.proto
cd "$startDir"

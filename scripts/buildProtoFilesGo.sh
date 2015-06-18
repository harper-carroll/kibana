#!/bin/bash
set -e
if [ -z "$GOPATH" ]; then export GOPATH=~/go; fi
if [ -z "$GOBIN" ]; then export GOBIN=$GOPATH/bin; fi
if [ -z "$GOROOT" ]; then export GOROOT=/usr/local/go; fi
startDir=`pwd`
goSrc=$GOPATH/src/github.schq.secious.com/Logrhythm/GoMessaging
goLR=$GOPATH/src/github.schq.secious.com/Logrhythm
protoFileDir="$startDir"/protofiles
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty
go get github.com/LogRhythm/protobuf/proto
go get github.com/gogo/protobuf/protoc-gen-gogo
go get github.com/gogo/protobuf/gogoproto

mkdir -p $goSrc
rm "$goSrc"/*.proto || true
rm "$goSrc"/clipboard/*.proto || true
if [ ! -d "$goSrc" ]; then
   cd $goLR
   git clone git@github.schq.secious.com:Logrhythm/GoMessaging.git
   cd $startDir
fi

(cd "$protoFileDir"; "$scriptsDir"/rewriteProto/rewriteProto . $goSrc/)

( cd $goSrc; protoc -I="$GOPATH"/src/:/usr/local/include:/usr/include:$goSrc --gogo_out=$GOPATH/src/ $goSrc/*.proto )
( cd "$goSrc"/clipboard; protoc -I="$GOPATH"/src/:/usr/local/include:/usr/include:$goSrc:$goSrc/clipboard/ --gogo_out=$GOPATH/src/ "$goSrc"/clipboard/*.proto) 
( cd "$goSrc"/clipboard; protoc -I="$GOPATH"/src/:/usr/local/include:/usr/include:$goSrc:$goSrc/clipboard/ --gogo_out=$GOPATH/src/ "$goSrc"/heartthrob/*.proto) 
rm "$goSrc"/*.proto || true
rm "$goSrc"/clipboard/*.proto || true

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
mkdir -p $goSrc/stats
if [ ! -d "$goSrc" ]; then
   cd $goLR
   git clone git@github.schq.secious.com:Logrhythm/GoMessaging.git
   cd $startDir
fi

#(cd "$protoFileDir"/stats; cp "$protoFileDir"/stats/*  "$goSrc"/stats/ )
#(cd "$protoFileDir"; cp `ls  | grep -v Config | grep -v ESData | grep -v RuleConf | grep -v DpiMsgLRproto | grep -v Applications | grep -v BaseConfMsg | grep -v stats`   "$goSrc"/ )

(cd "$protoFileDir"; "$scriptsDir"/RewriteProto/RewriteProto . $goSrc/)

( cd $goSrc; protoc -I="$GOPATH"/src/:/usr/local/include:/usr/include:$goSrc:/$goSrc/stats/ --gogo_out=$GOPATH/src/ "$goSrc"/*.proto )
( cd "$goSrc"/stats; protoc -I="$GOPATH"/src/:/usr/local/include:/usr/include:$goSrc:$goSrc/stats/ --gogo_out=$GOPATH/src/ "$goSrc"/stats/*.proto )
rm "$goSrc"/*.proto
rm "$goSrc"/stats/*.proto

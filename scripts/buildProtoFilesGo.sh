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

( cd $goSrc;
 for d in */ ; do
  #ignore UX files
#  if [ "$d" = "configelementsux/" ]; then
#    continue;
#  fi
    rm $goSrc/"$d"*.proto || true
 done
)

if [ ! -d "$goSrc" ]; then
   cd $goLR
   git clone git@github.schq.secious.com:Logrhythm/GoMessaging.git
   cd $startDir
fi

(cd "$protoFileDir"; "$scriptsDir"/rewriteProto/rewriteProto . $goSrc/)

( cd $goSrc; 
find * -not -path '*/\.*'  -type d  -exec  /usr/bin/sh -c "protoc -I=$GOPATH/src/:/usr/local/include:/usr/include:$goSrc:$goSrc --gogo_out=$GOPATH/src/  $goSrc/{}/*.proto" \;
find * -not -path '*/\.*'  -type d  -exec /usr/bin/sh -c "rm $goSrc/{}/*.proto" \;
)

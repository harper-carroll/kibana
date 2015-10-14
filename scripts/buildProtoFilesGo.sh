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

# Seems as though we should be able to do a `go get` for this repo, but it
# reports 'unrecognized import path'
if [ ! -d $goLR/rewriteProto ]; then
  git clone github.schq.secious.com/Logrhythm/rewriteProto $goLR/rewriteProto
fi
go install github.schq.secious.com/Logrhythm/rewriteProto
go get github.com/LogRhythm/protobuf/proto
go get github.com/LogRhythm/protobuf/proto
go get github.com/gogo/protobuf/protoc-gen-gogo
go get github.com/gogo/protobuf/gogoproto

mkdir -p $goSrc

(
cd $goSrc;
for d in */ ; do
  rm $goSrc/"$d"*.proto || true
done
)

# rewriteProto process proto files for use with gogoprotobuf and deposits the result in $goSrc
# which are then compiled into .pb.go files by protoc, etc below
(cd "$protoFileDir"; rewriteProto -conf $goLR/rewriteProto/c.yml . $goSrc/)

(
cd $goSrc;
find * -type d -exec /usr/bin/sh -c "protoc -I=$GOPATH/src/:/usr/local/include:/usr/include:$goSrc --gogo_out=$GOPATH/src/  $goSrc/{}/*.proto" \;
find * -type d -exec /usr/bin/sh -c "rm $goSrc/{}/*.proto" \;

#compile all main level protos
protoc -I=$GOPATH/src/:/usr/local/include:/usr/include:$goSrc --gogo_out=$GOPATH/src/  $goSrc/*.proto
rm $goSrc/*.proto
)

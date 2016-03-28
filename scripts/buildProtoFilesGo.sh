#!/bin/bash
set -e
if [ -z "$GOPATH" ]; then export GOPATH=~/go; fi
if [ -z "$GOBIN" ]; then export GOBIN=$GOPATH/bin; fi
if [ -z "$GOROOT" ]; then export GOROOT=/usr/local/go; fi
startDir=`pwd`
goSrc=$GOPATH/src/github.schq.secious.com/Logrhythm/GoMessaging_Gen
goLR=$GOPATH/src/github.schq.secious.com/Logrhythm
protoFileDir="$startDir"/protofiles
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty

# Seems as though we should be able to do a `go get` for this repo, but it
# reports 'unrecognized import path'
if [ ! -d $goLR/rewriteProto ]; then
  echo "Cloning http://github.schq.secious.com/Logrhythm/rewriteProto.git"
  git clone http://github.schq.secious.com/Logrhythm/rewriteProto.git $goLR/rewriteProto
fi

echo "Running 'go get' dependencies this script requires"
go get gopkg.in/yaml.v2 # required by rewriteProto
go install github.schq.secious.com/Logrhythm/rewriteProto
go get github.com/LogRhythm/protobuf/proto
go get github.com/gogo/protobuf || true # no buildable source (exits with non-zero)


mkdir -p $goSrc # Gauranteeing GoMessaging is a real directory

echo "Removing pre-existing .proto files in $goSrc"
(
cd $goSrc;
rm -rf $(find * -name '*.proto' | grep -v 'vendor/')
)
# rewriteProto process proto files for use with gogoprotobuf and deposits the result in $goSrc
# which are then compiled into .pb.go files by protoc, etc below
echo "Processing .proto files from Protobuffers repo into GoMessaging to add gogoprotobuf extensions"
(cd "$protoFileDir"; rewriteProto -conf $goLR/rewriteProto/c.yml . $goSrc/)

echo "Running Protoc"
(
cd $goSrc;
find * -type d -exec /usr/bin/sh -c "protoc -I=$GOPATH/src/:/usr/local/include:/usr/include:$goSrc --gogo_out=$GOPATH/src/  $goSrc/{}/*.proto" \;
find * -type d -exec /usr/bin/sh -c "rm $goSrc/{}/*.proto" \;

echo "Compile all main level protos"
protoc -I=$GOPATH/src/:/usr/local/include:/usr/include:$goSrc --gogo_out=$GOPATH/src/  $goSrc/*.proto
rm -rf $(find * -name '*.proto' | grep -v 'vendor/')
)
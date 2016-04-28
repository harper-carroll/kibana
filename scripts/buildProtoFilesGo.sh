#!/bin/bash
set -e

expectedProtoCVersion="libprotoc 2.6.1"
actualProtoCVersion=`protoc --version`
if [ "$actualProtoCVersion" != "$expectedProtoCVersion" ]
then
   echo "Expected protoc version: $expectedProtoCVersion"
   echo "Actual protoc version: $actualProtoCVersion"
   echo "You must use the install the expected version to continue"
   exit 1
fi

if [ -z "$PROTOINCLUDE" ]; then export PROTOINCLUDE=/usr/local/include; fi
if [ -z "$GOPATH" ]; then export GOPATH=~/go; fi
if [ -z "$GOBIN" ]; then export GOBIN=$GOPATH/bin; fi
if [ -z "$GOROOT" ]; then export GOROOT=/usr/local/go; fi
startDir=`pwd`
goSrc=$GOPATH/src/github.schq.secious.com/Logrhythm/GoMessaging
goLR=$GOPATH/src/github.schq.secious.com/Logrhythm
protoFileDir="$startDir"/protofiles
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty

echo "Running 'go get' dependencies this script requires"
go get github.schq.secious.com/Logrhythm/rewriteProto
go install github.schq.secious.com/Logrhythm/rewriteProto
go get github.schq.secious.com/DataIndexer/GoGoProtobuf || true # ignore 'no buildable source' non-zero exit

mkdir -p $goSrc # Guaranteeing GoMessaging is a real directory

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
find * -type d -exec /bin/sh -c "protoc -I=$GOPATH/src/:$PROTOINCLUDE:/usr/local/include:/usr/include:$goSrc --gogo_out=$GOPATH/src/  $goSrc/{}/*.proto" \;
find * -type d -exec /bin/sh -c "rm $goSrc/{}/*.proto" \;

echo "Compile all main level protos"
protoc -I=$GOPATH/src/:$PROTOINCLUDE:/usr/local/include:/usr/include:$goSrc --gogo_out=$GOPATH/src/  $goSrc/*.proto
rm -rf $(find * -name '*.proto' | grep -v 'vendor/')
)

echo "Fixing imports on generated files"
(
cd $goSrc
find . -name '*.go' -exec sed -i '' -E 's|github.com/gogo/protobuf|github.schq.secious.com/DataIndexer/GoGoProtobuf|g' {} \;
)

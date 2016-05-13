#!/bin/bash
set -e

os=`uname`
if [ "$os" != "Linux" ] 
then
   echo "You must run this command on a Centos 7 machine"
   exit 1
fi

command -v protoc > /dev/null 2>&1 || { echo "protoc is not installed, or in the PATH"; exit 1; }

expectedProtoCVersion="libprotoc 2.6.1"
actualProtoCVersion=`protoc --version` 
if [ "$actualProtoCVersion" != "$expectedProtoCVersion" ]; then
   echo "Expected protoc version: $expectedProtoCVersion"
   echo "Actual protoc version: $actualProtoCVersion"
   echo "You must use the install the expected version to continue"
   exit 1
fi

if [ -z "$GOPATH" ]; then export GOPATH=~/go; fi
if [ -z "$GOBIN" ]; then export GOBIN=$GOPATH/bin; fi
if [ -z "$GOROOT" ]; then export GOROOT=/usr/local/go; fi
startDir=`pwd`
goSrc=$GOPATH/src/github.schq.secious.com/Logrhythm/GoMessaging
goLR=$GOPATH/src/github.schq.secious.com/Logrhythm
goDX=$GOPATH/src/github.schq.secious.com/DataIndexer
gogoprotobuf=$GOPATH/src/github.com/gogo/protobuf
protoFileDir="$startDir"/protofiles
scriptsDir="$startDir"/scripts
thirdPartyDir="$startDir"/thirdParty

# Use git clone instead of go get because:
#  go get uses https, and github.schq repos refuse the connection; and
#  we need to clone a specific version
if [ ! -d $goLR/rewriteProto ]; then
  echo "Cloning http://github.schq.secious.com/Logrhythm/rewriteProto.git"
  git clone http://github.schq.secious.com/Logrhythm/rewriteProto.git $goLR/rewriteProto
fi
gogoHash="c3995ae437bb78d1189f4f147dfe5f87ad3596e4"
if [ ! -d $gogoprotobuf ]
then
  echo "Cloning https://github.com/gogo/protobuf.git"
  git clone https://github.com/gogo/protobuf.git $gogoprotobuf
fi
echo "Checking out specific commit of gogo protobuf"
(cd $gogoprotobuf; git checkout $gogoHash)

echo "Running 'go install' on dependencies this script requires"
go install github.schq.secious.com/Logrhythm/rewriteProto/./...
go install github.com/gogo/protobuf/./...

mkdir -p $goSrc # Guaranteeing GoMessaging is a real directory

echo "Removing pre-existing .proto files in $goSrc"
(
cd $goSrc;
find . -name '*.proto' -not -name vendor -not -path "./vendor/*" -not -name .git -not -path "./.git/*" -exec rm -rf {} \;
)

# rewriteProto process proto files for use with gogoprotobuf and deposits the result in $goSrc
# which are then compiled into .pb.go files by protoc, etc below
echo "Processing .proto files from Protobuffers repo into GoMessaging to add gogoprotobuf extensions"
(cd "$protoFileDir"; rewriteProto -conf $goLR/rewriteProto/c.yml . $goSrc/)

echo "Running Protoc"
(
cd $goSrc;
find . -type d -not -name vendor -not -path "./vendor/*" -not -name .git -not -path "./.git/*" -exec /bin/sh -c "protoc -I=$GOPATH/src/:$thirdPartyDir/dist/protobuf/include:/usr/local/include:/usr/include:$goSrc --gogo_out=$GOPATH/src/  $goSrc/{}/*.proto 2>&1 | grep -v 'WARNING: failed finding publicly'" \;
)

echo "Removing all re-written protos"
(
cd $goSrc;
find . -name '*.proto' -not -name vendor -not -path "./vendor/*" -not -name .git -not -path "./.git/*" -exec rm -rf {} \;
)

echo "Running go tests"
(
cd $goSrc;
go test --timeout=5m $(go list github.schq.secious.com/Logrhythm/$(basename $(pwd))/./... | grep -v vendor)
)


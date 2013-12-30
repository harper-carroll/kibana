if [ $ID -ne 0 ]
  then
  SUDO=sudo
else
  SUDO=
fi

#install php protobuffers
echo "Installing php protobuffers...";
MODULE=pear.pollinimini.net
eval $SUDO /usr/local/probe/bin/pear channel-update $MODULE
retCode=$?
#if it's not installed try and install it
if [ $retCode -ne 0 ]
  then
  set -e
  eval $SUDO /usr/local/probe/bin/pear channel-discover $MODULE
  eval $SUDO /usr/local/probe/bin/pear install drslump/Protobuf-beta
fi
set +e
eval $SUDO /usr/local/probe/bin/pear install drslump/Protobuf-beta
retCode=$?
if [ $retCode -ne 1 ]
  then
  echo "Returncode from install: " $retCode
  exit
fi

set -e


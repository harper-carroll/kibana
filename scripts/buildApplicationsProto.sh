#!/bin/sh
cat resources/Applications.protoheader
sed -ie 's/, //g' resources/Qosmos_Protocols.csv
perl scripts/buildApplicationsProto.pl resources/Qosmos_Protocols.csv protofiles/Applications.proto.orig resources/ProtocolFilters  | sort -nk 5
cat resources/Applications.protofooter

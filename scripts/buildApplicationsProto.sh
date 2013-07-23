#!/bin/sh
cat resources/Applications.protoheader
sed -e 's/, / /g' resources/Qosmos_Protocols.csv > resources/Qosmos_Protocols.csv.tmp
perl scripts/buildApplicationsProto.pl resources/Qosmos_Protocols.csv.tmp protofiles/Applications.proto.orig resources/ProtocolFilters  | sort -nk 5
rm  resources/Qosmos_Protocols.csv.tmp
cat resources/Applications.protofooter

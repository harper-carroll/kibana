#!/bin/sh
cat resources/Applications.protoheader
perl scripts/buildApplicationsProto.pl resources/Qosmos_Protobook.csv protofiles/Applications.proto.orig resources/ProtocolFilters  | sort -nk 5
cat resources/Applications.protofooter

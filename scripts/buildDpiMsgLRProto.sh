#!/bin/sh
cat resources/DpiMsgLRproto.protoheader
perl scripts/buildDpiMsgLRProto.pl resources/Qosmos_Protobook.csv protofiles/DpiMsgLRproto.proto.orig resources/ProtocolFilters resources/ProtocolDescriptions.csv | sort -nk 5
cat resources/DpiMsgLRproto.protofooter

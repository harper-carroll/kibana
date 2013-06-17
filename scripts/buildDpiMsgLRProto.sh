#!/bin/sh
cat resources/DpiMsgLRproto.protoheader
perl scripts/buildDpiMsgLRProto.pl resources/Qosmos_Protobook.csv protofiles/DpiMsgLRproto.proto.orig resources/ProtocolFilters
cat resources/DpiMsgLRproto.protofooter

#!/bin/sh
set -e
TMPFILE=/tmp/buildDpiMsgLRProto.$BASHPID
TMPFILE2=/tmp/buildDpiMsgLRProto2.$BASHPID

cat resources/DpiMsgLRproto.protoheader > $TMPFILE
perl scripts/buildDpiMsgLRProto.pl resources/Qosmos_Protobook.csv protofiles/DpiMsgLRproto.proto.orig resources/ProtocolFilters resources/LuaProtoFieldsDesc.csv resources/remapping cpp/source/liblrdpi/remapping.ipp resources/NetMonFieldNames.csv $TMPFILE2
# Sort the DPI Message contents by the enumeration ID (field 5)
sort -nk 5 $TMPFILE2 >> $TMPFILE
cat resources/DpiMsgLRproto.protofooter >> $TMPFILE

cat $TMPFILE
rm $TMPFILE
rm $TMPFILE2

#!/bin/sh
cat resources/DpiMsgLRproto.protoheader
perl scripts/buildDpiMsgLRProto.pl resources/Qosmos_Protobook.csv protofiles/DpiMsgLRproto.proto.orig resources/ProtocolFilters
#grep "string\|uint32\|uint64\|timeval\|,ip_addr,\|,mac_addr" resources/Qosmos_Protobook.csv \
# | grep -v string_ | grep -v NA,NA | grep -v "Q_IP_SRC_ADDR32"\
# | grep -v buffer | grep -v binary | grep "Q_" | grep -v ",,,,," \
# | grep -v "Q_IP_DST_ADDR32" | grep -v "Q_BASE_DELAY"\
# | grep -v "Q_IP_SRC_ADDR,\|Q_IP_DST_ADDR," | grep -v "Q_ETH_DST,\|Q_ETH_SRC," \
# | grep -v "Q_BASE_UTIME" | grep -v "Q_BASE_JITTER" \
# | grep -v "Q_BASE_SESSION_LEN" | grep -v "Q_MPA_CONTENT," \
# |  awk -F, ' BEGIN { sum = 18 } {sum+=1}  {if ($9 == "timeval") print "optional string "$8$2" = "sum"; // QOSMOS:"$2","$7",timeval,timevalToString"; else if ($9=="ip_addr") print "optional string "$8$2" = "sum"; // QOSMOS:"$2","$7",uint32,ip_addrToString"; else if ($9 == "mac_addr") print "optional string "$8$2" = "sum"; // QOSMOS:"$2","$7",clep_mac_addr_t,mac_addrToString" ;else print "optional "$9" "$8$2" = "sum"; // QOSMOS:"$2","$7 }'
cat resources/DpiMsgLRproto.protofooter

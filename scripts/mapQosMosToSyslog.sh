#!/bin/sh
# arg1: CSV file from labs, arg2: header file with qosmos, syslog unordered map.
perl mapQosMosToSyslog.pl resources/QosmosSyslogMapping.csv cpp/source/liblrdpi/qosmosSyslogMap.hh

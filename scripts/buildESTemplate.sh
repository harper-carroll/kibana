#!/bin/sh

ES_TEMPLATE=resources/network.json
EVENTS_TEMPLATE=resources/events.json
NETWORKRULES_TEMPLATE=resources/networkrules.json

cat resources/elasticsearch_network_template_header.json > $ES_TEMPLATE
perl scripts/buildESTemplate.pl protofiles/DpiMsgLRproto.proto resources/remapping >> $ES_TEMPLATE
cat resources/elasticsearch_network_template_footer.json >> $ES_TEMPLATE

cat resources/elasticsearch_events_template_header.json > $EVENTS_TEMPLATE
perl scripts/buildESTemplate.pl protofiles/DpiMsgLRproto.proto resources/remapping events >> $EVENTS_TEMPLATE
cat resources/elasticsearch_events_template_footer.json >> $EVENTS_TEMPLATE

cat resources/elasticsearch_networkrules_template_header.json > $NETWORKRULES_TEMPLATE
perl scripts/buildESTemplate.pl protofiles/DpiMsgLRproto.proto resources/remapping rules>> $NETWORKRULES_TEMPLATE
cat resources/elasticsearch_networkrules_template_footer.json >> $NETWORKRULES_TEMPLATE

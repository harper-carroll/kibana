#!/bin/sh

ES_TEMPLATE=resources/network.json
EVENTS_TEMPLATE=resources/events.json

cat resources/elasticsearch_network_template_header.json > $ES_TEMPLATE
perl scripts/buildESTemplate.pl protofiles/DpiMsgLRproto.proto resources/remapping >> $ES_TEMPLATE
cat resources/elasticsearch_network_template_footer.json >> $ES_TEMPLATE

cat resources/elasticsearch_events_template_header.json > $EVENTS_TEMPLATE
perl scripts/buildESEventsTemplate.pl protofiles/DpiMsgLRproto.proto resources/remapping >> $EVENTS_TEMPLATE
cat resources/elasticsearch_events_template_footer.json >> $EVENTS_TEMPLATE

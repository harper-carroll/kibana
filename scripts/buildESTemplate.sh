#!/bin/sh

ES_TEMPLATE=resources/network.json

cat resources/elasticsearch_network_template_header.json > $ES_TEMPLATE
perl scripts/buildESTemplate.pl protofiles/DpiMsgLRproto.proto resources/remapping >> $ES_TEMPLATE
cat resources/elasticsearch_network_template_footer.json >> $ES_TEMPLATE


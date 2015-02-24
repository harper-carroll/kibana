#!/bin/sh
grep string protofiles/Applications.proto | awk '{print $3","$5","substr($0,index($0,$8))}'  | tr -d ']' | tr -d ';'

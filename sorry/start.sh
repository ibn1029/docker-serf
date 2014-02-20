#!/bin/bash
#set -e
#set -x

service sshd start
service snmpd start
service td-agent start
serf agent -tag role=sorry -join=$NGINX_IP &

/usr/sbin/nginx

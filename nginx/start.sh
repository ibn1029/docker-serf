#!/bin/bash
#set -e
#set -x

service sshd start
service snmpd start
service td-agent start
serf agent -tag role=nginx -event-handler member-join,member-leave,member-failed=/root/handler.pl &

/usr/sbin/nginx

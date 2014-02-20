#!/bin/bash
#set -e
#set -x

service sshd start
service snmpd start
service td-agent start
serf agent -tag role=app -join=$NGINX_IP &

sed -ri "s/_NODE_/$NODE/" /opt/my_app/public/index.html

cd /opt/my_app
carton exec \
    start_server \
    --port=5000 \
    -- \
    plackup \
    -s Starlet \
    --workers 5 \
    -a script/my_app \
    --access-log=log/access_log

# Docker, Serf, Nginx and my app

docker + serf + nginx + mojolicious構成でnginxでのproxy,load balanceを自動認識させる構成のメモ

各コンテナはssh, snmp, fluentd有効にしている。

## docker build

    docker build -rm -t username/nginx:0.01 nginx
    docker build -rm -t username/my_app:0.01 my_app
    docker images
    ----
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    username/nginx       0.01                b02831653757        43 minutes ago      1.657 GB
    username/my_app      0.01                82bd8b74e7b8        6 minutes ago       1.71 GB
    ----

## docker run

    docker run -name nginx01 -h nginx01 -d -p 22/tcp -p 161/udp -p 80:80/tcp username/nginx:0.01
    docker ps
    ----
    CONTAINER ID        IMAGE                 COMMAND                CREATED              STATUS              PORTS                                                                             NAMES
    e3fff903695c        username/nginx:0.01   /root/start.sh      3 seconds ago       Up 3 seconds        0.0.0.0:49161->161/udp, 0.0.0.0:49161->22/tcp, 0.0.0.0:80->80/tcp, 7964/tcp, 7964/udp   nginx01          
    ----

    NGINX_IP=$(docker inspect nginx01 | jq -r '.[0].NetworkSettings.IPAddress')

`NGINX_IP` is serf join target. require `jq`.

    NODE=my_app01 && docker run -name $NODE -h $NODE -d -p 22/tcp -p 161/udp -e "NGINX_IP=$NGINX_IP" -e "NODE=$NODE" username/my_app:0.01
    NODE=my_app02 && docker run -name $NODE -h $NODE -d -p 22/tcp -p 161/udp -e "NGINX_IP=$NGINX_IP" -e "NODE=$NODE" username/my_app:0.01
    docker ps
    ----
    CONTAINER ID        IMAGE                 COMMAND             CREATED             STATUS              PORTS                                                                                   NAMES
    fc8b352a8bc7        username/my_app:0.01   /root/start.sh      3 seconds ago       Up 2 seconds        0.0.0.0:49163->161/udp, 0.0.0.0:49163->22/tcp, 5000/tcp, 7964/tcp, 7964/udp             my_app02        
    2700e5cb1719        username/my_app:0.01   /root/start.sh      9 seconds ago       Up 8 seconds        0.0.0.0:49162->161/udp, 0.0.0.0:49162->22/tcp, 5000/tcp, 7964/tcp, 7964/udp             my_app01        
    e3fff903695c        username/nginx:0.01    /root/start.sh      46 seconds ago      Up 45 seconds       0.0.0.0:49161->161/udp, 0.0.0.0:49161->22/tcp, 0.0.0.0:80->80/tcp, 7964/tcp, 7964/udp   nginx01         
    ----

## serf

`startup.sh` of nginx container run the following command.

    serf agent -tag role=nginx -event-handler member-join,member-leave,member-failed=/root/handler.pl &

`startup.sh` of my_app container run the following command.

    serf agent -tag role=app -join=$NGINX_IP &

    sed -ri "s/_NODE_/$NODE/" /opt/my_app/public/index.html


## ssh to container

    ssh username@localhost -p `docker port my_app01 22 | cut -d : -f 2`

`my_app01` is named container.


### remove all images

    docker rmi `docker images -a -q`

### remove all conainers

    docker rm `docker ps -a -q`


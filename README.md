# Docker

## build container


    docker build -t username/my_app:0.01 .
    docker images
    ----
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    username/my_app      0.01                82bd8b74e7b8        6 minutes ago       1.71 GB
    ----

## run container

    docker run -d -name my_app01 -h my_app01 -p 22/tcp -p 161/udp -p 5000/tcp username/my_app:0.01
    docker ps
    ----
    CONTAINER ID        IMAGE                 COMMAND                CREATED              STATUS              PORTS                                                                             NAMES
    8023f038d546        username/my_app:0.01   /opt/my_app/script/s   About a minute ago   Up About a minute   0.0.0.0:49154->161/udp, 0.0.0.0:49208->22/tcp, 0.0.0.0:49209->5000/tcp, 161/tcp   my_app01
    ----

## ssh to container

    ssh username@localhost -p `docker port my_app01 22 | cut -d : -f 2`

`my_app01` is named container.

### remove all images

    docker rmi `docker images -a -q`

### remove all conainers

    docker rm `docker ps -a -q`


# Docker and Serf

## run container and join serf cluster

    docker run -name nginx01 -h nginx01 -d -p 22/tcp -p 161/udp -p 80:80/tcp username/nginx:0.01
    NGINX_IP=$(docker inspect nginx01 | jq '.[0].NetworkSettings.IPAddress' | cut -d '"' -f 2)
    docker run -name my_app01 -h my_app01 -d -p 22/tcp -p 161/udp -e="NGINX_IP=$NGINX_IP" username/my_app:0.01

`NGINX_IP` is serf join target. require `jq`.

startup.sh of my_app container run the following command.

    serf agent -tag=my_app -join=$NGINX_IP &



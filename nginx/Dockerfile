# Refs.
# http://valencia.hatenablog.com/entry/2014/01/22/200755
# http://shibayu36.hatenablog.com/entry/2013/12/23/153019

FROM centos:6.4

#### Install base packages
RUN yum groupinstall -y Base
RUN yum groupinstall -y 'Development Tools'
RUN yum groupinstall -y 'SNMP Support'
RUN yum install -y sudo
RUN yum install -y openssh openssh-server openssh-clients

#### Configure timezone
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

#### Initialize sshd
RUN /etc/init.d/sshd start
RUN /etc/init.d/sshd stop
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

#### Install serf
RUN curl -L -O https://dl.bintray.com/mitchellh/serf/0.4.1_linux_amd64.zip
RUN unzip 0.4.1_linux_amd64.zip -d /usr/bin/
RUN rm -f 0.4.1_linux_amd64.zip
ADD serf/handler.pl /root/handler.pl

#### Install nginx
RUN rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
RUN yum install -y nginx
RUN echo 'daemon off;' >> /etc/nginx/nginx.conf
ADD nginx/my_app.conf /etc/nginx/conf.d/
ADD nginx/my_app_backends.conf /etc/nginx/conf.d/

#### Install fluentd
# http://docs.fluentd.org/articles/install-by-rpm 
# The following script is being edited for the execution of the root
ADD fluentd/install-redhat.sh /tmp/install-redhat.sh
RUN bash /tmp/install-redhat.sh

#### Add users
RUN useradd akimoto && echo 'akimoto:akimoto00' | /usr/sbin/chpasswd

#### Configure sudoers
RUN echo "akimoto ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/akimoto

EXPOSE 22/tcp
EXPOSE 161/udp
EXPOSE 7964/tcp 7964/udp
EXPOSE 80/tcp

ADD start.sh /root/start.sh
CMD ["/root/start.sh"]


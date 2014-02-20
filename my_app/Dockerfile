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

#### Install perl and carton
RUN wget -O /tmp/perl-install https://raw.github.com/tatsuru/xbuild/master/perl-install
RUN bash /tmp/perl-install 5.14.4 /opt/perl
ENV PATH /opt/perl/bin:/usr/sbin:/sbin:/usr/bin:/bin
RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm Carton 

#### Install fluentd
# http://docs.fluentd.org/articles/install-by-rpm 
# The following script is being edited for the execution of the root
ADD fluentd/install-redhat.sh /tmp/
RUN bash /tmp/install-redhat.sh
RUN rm -f /etc/td-agent/td-agent.conf
ADD fluentd/td-agent.conf /etc/td-agent/
RUN install -o td-agent -m 775 -d /var/log/td-agent/tmp

#### Configure application and modules
RUN mkdir /opt/my_app
ADD my_app /opt/my_app
RUN rm -rf /opt/my_app/local
RUN cd /opt/my_app && carton install --cached

#### Add users
RUN useradd akimoto && echo 'akimoto:akimoto00' | /usr/sbin/chpasswd

#### Configure sudoers
RUN echo "akimoto ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/akimoto


EXPOSE 22/tcp
EXPOSE 161/udp
# serf
EXPOSE 7964/tcp 7964/udp
# app
EXPOSE 5000/tcp

ADD start.sh /root/start.sh
CMD ["/root/start.sh"]


FROM centos:7 
MAINTAINER Lawrence Stubbs <technoexpressnet@gmail.com>

# Install Required Dependencies    
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
	&& yum update -y \
	&& yum -y install perl iptables-utils iptables-services cronie wget sysvinit-tools initscripts
    
# Install Shorewall and the fail2ban action 
RUN yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall-core-5.1.9-0base.noarch.rpm -y \
    && yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall-5.1.9-0base.noarch.rpm -y \
    && yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall-init-5.1.9-0base.noarch.rpm -y \
    && yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall6-5.1.9-0base.noarch.rpm -y 
	
COPY etc /etc/
# Fixes issue with running systemD inside docker builds 
# From https://github.com/gdraheim/docker-systemctl-replacement
COPY systemctl.py /usr/bin/systemctl.py
RUN cp -f /usr/bin/systemctl /usr/bin/systemctl.original \
    && chmod +x /usr/bin/systemctl.py \
    && cp -f /usr/bin/systemctl.py /usr/bin/systemctl
  
# Install Webmin repositorie and Webmin
RUN wget http://www.webmin.com/jcameron-key.asc -q && rpm --import jcameron-key.asc \
    && yum install webmin -y && rm jcameron-key.asc
 
RUN yum install yum-versionlock -y && yum versionlock systemd 
    
RUN systemctl.original disable dbus \
    && (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    rm -f /etc/dbus-1/system.d/*; \
    rm -f /etc/systemd/system/sockets.target.wants/*; 
    
RUN sed -i "s#10000#19999#" /etc/webmin/miniserv.conf \
    && sed -i "s#9000,#19999,#" /etc/shorewall/rules \
    && sed -i "s#STARTUP_ENABLED=No#STARTUP_ENABLED=Yes#" /etc/shorewall/shorewall.conf \
    && sed -i "s#DOCKER=No#DOCKER=Yes#" /etc/shorewall/shorewall.conf \
	&& systemctl.original disable shorewall6.service \
	&& systemctl.original enable shorewall.service crond.service webmin.service containerstartup.service \
    && chmod +x /etc/containerstartup.sh \
    && mv -f /etc/containerstartup.sh /containerstartup.sh \
    && echo "root:shorewall" | chpasswd
  
ENV container docker
ENV WEBMINPORT 19999

EXPOSE 19999/tcp 19999/udp

#ENTRYPOINT ["/usr/sbin/init"]
#ENTRYPOINT ["/usr/bin/systemctl.original"]
CMD ["/usr/bin/systemctl","default","--init"]
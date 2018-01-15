#!/bin/bash
export WEBMINPORT

if [ -f "/etc/letsencrypt/archive/$HOSTNAME/cert1.pem" ]
then
    ln -sf "/etc/letsencrypt/archive/$HOSTNAME/cert1.pem" /etc/pki/tls/certs/localhost.crt
    ln -sf "/etc/letsencrypt/archive/$HOSTNAME/privkey1.pem" /etc/pki/tls/private/localhost.key
	cat "/etc/letsencrypt/archive/$HOSTNAME/privkey1.pem" "/etc/letsencrypt/archive/$HOSTNAME/cert1.pem" > /etc/webmin/miniserv.pem
fi

if [ ! -f /var/log/fail2ban.log ] || [ ! -f /var/log/secure ] || [ ! -f /var/log/auth.log ]
then
    mkdir -p /var/log/asterisk
    mkdir -p /var/log/httpd
    mkdir -p /var/log/nginx
    mkdir -p /var/log/horde
    mkdir -p /var/log/sogo
    mkdir -p /var/log/squid
    mkdir -p /var/log/named
    mkdir -p /var/log/freeswitch
    mkdir -p /var/log/stunnel4
    mkdir -p /var/log/ejabberd
    mkdir -p /var/log/directadmin
    touch /var/log/asterisk/full /var/log/secure /var/log/auth.log /var/log/maillog /var/log/httpd/access_log /var/log/httpd/error_log /var/log/fail2ban.log /var/log/nginx/access*.log /var/log/openwebmail.log /var/log/horde/horde.log /var/log/sogo/sogo.log /var/log/monit /var/log/squid/access.log /var/log/3proxy.log /var/log/named/security.log /var/log/nsd.log /var/log/freeswitch/freeswitch.log /var/log/stunnel4/stunnel.log /var/log/ejabberd/ejabberd.log /var/log/directadmin/login.log /var/log/mysqld.log   
    service fail2ban restart
fi

source <( grep listen /etc/webmin/miniserv.conf ) 
if [[ $WEBMINPORT =~ ^[0-9]+$ ]] && [ "$WEBMINPORT" != "$listen" ]
then  
	if pgrep -x "miniserv.pl" > /dev/null
	then 
		systemctl stop webmin
	fi
	sed -i "s#$listen#$WEBMINPORT#" /etc/webmin/miniserv.conf
    sed -i "s#$listen#$WEBMINPORT#" /etc/fail2ban/jail.local
    systemctl start webmin
    service fail2ban restart
fi

if ! pgrep -x "sendmail" > /dev/null
then
    service sendmail start
fi  

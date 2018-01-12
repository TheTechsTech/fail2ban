#!/bin/bash
export WEBMINPORT

if [ -f "/etc/letsencrypt/archive/$HOSTNAME/cert1.pem" ]
then
    ln -sf "/etc/letsencrypt/archive/$HOSTNAME/cert1.pem" /etc/pki/tls/certs/localhost.crt
    ln -sf "/etc/letsencrypt/archive/$HOSTNAME/privkey1.pem" /etc/pki/tls/private/localhost.key
	cat "/etc/letsencrypt/archive/$HOSTNAME/privkey1.pem" "/etc/letsencrypt/archive/$HOSTNAME/cert1.pem" > /etc/webmin/miniserv.pem
fi

source <( grep listen /etc/webmin/miniserv.conf ) 
if [[ $WEBMINPORT =~ ^[0-9]+$ ]] && [ "$WEBMINPORT" != "$listen" ]
then  
	if pgrep -x "miniserv.pl" > /dev/null
	then 
		systemctl stop webmin
		sed -i "s#$listen#$WEBMINPORT#" /etc/webmin/miniserv.conf
		systemctl start webmin
	else
		sed -i "s#$listen#$WEBMINPORT#" /etc/webmin/miniserv.conf
	fi
fi

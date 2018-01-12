# fail2ban & shorewall for Docker

Fail2Ban for docker environment. 
Just mounting `-v /var/log:/var/log` in all `docker run` containers can protect your expose ports from abuse.

This build has Webmin http://www.webmin.com/ installed to easy update underlining image and manage fail2ban. 
It can be disable by passing `–e WEBMINPORT=off`

### Usage
To run it:
```
$ docker run --name fail2ban \
-v /var/log:/var/log \
--net=host --restart=always \
--cap-add=NET_ADMIN \
--hostname=server.fail2ban.host \
-e WEBMINPORT=19999 \
-d technoexpressnet/fail2ban
```

This build also assume reverse proxy is setup. 
This build setup to use https://github.com/adi90x/rancher-active-proxy
```
-v /nginx/rancher-active-proxy/letsencrypt/archive/server.fail2ban.host:/etc/letsencrypt/archive/server.fail2ban.host \
-l rap.host=server.fail2ban.host \
-l rap.le_host=server.fail2ban.host \
-l rap.https_method=noredirect \
```

### Docker Hub
https://hub.docker.com/r/technoexpress/fail2ban/builds/ automatically builds the latest changes into images which can easily be pulled and ran with a simple `docker run` command. 

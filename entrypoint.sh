#!/bin/sh
set -e
if [ !${GITHUB_USER} ]; then
    GITHUB_USER=tukiyo
fi

adduser -D -s /bin/ash ${GITHUB_USER}
passwd -u ${GITHUB_USER}
addgroup ${GITHUB_USER} wheel
mkdir -p /home/${GITHUB_USER}/.ssh/
wget -q -O /home/${GITHUB_USER}/.ssh/authorized_keys https://github.com/${GITHUB_USER}.keys
chown -R ${GITHUB_USER}:${GITHUB_USER} /home/${GITHUB_USER}

if [ !${PROXY_PASS} ]; then
    PROXY_PASS="http://walt.mydns.bz:10022/"
fi

#-------------------------------------------
cat << EOF > /etc/nginx/conf.d/default.conf
	server {
		listen 80 default_server;
		location / {
			proxy_pass ${PROXY_PASS};
		}
	}
	proxy_set_header Host $http_host;
	proxy_set_header X-Real-IP $remote_addr;
	proxy_set_header X-Forwarded-Proto $scheme;
	proxy_set_header X-Forwarded-Host $http_host;
	proxy_set_header X-Forwarded-Server $host;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
EOF
#-------------------------------------------

/usr/sbin/nginx
/usr/sbin/sshd -D

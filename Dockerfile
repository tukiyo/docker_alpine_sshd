FROM alpine:latest
MAINTAINER tukiyo3@gmail.com
ENV GITHUB_USER="tukiyo" \
    PROXY_PASS="http://walt.mydns.bz:10022/"
EXPOSE 80 22
RUN set -x \
    && apk update && apk add --update --no-cache ca-certificates nginx openssh screen sudo\
    && sed -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' -i /etc/sudoers \
    && passwd -d root \
    && adduser -D -s /bin/ash ${GITHUB_USER} \
    && passwd -u ${GITHUB_USER} \
    && addgroup ${GITHUB_USER} wheel \
    && mkdir -p /home/${GITHUB_USER}/.ssh/ \
    && wget -q -O /home/${GITHUB_USER}/.ssh/authorized_keys https://github.com/${GITHUB_USER}.keys \
    && chown -R ${GITHUB_USER}:${GITHUB_USER} /home/${GITHUB_USER} \
    && ssh-keygen -A \
    && mkdir -p /run/nginx \
    && sed -i 's|\treturn 404|\tproxy_pass '${PROXY_PASS}'|g' /etc/nginx/conf.d/default.conf \
    && update-ca-certificates
# COPY entrypoint.sh /
CMD /usr/sbin/nginx && /usr/sbin/sshd -D
# ENTRYPOINT /entrypoint.sh

FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive
ARG USER_NAME=docker_postfix
ARG TZ=Etc/UTC

RUN apt-get -y update
RUN apt-get -y install supervisor postfix sasl2-bin opendkim opendkim-tools rsyslog tzdata mail-stack-delivery dovecot-imapd dovecot-pop3d

RUN mkdir -p /etc/supervisor/conf.d/supervisord.conf
COPY supervisor/supervisord.conf /etc/supervisor/conf.d

COPY dovecot/dovecot.conf /etc/dovecot
COPY dovecot/conf.d /etc/dovecot/conf.d

RUN echo ${TZ} > /etc/timezone && \
	rm /etc/localtime && \
	ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
	dpkg-reconfigure -f noninteractive tzdata

RUN adduser --disabled-password --gecos '' ${USER_NAME}
RUN	echo "/.*/ ${USER_NAME}" >> /etc/postfix/virtual_address && \
	echo "/.*/ ${USER_NAME}" >> /etc/postfix/virtual_domains

RUN	postmap /etc/postfix/virtual_address && \
	postmap /etc/postfix/virtual_domains && \
	postconf -F '*/*/chroot = n' && \
	postconf -e broken_sasl_auth_clients=no && \
	postconf -e smtpd_recipient_restrictions=permit_mynetworks,defer_unauth_destination && \
	postconf -e debug_peer_list=127.0.0.1 && \
	postconf -e home_mailbox=Maildir/ && \
	postconf -e mynetworks=127.0.0.0/8 && \
	postconf -e smtpd_relay_restrictions=permit_mynetworks,defer_unauth_destination && \
	postconf -e relayhost=localhost && \
	postconf -e smtpd_sasl_auth_enable=no && \
	postconf -e luser_relay=${USER_NAME} && \
	postconf -e mydestination=regexp:/etc/postfix/virtual_domains && \
	postconf -e virtual_alias_maps=regexp:/etc/postfix/virtual_address && \
	echo "${USER_NAME}:{PLAIN}${USER_NAME}:$(id -u ${USER_NAME}):$(id -g ${USER_NAME})::/home/${USER_NAME}::" >> /etc/dovecot/users

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh
CMD ["/entrypoint.sh"]

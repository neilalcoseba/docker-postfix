FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive
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

RUN	postconf -F '*/*/chroot = n' && \
	postconf -e broken_sasl_auth_clients=no && \
	postconf -e smtpd_recipient_restrictions=permit_mynetworks,defer_unauth_destination && \
	postconf -e debug_peer_list=127.0.0.1 && \
	postconf -e home_mailbox=Maildir/ && \
	postconf -e mynetworks=127.0.0.0/8 && \
	postconf -e smtpd_relay_restrictions=permit_mynetworks,defer_unauth_destination && \
	postconf -e relayhost=localhost && \
	postconf -e smtpd_sasl_auth_enable=no

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh
CMD ["/entrypoint.sh"]

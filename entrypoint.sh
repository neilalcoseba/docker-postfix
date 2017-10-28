#!/bin/bash

postconf -e myhostname=$HOSTNAME
postconf -e mydomain=$HOSTNAME
postconf -e relay_domains=$mydomain

if [ -z "$USER_NAME" ]
then
	USER_NAME="docker"
fi

adduser --disabled-password --home /home/docker --gecos '' $USER_NAME
echo "/.*/ $USER_NAME" >> /etc/postfix/virtual_address
echo "/.*/ $USER_NAME" >> /etc/postfix/virtual_domains

postmap /etc/postfix/virtual_address
postmap /etc/postfix/virtual_domains
postconf -e mydestination=regexp:/etc/postfix/virtual_domains
postconf -e virtual_alias_maps=regexp:/etc/postfix/virtual_address

echo "$USER_NAME:{PLAIN}$USER_NAME:$(id -u $USER_NAME):$(id -g $USER_NAME)::/home/docker::" >> /etc/dovecot/users

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

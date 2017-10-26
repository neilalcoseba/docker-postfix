#!/bin/bash

postconf -e myhostname=$HOSTNAME
postconf -e mydomain=$HOSTNAME
postconf -e relay_domains=$mydomain

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

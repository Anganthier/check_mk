#!/bin/bash

# Create SSMTP config
CFGFILE=/etc/ssmtp/ssmtp.conf

cat >$CFGFILE <<CONFIG
root=root
mailhub=${MAILHUB}
FromLineOverride=YES
CONFIG

chmod 640 $CFGFILE
chown root:mail $CFGFILE


# Start cron daemon
/usr/sbin/crond

# Check omd created
if [ ! -d "/omd/sites/${CMK_SITE}/etc" ]; then
  # Control will enter here if $DIRECTORY doesn't exist.
    omd init ${CMK_SITE} || \
    omd config ${CMK_SITE} set DEFAULT_GUI check_mk && \
    omd config ${CMK_SITE} set TMPFS off && \
    omd config ${CMK_SITE} set CRONTAB on && \
    omd config ${CMK_SITE} set APACHE_TCP_ADDR 0.0.0.0 && \
    omd config ${CMK_SITE} set APACHE_TCP_PORT 5000 && \
    htpasswd -b -m /omd/sites/${CMK_SITE}/etc/htpasswd cmkadmin omd && \
    ln -s "/omd/sites/${CMK_SITE}/var/log/nagios.log" /var/log/nagios.log && \
    /opt/redirector.sh ${CMK_SITE} > /omd/sites/${CMK_SITE}/var/www/index.html
fi
# Start check_mk
omd start && tail -f /var/log/nagios.log


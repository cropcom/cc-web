#!/bin/bash

printf "\033[1;1m ____   __    ____    __    __    __      __    _  _ 
(  _ \ /__\  (  _ \  /__\  (  )  (  )    /__\  ( \/ )
 )___//(__)\  )   / /(__)\  )(__  )(__  /(__)\  )  ( 
(__) (__)(__)(_)\_)(__)(__)(____)(____)(__)(__)(_/\_)\033[0m\n"

printf "\n\033[1;1mRunning Nginx PHP-FPM worker mode\033[0m\n\n"

# printf "%-30s %-30s\n" "Key" "Value"

# Container info:
printf "%-30s %-30s\n" "Site:" "$SITE_NAME"

# Version numbers:
printf "%-30s %-30s\n" "PHP Version:" "`php -r 'echo phpversion();'`"
printf "%-30s %-30s\n" "Nginx Version:" "`/usr/sbin/nginx -v 2>&1 | sed -e 's/nginx version: nginx\///g'`"

# Print the real value
printf "%-30s %-30s\n" "Opcache Memory Max:" "`php -r 'echo ini_get("opcache.memory_consumption");'`M"

# SYSLOG-NG Enable
# Enable SYSLOG-NG
printf "%-30s %-30s\n" "Syslog-ng" "ENABLED via Supervisord"
cp /etc/supervisor.d/syslog-ng.conf /etc/supervisord-enabled/


# Cron
cp /etc/supervisor.d/cron.conf /etc/supervisord-enabled/


# Download config for webapp
if [ -f /config.sh ]; then
    printf "%-30s %-30s\n" "Web Config Download Script:" "Running"
    chmod +x /config.sh && ./config.sh
fi

# Enable the worker-specific supervisor files
cp /etc/supervisord-worker/* /etc/supervisord-enabled/

printf "\n\033[1;1mStarting supervisord\033[0m\n\n"

# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf

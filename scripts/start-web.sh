#!/bin/bash

printf "\033[1;1m ____   __    ____    __    __    __      __    _  _ 
(  _ \ /__\  (  _ \  /__\  (  )  (  )    /__\  ( \/ )
 )___//(__)\  )   / /(__)\  )(__  )(__  /(__)\  )  ( 
(__) (__)(__)(_)\_)(__)(__)(____)(____)(__)(__)(_/\_)\033[0m\n"

printf "\n\033[1;1mRunning Nginx PHP-FPM web mode\033[0m\n\n"

# printf "%-30s %-30s\n" "Key" "Value"

# Container info:
printf "%-30s %-30s\n" "Site:" "$SITE_NAME"

# Enable Nginx
cp /etc/supervisor.d/nginx.conf /etc/supervisord-enabled/

# Enable PHP-FPM
cp /etc/supervisor.d/php-fpm.conf /etc/supervisord-enabled/

# Version numbers:
printf "%-30s %-30s\n" "PHP Version:" "`php -r 'echo phpversion();'`"
printf "%-30s %-30s\n" "Nginx Version:" "`/usr/sbin/nginx -v 2>&1 | sed -e 's/nginx version: nginx\///g'`"
printf "%-30s %-30s\n" "Nginx Port:" "80"
printf "%-30s %-30s\n" "Nginx Web Root:" "/var/www/src"

# Print the real value
printf "%-30s %-30s\n" "PHP Memory Max:" "`php -r 'echo ini_get("memory_limit");'`"

# Print the real value
printf "%-30s %-30s\n" "Opcache Memory Max:" "`php -r 'echo ini_get("opcache.memory_consumption");'`M"

# Print the value
printf "%-30s %-30s\n" "Nginx Max Read:" "`cat /etc/nginx/sites-enabled/site.conf | grep 'fastcgi_read_timeout' | sed -e 's/fastcgi_read_timeout//g'`"

# Print the value
printf "%-30s %-30s\n" "PHP Max Execution Time:" "`cat /etc/php/php.ini | grep 'max_execution_time = ' | sed -e 's/max_execution_time = //g'`"

# PHP-FPM Max Workers
# If set
if [ ! -z "$PHP_FPM_WORKERS" ]; then
        
    # Set PHP.ini accordingly
    sed -i -e "s#pm.max_children = 4#pm.max_children = $PHP_FPM_WORKERS#g" /etc/php/php-fpm.d/www.conf

fi

# SYSLOG-NG Enable
# If set
if [ ! -z "$LOG_IP" ]; then
    # Replace IP Address of log server and copy config to syslog-ng app
    sed -i -e "s#127.0.0.1#$LOG_IP#g" /syslog-ng.conf



    # If set LOG_PORT
    if [ ! -z "$LOG_PORT" ]; then
        # Replace IP Address of log server and copy config to syslog-ng app
        sed -i -e "s#1514#$LOG_PORT#g" /syslog-ng.conf
        printf "%-30s %-30s\n" "Syslog-ng Remote Sync Status" "(UDP) $LOG_IP : PORT $LOG_PORT"
    fi

    # If not set LOG_PORT
    if [ -z "$LOG_PORT" ]; then
        printf "%-30s %-30s\n" "Syslog-ng Remote Sync Status" "(UDP) $LOG_IP : PORT 1514"
    fi

    # If set LOG_TOKEN
    if [ ! -z "$LOG_TOKEN" ]; then
        # Replace IP Address of log server and copy config to syslog-ng app
        sed -i -e "s#LOG_TOKEN#$LOG_TOKEN#g" /syslog-ng.conf
    fi

    # If not set LOG_TOKEN
    if [ -z "$LOG_TOKEN" ]; then
        printf "%-30s %-30s\n" "Syslog-ng LOG_TOKEN not set can affect the log process"
    fi

    # Copy edited file to config directory
    cp /syslog-ng.conf /etc/syslog-ng/conf.d/
    # Enable SYSLOG-NG
    cp /etc/supervisor.d/syslog-ng.conf /etc/supervisord-enabled/
fi

# If not set LOG_IP
if [ -z "$LOG_IP" ]; then
    printf "%-30s %-30s\n" "Syslog-ng Remote Sync Status" "DISABLED"
fi

# Download config for webapp
if [ -f /config.sh ]; then
    printf "%-30s %-30s\n" "Web Config Download Script:" "Running"
    chmod +x /config.sh && ./config.sh

fi


# Print the value
printf "%-30s %-30s\n" "PHP-FPM Max Workers:" "`cat /etc/php/php-fpm.d/www.conf | grep 'pm.max_children = ' | sed -e 's/pm.max_children = //g'`"
# End PHP-FPM

printf "\n\033[1;1mStarting supervisord\033[0m\n\n"

# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf

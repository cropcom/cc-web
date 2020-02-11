# cc-web
(Based on prlx/prlx-nginx-php-fpm:7.3-master)

> A relatively clean but full-featured, usable nginx and php-fpm docker image supporting PHP versions 7.3 maintained by [Parallax](https://parall.ax/)

# Environment Variables

These containers work with certain environment variables to control their operation. Environment variables marked as required may be omitted and things may seem to work OK but we do not test against omitting these so you may see some pretty interesting behaviour as a result.

Web/Worker just means whether these have any effect - nothing bad will happen if they are set on both.

For help running these locally with docker run see the [docker run reference](https://docs.docker.com/engine/reference/run/#env-environment-variables)

| Key                             | Description                                                                                                     | Required | Web | Worker |
| ---                             | ---                                                                                                             | ---      | --- | ---    |
| SITE_NAME                       | The name of your project, i.e. 'mywebsite'. Used by NR for app name.                                            | ✓        | ✓   | ✓      |
| PHP_FPM_WORKERS                 | Maximum PHP-FPM workers. Defaults to 4 if not set.                                                              | ✖        | ✓   | ✖      |
| LOG_IP                          | IP Address of UDP Log Server (Ignore will not send UDP Log)                                                     | ✖        | ✓   | ✖      |
| LOG_PORT                        | PORT of UDP Log Server (Default is 1514)                                                                        | ✖        | ✓   | ✖      |
| LOG_TOKEN                       | Access Token for access Log Server                                                                              | ✖        | ✓   | ✖      |

# The web mode/command

The web mode is what you use to run a web server - unless you're using workers this is the only one you'll be using. It runs all the things you need to be able to run a PHP-FPM container in Kubernetes.

It is also the default behaviour for the docker containers meaning you don't need to specify a command or working directory to run.

## Ports and Services

Not everything is as straightforward as the idealistic world of Docker would have you believe. The "one process per container" doesn't really work for us in the real world so we've gone with "one logical service per container" instead.

We use [Supervisord](http://supervisord.org/) to bootstrap the following services in our Nginx PHP-FPM web mode container:

| Service                                                                                  | Description                                             | Port/Socket         |
| -------------                                                                            | -------------                                           | -------------       |
| [Nginx](https://www.nginx.com/)                                                          | Web server                                              | 0.0.0.0:80          |
| [PHP-FPM](https://php-fpm.org/)                                                          | PHP running as a pool of workers                        | /run/php.sock       |


# The worker mode/command

The worker mode is used when you want to run a worker-type task in this container. Usually this means something like php artisan queue:work.

To run in this mode, change the Docker CMD to be /start-worker.sh instead of the default /start-web.sh.

You will need to ship your own worker supervisord jobs by adding these to /etc/supervisord-worker/ in your Dockerfile for your worker. Any .conf files in that directory will be picked up by supervisord to run when in worker mode.

An example of one of these files is provided below - feel free to amend as appropriate:

```
[program:laravel-queue]
command=/usr/bin/php artisan queue:listen 
directory=/src
autostart=true
autorestart=true
priority=15
stdout_events_enabled=true
stderr_events_enabled=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
```


# PHP Modules
| Module        | 5.6 | 7.1 | 7.2 |  7.3 |Notes                                                                                   |
| ---           | --- | --- | --- |  --- |---                                                                                     |
| apc           | ✓   | ✖   | ✖   | ✖   | Deprecated in PHP 7 and up                                                              |
| apcu          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| bcmath        | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| calendar      | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| Core          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| ctype         | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| curl          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| date          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| dom           | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| ereg          | ✓   | ✖   | ✖   | ✖   | Deprecated in PHP 7 and up                                                              |
| exif          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| fileinfo      | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| filter        | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| ftp           | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| gd            | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| gettext       | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| hash          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| iconv         | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| imagick       | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| intl          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| json          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| ldap          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| libxml        | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| mbstring      | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| mcrypt        | ✓   | ✓   | ✖   | ✖   | Deprecated in PHP 7.2 and up                                                            |
| memcached     | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| mysqli        | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| mysql         | ✓   | ✖   | ✖   | ✖   | Deprecated in PHP 7 and up                                                              |
| mysqlnd       | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| openssl       | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| pcntl         | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| pcre          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| PDO           | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| pdo_mysql     | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| pdo_sqlite    | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| Phar          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| posix         | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| readline      | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| redis         | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| Reflection    | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| session       | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| SimpleXML     | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| soap          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| sockets       | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| SPL           | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| sqlite3       | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| standard      | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| tidy          | ✖   | ✓   | ✓   | ✓    |Weirdly missing from upstream Alpine Linux repository                                   |
| tokenizer     | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| wddx          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| xml           | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| xmlreader     | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| xmlrpc        | ✓   | ✓   | ✖   | ✖   |[Missing from upstream PHP 7.2](https://github.com/codecasts/php-alpine/issues/23)      |
| xmlwriter     | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| xsl           | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| Zend OPcache  | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| zip           | ✓   | ✓   | ✓   |  ✓   |                                                                                        |
| zlib          | ✓   | ✓   | ✓   |  ✓   |                                                                                        |

# Notes about `syslog-ng`

# Notes about `logrotate`
# shinsenter/php

Docker images for PHP applications, from CLI to standalone web server.

https://hub.docker.com/r/shinsenter/php/

[![Publish Docker (shinsenter/php)](https://github.com/shinsenter/php/actions/workflows/build-production.yml/badge.svg?branch=main)](https://github.com/shinsenter/php/actions/workflows/build-production.yml)
[![Docker Pulls shinsenter/php](https://img.shields.io/docker/pulls/shinsenter/php)](https://hub.docker.com/r/shinsenter/php/)


---


## Support my activities

If you like this repository, please hit the star button to follow further updates, or buy me a coffee 😉.

[![Donate via PayPal](https://img.shields.io/badge/Donate-Paypal-blue)](https://www.paypal.me/shinsenter) [![Become a sponsor](https://img.shields.io/badge/Donate-Patreon-orange)](https://www.patreon.com/appseeds) [![Become a stargazer](https://img.shields.io/badge/Support-Stargazer-yellow)](https://github.com/shinsenter/docker-imgproxy/stargazers) [![Report an issue](https://img.shields.io/badge/Support-Issues-green)](https://github.com/shinsenter/docker-imgproxy/discussions/new)

I really appreciate your love and supports.


---


## Thank you [@serversideup](https://github.com/serversideup)

This project is inspired by the [serversideup/docker-php](https://github.com/serversideup/docker-php) project, I love it. However the owners seem to be quite busy updating their projects, so I created this project.

I thought I could make it more maintainable and stable with the latest middleware.

---


## OS version
- Ubuntu 20.04 (Focal)


## Usage

(I will gradually update the content in this section.)

### PHP version

- 7.4
- 8.0
- 8.1


### Image variations

- `shinsenter/php:${PHP_VERSION}-cli`
- `shinsenter/php:${PHP_VERSION}-fpm`
- `shinsenter/php:${PHP_VERSION}-fpm-apache`
- `shinsenter/php:${PHP_VERSION}-fpm-nginx`

### Create your own Dockerfile

You can continue to install more of your favorite modules from my built-in base images. Create your own Dockerfile. For example:

```Dockerfile
FROM shinsenter/php:8.1-fpm-apache
```

or

```Dockerfile
FROM shinsenter/php:8.1-fpm-nginx
```

---


## ENV variables

You can also customize your Docker container by update these ENV variables.

```Dockerfile
################################################################################

# Control your timezone
ENV TZ="UTC"

################################################################################

# User ID the webserver and PHP should run as
ENV PUID="9999"

# Group ID the webserver and PHP should run as
ENV PGID="9999"

# You can change the home of the web user if needed
ENV WEBHOME="/var/www/html"

################################################################################

# Sets the directory from which Nginx will serve files
ENV NGINX_DOCUMENT_ROOT="$WEBHOME"

################################################################################

# Sets the directory from which Apache will serve files
ENV APACHE_DOCUMENT_ROOT="$WEBHOME"

# Sets the limit on the number of connections
# that an individual child server process will handle
ENV APACHE_MAX_CONNECTIONS_PER_CHILD="0"

# Sets the limit on the number of simultaneous requests that will be served
ENV APACHE_MAX_REQUEST_WORKERS="150"

# Maximum number of idle threads
ENV APACHE_MAX_SPARE_THREADS="75"

# Minimum number of idle threads to handle request spikes
ENV APACHE_MIN_SPARE_THREADS="10"

# Set the username of what Apache should run as
ENV APACHE_RUN_GROUP="webgroup"

# Set the username of what Apache should run as
ENV APACHE_RUN_USER="webuser"

# Sets the number of child server processes created on startup
ENV APACHE_START_SERVERS="2"

# Set the maximum configured value for ThreadsPerChild
# for the lifetime of the Apache httpd process
ENV APACHE_THREAD_LIMIT="64"

# This directive sets the number of threads created by each child process
ENV APACHE_THREADS_PER_CHILD="25"

################################################################################

# Show PHP errors on screen
ENV PHP_DISPLAY_ERRORS="On"

# Set PHP error reporting level
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_WARNING"

# Set the maximum time in seconds a script is allowed
# to run before it is terminated by the parser
ENV PHP_MAX_EXECUTION_TIME="99"

# Set the maximum amount of memory in bytes that a script is allowed to allocate
ENV PHP_MEMORY_LIMIT="256M"

# Choose how the process manager will control the number of child processes
ENV PHP_PM_CONTROL="dynamic"

# The number of child processes to be created when pm is set to static
# and the maximum number of child processes to be created when pm is set to dynamic
ENV PHP_PM_MAX_CHILDREN="20"

# The desired maximum number of idle server processes
ENV PHP_PM_MAX_SPARE_SERVERS="3"

# The desired minimum number of idle server processes
ENV PHP_PM_MIN_SPARE_SERVERS="1"

# The number of child processes created on startup
ENV PHP_PM_START_SERVERS="2"

# Set the name of your PHP-FPM pool
# (helpful when running multiple sites on a single server)
ENV PHP_POOL_NAME="www"

# Sets max size of post data allowed
ENV PHP_POST_MAX_SIZE="100M"

# The maximum size of an uploaded file
ENV PHP_UPLOAD_MAX_FILE_SIZE="100M"

################################################################################

# Server that should relay emails for MSMTP
ENV MSMTP_RELAY_SERVER_HOSTNAME="mailhog"

# Port the SMTP server is listening on
ENV MSMTP_RELAY_SERVER_PORT="1025"

################################################################################
```

* * *

If you like this project, please [support my works](#support-my-activities) 😉.

From Vietnam 🇻🇳 with love.

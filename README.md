# shinsenter/php

Docker images for PHP applications, from CLI to standalone web server.

https://hub.docker.com/r/shinsenter/php/

[![Publish Docker (shinsenter/php)](https://github.com/shinsenter/php/actions/workflows/production.yml/badge.svg?branch=main)](https://github.com/shinsenter/php/actions/workflows/production.yml)
[![Docker Pulls shinsenter/php](https://img.shields.io/docker/pulls/shinsenter/php)](https://hub.docker.com/r/shinsenter/php/)


---


## Support my activities

If you like this repository, please hit the star button to follow further updates, or buy me a coffee 😉.

[![Donate via PayPal](https://img.shields.io/badge/Donate-Paypal-blue)](https://www.paypal.me/shinsenter) [![Become a sponsor](https://img.shields.io/badge/Donate-Patreon-orange)](https://www.patreon.com/appseeds) [![Become a stargazer](https://img.shields.io/badge/Support-Stargazer-yellow)](https://github.com/shinsenter/docker-imgproxy/stargazers) [![Report an issue](https://img.shields.io/badge/Support-Issues-green)](https://github.com/shinsenter/docker-imgproxy/discussions/new) [![Join the chat at https://gitter.im/shinsenter/php](https://badges.gitter.im/shinsenter/php.svg)](https://gitter.im/shinsenter/php?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

I really appreciate your love and supports.


---


## Thank you [@serversideup](https://github.com/serversideup)

This project is inspired by the [serversideup/docker-php](https://github.com/serversideup/docker-php) project, I love it. However the owners seem to be quite busy updating their projects, so I made my own version.

I think I can make it more maintainable and stable with the latest version of its middlewares.

---

## OS version

- Ubuntu 20.04 (Focal) with [S6 Overlay v3](https://github.com/just-containers/s6-overlay/tree/v3) and OpenSSL included.

View more: [shinsenter/s6-ubuntu](https://hub.docker.com/r/shinsenter/s6-ubuntu/tags)


## Usage

(I will gradually update the content in this section.)

[View all available image tags.](https://hub.docker.com/r/shinsenter/php/tags)

### PHP version

- [`shinsenter/php:7.4`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=7.4) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/php/7.4)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=7.4)
- [`shinsenter/php:8.0`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=8.0) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/php/8.0)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=8.0)
- [`shinsenter/php:8.1`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=8.1) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/php/8.1)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=8.1)


### Image variations

- [`shinsenter/php:${PHP_VERSION}-cli`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=cli) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/php/cli)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=cli)
- [`shinsenter/php:${PHP_VERSION}-fpm`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=fpm) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/php/fpm)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=fpm)
- [`shinsenter/php:${PHP_VERSION}-fpm-apache`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=fpm-apache) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/servers/fpm-apache)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=fpm-apache)
- [`shinsenter/php:${PHP_VERSION}-fpm-nginx`](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=fpm-nginx) <br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/servers/fpm-nginx)](https://hub.docker.com/r/shinsenter/php/tags?page=1&name=fpm-nginx)


### Popular PHP projects

- [`shinsenter/wordpress`](https://hub.docker.com/r/shinsenter/wordpress/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/wordpress)](https://hub.docker.com/r/shinsenter/wordpress/tags)
- [`shinsenter/phpmyadmin`](https://hub.docker.com/r/shinsenter/phpmyadmin/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/phpmyadmin)](https://hub.docker.com/r/shinsenter/phpmyadmin/tags)
- [`shinsenter/laravel`](https://hub.docker.com/r/shinsenter/laravel/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/laravel)](https://hub.docker.com/r/shinsenter/laravel/tags)
- [`shinsenter/codeigniter4`](https://hub.docker.com/r/shinsenter/codeigniter4/tags)<br/> [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/shinsenter/codeigniter4)](https://hub.docker.com/r/shinsenter/codeigniter4/tags)

---

## Create your own Dockerfile

You can install other favorite modules to your image extending my built-in base images.

For example:


```Dockerfile
FROM shinsenter/php:8.1-fpm-apache
```

or

```Dockerfile
FROM shinsenter/php:8.1-fpm-nginx
```

---


## ENV variables


### Common variables

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

# Set to "true" to fix permission for whole $WEBHOME
ENV FIX_WEBHOME_PERMISSION="false"

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
ENV PHP_PM_CONTROL="ondemand"

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


### shinsenter/php:fpm-apache

```Dockerfile
################################################################################

# Set to "true" to fix permission for whole $WEBHOME
ENV FIX_WEBHOME_PERMISSION="false"

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

# Sets the number of child server processes created on startup
ENV APACHE_START_SERVERS="2"

# Set the maximum configured value for ThreadsPerChild
# for the lifetime of the Apache httpd process
ENV APACHE_THREAD_LIMIT="64"

# This directive sets the number of threads created by each child process
ENV APACHE_THREADS_PER_CHILD="25"

################################################################################
```


### shinsenter/php:fpm-nginx

```Dockerfile
################################################################################

# Set to "true" to fix permission for whole $WEBHOME
ENV FIX_WEBHOME_PERMISSION="false"

# Sets the directory from which Nginx will serve files
ENV NGINX_DOCUMENT_ROOT="$WEBHOME"

################################################################################
```


### shinsenter/laravel

```Dockerfile
################################################################################

# Optimize and cache all config, views, routes
ENV LARAVEL_AUTO_OPTIMIZE=true

# Create symlinks to the storage folder
ENV LARAVEL_LINK_STORAGE=true

# Run Laravel migrations (for development purposese)
ENV LARAVEL_AUTO_MIGRATION=false

################################################################################
```


### shinsenter/wordpress

```Dockerfile
################################################################################

# The locale for a fresh Wordpress
ENV WORDPRESS_LOCALE="en_US"

################################################################################
```


### shinsenter/phpmyadmin

```Dockerfile
################################################################################

ENV PMA_HOST=mysql
ENV PMA_USER=
ENV PMA_PASSWORD=

################################################################################

# ENV PMA_ARBITRARY=1
# ENV PMA_HOSTS=
# ENV PMA_VERBOSE=
# ENV PMA_VERBOSES=
# ENV PMA_PORT=
# ENV PMA_PORTS=
# ENV PMA_SOCKET=
# ENV PMA_SOCKETS=

################################################################################

# ENV PMA_ABSOLUTE_URI=
# ENV PMA_CONTROLHOST=
# ENV PMA_CONTROLPORT=
# ENV PMA_PMADB=
# ENV PMA_CONTROLUSER=
# ENV PMA_CONTROLPASS=
# ENV PMA_QUERYHISTORYDB=
# ENV PMA_QUERYHISTORYMAX=

################################################################################
```


* * *

If you like this project, please support my works.

[![Donate via PayPal](https://img.shields.io/badge/Donate-Paypal-blue)](https://www.paypal.me/shinsenter) [![Become a sponsor](https://img.shields.io/badge/Donate-Patreon-orange)](https://www.patreon.com/appseeds) [![Become a stargazer](https://img.shields.io/badge/Support-Stargazer-yellow)](https://github.com/shinsenter/docker-imgproxy/stargazers) [![Report an issue](https://img.shields.io/badge/Support-Issues-green)](https://github.com/shinsenter/docker-imgproxy/discussions/new) [![Join the chat at https://gitter.im/shinsenter/php](https://badges.gitter.im/shinsenter/php.svg)](https://gitter.im/shinsenter/php?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

From Vietnam 🇻🇳 with love.

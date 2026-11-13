<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Ready-made application images

Part of the [PHP Docker Images](https://code.shin.company/php) README, moved here to keep the Docker Hub description under its 25000-byte limit.

Images for popular frameworks and applications install the project for you on first start (mount an empty folder). Each one links back here for shared settings.

[bagisto](https://hub.docker.com/r/shinsenter/bagisto), [bedrock](https://hub.docker.com/r/shinsenter/bedrock), [cakephp5](https://hub.docker.com/r/shinsenter/cakephp5), [codeigniter4](https://hub.docker.com/r/shinsenter/codeigniter4), [coolify](https://hub.docker.com/r/shinsenter/coolify), [craftcms](https://hub.docker.com/r/shinsenter/craftcms), [drupal](https://hub.docker.com/r/shinsenter/drupal), [espocrm](https://hub.docker.com/r/shinsenter/espocrm), [flarum](https://hub.docker.com/r/shinsenter/flarum), [flightphp](https://hub.docker.com/r/shinsenter/flightphp), [grav](https://hub.docker.com/r/shinsenter/grav), [hyperf](https://hub.docker.com/r/shinsenter/hyperf), [invoiceshelf](https://hub.docker.com/r/shinsenter/invoiceshelf), [joomla](https://hub.docker.com/r/shinsenter/joomla), [kirby](https://hub.docker.com/r/shinsenter/kirby), [laravel](https://hub.docker.com/r/shinsenter/laravel), [magento](https://hub.docker.com/r/shinsenter/magento), [matomo](https://hub.docker.com/r/shinsenter/matomo), [mautic](https://hub.docker.com/r/shinsenter/mautic), [nextcloud](https://hub.docker.com/r/shinsenter/nextcloud), [phpmyadmin](https://hub.docker.com/r/shinsenter/phpmyadmin), [prestashop](https://hub.docker.com/r/shinsenter/prestashop), [shopware](https://hub.docker.com/r/shinsenter/shopware), [spiral](https://hub.docker.com/r/shinsenter/spiral), [statamic](https://hub.docker.com/r/shinsenter/statamic), [sulu](https://hub.docker.com/r/shinsenter/sulu), [tempest](https://hub.docker.com/r/shinsenter/tempest), [symfony](https://hub.docker.com/r/shinsenter/symfony), [wordpress](https://hub.docker.com/r/shinsenter/wordpress), [yii](https://hub.docker.com/r/shinsenter/yii).

Web server images without PHP version tags in the name: [phpfpm-nginx](https://hub.docker.com/r/shinsenter/phpfpm-nginx), [phpfpm-apache](https://hub.docker.com/r/shinsenter/phpfpm-apache), [frankenphp](https://hub.docker.com/r/shinsenter/frankenphp), [roadrunner](https://hub.docker.com/r/shinsenter/roadrunner).


### Examples

Run a container using one of these commands:


### CLI

```shell
# non-interactive
docker run --rm shinsenter/php:8.5-cli php -m

# interactive
docker run -it -v ./myproject:/var/www/html shinsenter/php:8.5-cli
```


### PHP-FPM

```shell
docker run -v ./myproject:/var/www/html -p 9000:9000 shinsenter/php:8.5-fpm
```


### PHP-FPM + Nginx (or Apache, RoadRunner, FrankenPHP)

```shell
# with Nginx
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 -p 443:443/udp shinsenter/php:8.5-fpm-nginx

# with Apache
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 -p 443:443/udp shinsenter/php:8.5-fpm-apache

# with RoadRunner
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 -p 443:443/udp shinsenter/php:8.4-roadrunner

# with FrankenPHP
docker run -v ./myproject:/var/www/html -p 80:80 -p 443:443 -p 443:443/udp shinsenter/php:8.4-frankenphp
```

<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Running the images behind Traefik

This page shows a working setup of the web images (`fpm-nginx`, `fpm-apache`, `frankenphp`, `roadrunner`) behind [Traefik](https://traefik.io) v3 with Docker. It lists what each setting does, so you can change it with confidence, and what is verified and what is not.

If you want a tool that sets all of this up for you, see [muken](https://github.com/shinsenter/muken).

- [A working Compose file](#a-working-compose-file)
- [What each setting does](#what-each-setting-does)
- [Why deploys can return 502, and the fix](#why-deploys-can-return-502-and-the-fix)
- [Image defaults that matter](#image-defaults-that-matter)
- [What is verified and what is not](#what-is-verified-and-what-is-not)


## A working Compose file

```yaml
services:
  traefik:
    image: traefik:v3
    command:
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --entrypoints.web.http.redirections.entrypoint.to=websecure
      - --certificatesresolvers.le.acme.email=you@example.com
      - --certificatesresolvers.le.acme.storage=/acme/acme.json
      - --certificatesresolvers.le.acme.httpchallenge.entrypoint=web
    ports: ["80:80", "443:443"]
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - acme:/acme

  app:
    image: shinsenter/php:8.5-fpm-nginx
    environment:
      TRUSTED_PROXIES: private
      SHUTDOWN_DELAY: "5"
    volumes:
      - ./project:/var/www/html
    labels:
      - traefik.enable=true
      - traefik.http.routers.app.rule=Host(`app.example.com`)
      - traefik.http.routers.app.entrypoints=websecure
      - traefik.http.routers.app.tls.certresolver=le
      - traefik.http.services.app.loadbalancer.server.port=80
      - traefik.http.services.app.loadbalancer.healthcheck.port=2020
      - traefik.http.services.app.loadbalancer.healthcheck.path=/readyz
      - traefik.http.services.app.loadbalancer.healthcheck.interval=5s

volumes:
  acme:
```

For RoadRunner use `healthcheck.path=/health?plugin=http`. FrankenPHP and Apache use `/readyz` as shown.


## What each setting does

| Setting | What it does | If you leave it out |
|---|---|---|
| `loadbalancer.server.port=80` | Tells Traefik which container port gets the traffic | The images expose several ports (22, 80, 443, 443/udp, plus 2019 on FrankenPHP and 6001 on RoadRunner). The Traefik documentation asks for this label when a container exposes more than one port |
| Send traffic to port 80, not 443 | Traefik ends TLS. The image port 443 has a self-signed certificate for local tests | Traffic to 443 fails verification unless you also set `insecureSkipVerify` in a `serversTransport`. There is no benefit in doing that |
| `healthcheck.port=2020`, `healthcheck.path=/readyz` | Traefik asks the health server of the image (port 2020, not published) and sends traffic only to replicas that answer 200 | Traefik treats a container as ready as soon as it starts. During a slow start (for example `composer install` in the startup hook) visitors can get errors |
| `TRUSTED_PROXIES=private` | The server uses the visitor address from `X-Forwarded-For` and the scheme from `X-Forwarded-Proto` when the request comes from a private address, which is where Traefik runs | `REMOTE_ADDR` is the Traefik address, `$_SERVER['HTTPS']` is empty, and apps can generate `http://` links behind HTTPS |
| `SHUTDOWN_DELAY=5` | On `docker stop` the server waits 5 seconds before it stops, while Traefik removes it from the pool | Requests that arrive in the first seconds after the stop signal can fail |

`private` means `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` and `fd00::/8`. Use it only when nothing outside your private network can reach the container directly. Otherwise list the exact address of Traefik, for example `172.18.0.0/16`.

The web images carry the label `traefik.enable=true`, so with `exposedbydefault=false` they still need a router rule but not the enable label. The `phpmyadmin` and `coolify` images carry `traefik.enable=false`: they are tools with admin rights, and nothing routes them until you set `traefik.enable=true` in your own labels. A label in your Compose file replaces the one in the image.

`SHUTDOWN_DELAY` stays `0` in the image because a delay slows down every `docker stop` and `docker compose up` for people who run without a proxy. Traefik with the Docker provider needs a few seconds to notice that a container is stopping, so `5` is a safe value there.


## Why deploys can return 502, and the fix

Traefik keeps connections to your container open and reuses them. If the container closes an idle connection at the same moment Traefik sends a request on it, Traefik gets a closed connection and answers 502. It happens rarely, at random, and often only under light traffic.

It cannot happen when the container keeps an idle connection open longer than Traefik does. Traefik closes its own idle backend connections after 90 seconds (`idleConnTimeout`, from the Traefik documentation).

The images used to close idle connections earlier than that: Apache after 5 seconds and Nginx after 75 seconds. Both now wait 120 seconds:

| Variable | Default |
|---|---|
| `NGINX_KEEPALIVE_TIMEOUT` | `120` |
| `APACHE_KEEPALIVE_TIMEOUT` | `120` |

FrankenPHP (Caddy, 5 minutes) and RoadRunner (no idle limit) were already above 90 seconds, going by the upstream defaults.

If you raised Traefik's `idleConnTimeout`, raise these values above it. If you cannot change the image variables, lower Traefik's value instead:

```yaml
    command:
      - --serverstransport.forwardingtimeouts.idleconntimeout=60s
```


## Image defaults that matter

| Topic | Behavior |
|---|---|
| Redirect HTTP to HTTPS | The images do not redirect, so there is no redirect loop behind Traefik. Let Traefik redirect, as in the example (FrankenPHP is configured with `auto_https disable_redirects`) |
| Client address in logs | Correct only when `TRUSTED_PROXIES` includes Traefik |
| `X-Forwarded-Host`, `X-Forwarded-Prefix` | Passed to PHP as `HTTP_X_FORWARDED_*`. Your framework decides whether to trust them. Symfony and Laravel have their own trusted-proxy settings |
| Health port 2020 | Not exposed and not published. Traefik reaches it over the Docker network |
| Stop signal | `SIGTERM`, then `SHUTDOWN_DELAY`, then a graceful stop that lets running requests finish (see "Stopping a replica" in the README) |


## What is verified and what is not

Verified by the offline tests (`tests/run.sh scaling`):

- `TRUSTED_PROXIES` is expanded by one utility for all four servers, and `private` gives the four ranges. Bad items are skipped with a warning.
- The keep-alive defaults and the generated Nginx setting.
- The `traefik.enable` labels of the images.

Not verified, because it needs Docker and Traefik running:

- The Compose file above on a live system. It follows the Traefik documentation and the settings the images already had.
- The 502 explanation and the 90 second value. Both come from the Traefik documentation and common experience, not from a reproduction here. Check the value of your Traefik version.
- The effect of the new keep-alive defaults under load.
- That Traefik picks the right port without the `server.port` label. We do not rely on it.

`tests/scaling-test.sh <image>` starts Traefik and several replicas from `tests/docker-compose.scaling.yml` and checks them. Run it after a change to these settings.

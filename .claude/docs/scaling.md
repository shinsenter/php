<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Scaling (Kubernetes, GCP, AWS, Traefik)

What the web images give you when you run many replicas behind a load balancer: `phpfpm-nginx`, `phpfpm-apache`, `frankenphp` and `roadrunner`.
The user-facing version is "Running in Production" in `README.md`. This page has the reasons and the details.
Settings are the same across variants where the server allows it. Only the health check address differs.

## Health endpoints

Each image serves health checks on its own port, `HEALTH_PORT` (default `2020`). The port is not in `EXPOSE` and is not published.
It listens on all addresses, because probes and load balancers call the container address.
`HEALTH_CHECK_URL` holds the full address. The startup check (`verify-server`) and your own checks use it.

| Image | `HEALTH_CHECK_URL` | Answers |
|---|---|---|
| `phpfpm-nginx`, `phpfpm-apache`, `frankenphp` | `http://127.0.0.1:2020/healthz` | `200 ok` from the web server, no PHP |
| `phpfpm-nginx`, `phpfpm-apache` | `/readyz` on the same port | `200 pong` from the PHP-FPM ping page (`PHP_PING_PATH`, default `/ping`). Use it for readiness |
| `frankenphp` | `/readyz` on the same port | `200 ok`. PHP runs inside Caddy, so it equals `/healthz` |
| `roadrunner` | `http://127.0.0.1:2020/health?plugin=http` | `200` while the HTTP workers are up. `/ready?plugin=http` gives `200` only when a worker is free |

A separate port avoids four problems:

- It does not depend on the `Host` header, `SERVER_NAME`, a virtual host, an HTTPS redirect or app middleware.
- It cannot clash with a route of your app.
- The public load balancer does not reach it.
- It is the same on every image.

Anything that reaches the pod address can call it. Use a NetworkPolicy to limit that.
A platform that probes only the main port needs a route in your app, or a proxy rule to the health port.

## Why there is no default HEALTHCHECK

The start can take long, and the endpoint answers only after it.
The bootstrap hook `src/php/common/rootfs/etc/hooks/bootstrap/10-create-project` runs before the web server starts. It can:

- Clone or download the project and run `composer update -W` and `npm install`, when `APP_PATH` is empty and `INITIAL_PROJECT` is set.
- Run `composer install`, when `composer.json` exists but `vendor/` does not.

Each platform also reacts differently to a failing check, so one fixed timing would suit only some of them.

Docker marks a container `unhealthy` after `retries` failures in a row once `start_period` has passed.
Probes that fail during `start_period` do not count, and the first success makes the container `healthy`.
A long `start_period` costs nothing for a container that starts well, so set it above the longest start you expect.

To keep the start short when you scale:

- Put the source and `vendor/` in the image at build time.
- Set `DISABLE_AUTORUN_CREATING_PROJECT=1` and `DISABLE_AUTORUN_COMPOSER_INSTALL=1`.
  A replica that clones or runs `composer update` at start calls GitHub and Packagist, and can get different package versions.

## Set up a health check

Use `HEALTH_CHECK_URL` from the table above, or the address of your own endpoint.

### Docker and Compose

The Compose example is in "Health checks" in `README.md`. Same values work for `docker run`: `--health-cmd`, `--health-interval`, `--health-timeout`, `--health-retries` and `--health-start-period`.
`with-env` loads the image defaults, so `HEALTH_CHECK_URL` is set inside the check.
Compose `depends_on: condition: service_healthy` fails when the container turns `unhealthy`.
Docker Swarm replaces an `unhealthy` task, so a `start_period` shorter than the real start causes a restart loop.

### Kubernetes

Kubernetes ignores the Docker `HEALTHCHECK` and uses its own probes.
Set a `startupProbe` first. The liveness probe starts at once and would restart a pod that is still cloning or installing.

```yaml
spec:
  terminationGracePeriodSeconds: 30
  containers:
    - name: web
      image: shinsenter/phpfpm-nginx:8.4
      env:
        - { name: SHUTDOWN_DELAY, value: "5" }
        - { name: TRUSTED_PROXIES, value: "130.211.0.0/22,35.191.0.0/16" }
      startupProbe:
        httpGet: { path: /healthz, port: 2020 }
        periodSeconds: 10
        failureThreshold: 30
      livenessProbe:
        httpGet: { path: /healthz, port: 2020 }
        periodSeconds: 10
      readinessProbe:
        httpGet: { path: /readyz, port: 2020 }
        periodSeconds: 5
```

`periodSeconds × failureThreshold` of the startup probe (300 s here) must exceed the longest start.
RoadRunner uses the same port with other paths: liveness `/health?plugin=http`, readiness `/ready?plugin=http`.

### Load balancers

The main port (80) carries the traffic. The health check uses `HEALTH_PORT`.

- Traefik: the images carry `traefik.enable=true`. Set `traefik.http.services.<name>.loadbalancer.server.port=80` and a router rule. For health checks add `traefik.http.services.<name>.loadbalancer.healthcheck.port=2020` and `traefik.http.services.<name>.loadbalancer.healthcheck.path=/readyz`.
- AWS ALB: target group health check port override `2020`, path `/readyz`, protocol HTTP. Set the deregistration delay equal to or longer than `SHUTDOWN_DELAY`. A target that is still starting stays out of rotation.
- AWS ECS: define `healthCheck` in the task definition (`CMD-SHELL`, `startPeriod`). Set the ALB check port in the target group as above.
- GCP: BackendConfig health check `requestPath: /readyz`, `port: 2020`. Use container-native load balancing (NEG) so the check hits the pod directly.

## Environment variables

| Variable | Default | Effect |
|---|---|---|
| `TRUSTED_PROXIES` | empty | CIDRs (comma or space separated) that may set `X-Forwarded-For` and `X-Forwarded-Proto`. No proxy is trusted until this is set |
| `SHUTDOWN_DELAY` | `0` | Seconds to wait after the stop signal, so the load balancer can remove the replica |
| `S6_SERVICES_GRACETIME`, `S6_KILL_GRACETIME` | `25000` | Milliseconds the servers get to finish running requests. Keep below `terminationGracePeriodSeconds` (30 s by default) |
| `PHP_PING_PATH` | `/ping` | FPM ping path that `/readyz` uses (Nginx and Apache) |
| `HEALTH_PORT` | `2020` | Port of the health checks. Not exposed |
| `HEALTH_CHECK_URL` | `http://127.0.0.1:${HEALTH_PORT}/healthz` | See the table above (RoadRunner uses `/health?plugin=http`) |
| `CADDY_GRACE_PERIOD` | `20s` | FrankenPHP: time for running requests on stop |

All four web images trust no proxy by default. `REMOTE_ADDR` stays the address of the connection, and the app reads `X-Forwarded-For` itself, as in 5.x.
`TRUSTED_PROXIES` lets the server replace `REMOTE_ADDR` and honor `X-Forwarded-Proto`. For pod IPs, Traefik and load balancers inside the VPC, use `10.0.0.0/8,172.16.0.0/12,192.168.0.0/16`.
With Cloudflare in front, list the load balancer and the Cloudflare ranges.

## HTTPS behind a proxy

`X-Forwarded-Proto: https` sets `$_SERVER['HTTPS']` to `on` and `REQUEST_SCHEME` to `https`.
The server uses the header only when the proxy that sent it is trusted, the same rule as for the client address.
A client that connects directly cannot fake it.

## Stopping a replica

On `SIGTERM`, s6 runs the `SHUTDOWN_DELAY` wait, then stops the servers with their graceful signal: `SIGQUIT` for Nginx and PHP-FPM, `SIGWINCH` for Apache.
Running requests finish and new connections are refused. Nginx or Apache stops before PHP-FPM.
FrankenPHP and RoadRunner stop on `SIGTERM` by themselves, and FrankenPHP uses `CADDY_GRACE_PERIOD`.
Not verified: how long RoadRunner waits for running requests on `SIGTERM`.

## Read-only root and state

Keep sessions, uploads and cache outside the container (Redis, a database, object storage or a shared volume), so every replica can answer any request.
Not verified: `readOnlyRootFilesystem: true`. If you try it, mount `emptyDir` on `/run`, `/tmp`, `/var/log` and `/var/tmp`, and check the start log.

## Test

- Offline: `tests/run.sh scaling` checks that the files and settings above exist.
- Docker: `tests/scaling-test.sh <image> [replicas]` starts Traefik and the replicas from `tests/docker-compose.scaling.yml`, then checks health, load balancing, client address, HTTPS and a graceful stop. The variant comes from the image name. RoadRunner runs without the app checks. See `.claude/docs/tests.md`.

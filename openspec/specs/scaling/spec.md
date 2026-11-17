<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->


# Scaling

## Purpose

Web images (`phpfpm-nginx`, `phpfpm-apache`, `frankenphp`, `roadrunner`) run as many replicas behind Kubernetes, GCP, AWS or Traefik load balancers. User guide: "Running in Production" in `README.md`, `docs/traefik.md`. Offline check: `tests/run.sh scaling`. Docker check: `tests/scaling-test.sh <image> [replicas]`.

## Requirements


### Requirement: Health endpoints

The repo SHALL follow these rules for: health endpoints.
- Each image SHALL serve health checks on `HEALTH_PORT` (default `2020`), listening on all addresses, not in `EXPOSE`, not published.
- `HEALTH_CHECK_URL` SHALL hold the full address (default `http://127.0.0.1:${HEALTH_PORT}/healthz`). `verify-server` uses it.
- Endpoints per image:

| Image | Liveness | Readiness |
|---|---|---|
| nginx, apache | `/healthz` 200 `ok`, no PHP | `/readyz` 200 `pong` from FPM ping (`PHP_PING_PATH`, default `/ping`) |
| frankenphp | `/healthz` 200 | `/readyz` 200, same as `/healthz` (PHP runs in Caddy) |
| roadrunner | `/health?plugin=http` 200 while workers are up | `/ready?plugin=http` 200 only when a worker is free |

Why a separate port: independent of `Host`, `SERVER_NAME`, vhost, HTTPS redirect and app middleware; no route clash; unreachable from the public LB; same on every image.
- Docs SHALL say a NetworkPolicy limits access to the port, and that a platform probing only the main port needs an app route or proxy rule.

#### Scenario: image start
- WHEN a container starts THEN `/healthz` answers only after the bootstrap hook `10-create-project` ends and the server is up.

### Requirement: No default HEALTHCHECK

The repo SHALL follow these rules for: no default healthcheck.

#### Scenario: No default HEALTHCHECK
- **WHEN** this area is changed
- **THEN** all of the following hold:
- Images SHALL NOT set a Docker `HEALTHCHECK`. Why: bootstrap (clone, `composer update -W`, `npm install`, `composer install` when `vendor/` is missing) can take long, and each platform reacts differently to failures.
- Docs SHALL advise: put source and `vendor/` in the image; set `DISABLE_AUTORUN_CREATING_PROJECT=1` and `DISABLE_AUTORUN_COMPOSER_INSTALL=1` when scaling (a replica that installs at start calls GitHub and Packagist and may get other versions).
- Docker: `unhealthy` after `retries` failures once `start_period` passed; failures in `start_period` do not count. Set `start_period` above the longest start. Swarm replaces an `unhealthy` task, so a short `start_period` loops restarts. `depends_on: condition: service_healthy` fails on `unhealthy`. `docker run` uses `--health-*` flags; `with-env` sets `HEALTH_CHECK_URL` inside the check.

### Requirement: Kubernetes

The repo SHALL follow these rules for: kubernetes.

#### Scenario: Kubernetes
- **WHEN** this area is changed
- **THEN** all of the following hold:
- Docs SHALL use a `startupProbe` first (liveness starts at once and would restart a pod that is still installing). `periodSeconds × failureThreshold` of it SHALL exceed the longest start.
- Reference values: startup and liveness `/healthz` port 2020 (period 10, startup threshold 30); readiness `/readyz` port 2020 (period 5); `terminationGracePeriodSeconds: 30`; `SHUTDOWN_DELAY=5`; `TRUSTED_PROXIES=130.211.0.0/22,35.191.0.0/16` on GCP. RoadRunner: liveness `/health?plugin=http`, readiness `/ready?plugin=http`.

### Requirement: Load balancers

The repo SHALL follow these rules for: load balancers.

#### Scenario: Load balancers
- **WHEN** this area is changed
- **THEN** all of the following hold:
Traffic uses port 80. Health checks use `HEALTH_PORT`.
- Traefik: web images carry `traefik.enable=true`; `phpmyadmin` and `coolify` carry `traefik.enable=false` (admin tools are routed only on opt-in). Docs SHALL require `loadbalancer.server.port=80` (images expose several ports) and `loadbalancer.healthcheck.port=2020`, path `/readyz`. RoadRunner SHALL use `/health?plugin=http`, never `/ready?plugin=http` (503 while all workers are busy drops the replica under load).
- AWS ALB: health check port override `2020`, path `/readyz`, HTTP; deregistration delay >= `SHUTDOWN_DELAY`.
- AWS ECS: `healthCheck` in the task definition (`CMD-SHELL`, `startPeriod`); ALB port as above.
- GCP: BackendConfig `requestPath: /readyz`, `port: 2020`; use container-native LB (NEG).

### Requirement: Environment variables

The repo SHALL follow these rules for: environment variables.

#### Scenario: Environment variables
- **WHEN** this area is changed
- **THEN** all of the following hold:
| Variable | Default | Effect |
|---|---|---|
| `TRUSTED_PROXIES` | empty | CIDRs (comma or space) allowed to set `X-Forwarded-For` and `X-Forwarded-Proto`. `private` = `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `fd00::/8`. One utility, `trusted-proxies`, expands it for all four servers |
| `NGINX_KEEPALIVE_TIMEOUT`, `APACHE_KEEPALIVE_TIMEOUT` | `120` | Idle client connection seconds |
| `SHUTDOWN_DELAY` | `0` | Seconds to wait after the stop signal |
| `S6_SERVICES_GRACETIME`, `S6_KILL_GRACETIME` | `25000` | ms for running requests. MUST stay within 10000 to 29000 (below the 30 s Kubernetes default) |
| `PHP_PING_PATH` | `/ping` | FPM ping path for `/readyz` |
| `HEALTH_PORT` | `2020` | Health port, not exposed |
| `HEALTH_CHECK_URL` | see above | Full health address |
| `CADDY_GRACE_PERIOD` | `20s` | FrankenPHP stop grace |

### Requirement: Proxy trust and HTTPS

The repo SHALL follow these rules for: proxy trust and https.

#### Scenario: Proxy trust and HTTPS
- **WHEN** this area is changed
- **THEN** all of the following hold:
- With `TRUSTED_PROXIES` empty, no proxy SHALL be trusted: `REMOTE_ADDR` stays the connection address and the app reads `X-Forwarded-For` itself (as in 5.x).
- With it set, the server SHALL replace `REMOTE_ADDR` and honor `X-Forwarded-Proto` only from a trusted proxy.
- `X-Forwarded-Proto: https` from a trusted proxy SHALL set `$_SERVER['HTTPS']=on` and `REQUEST_SCHEME=https`. A direct client cannot fake it.
- Docs: for pod IPs, Traefik and VPC LBs use the three private ranges; behind Cloudflare list the LB and Cloudflare ranges.

### Requirement: Keep-alive

The repo SHALL follow these rules for: keep-alive.

#### Scenario: Keep-alive
- **WHEN** this area is changed
- **THEN** all of the following hold:
Why: a backend that closes an idle connection first makes the proxy's next request fail with 502. The backend idle time SHALL exceed the proxy's.
- Nginx 120 s (`NGINX_KEEPALIVE_TIMEOUT`; Nginx alone is 75 s). Apache 120 s (`APACHE_KEEPALIVE_TIMEOUT`; was 5 s; event MPM holds no worker while idle). FrankenPHP: Caddy default 5 min, unchanged. RoadRunner: Go default, no idle limit, unchanged.
- Traefik closes idle backend connections after 90 s (`serversTransport.forwardingTimeouts.idleConnTimeout`; from Traefik docs, untested here). A longer proxy idle time needs a larger value here.
- Unverified: FrankenPHP and RoadRunner values come from upstream defaults, not image tests.

### Requirement: Stopping a replica

The repo SHALL follow these rules for: stopping a replica.

#### Scenario: Stopping a replica
- **WHEN** this area is changed
- **THEN** all of the following hold:
- On `SIGTERM`, s6 SHALL wait `SHUTDOWN_DELAY`, then stop servers gracefully: `SIGQUIT` for Nginx and PHP-FPM, `SIGWINCH` for Apache. Running requests finish, new connections are refused, the web server stops before PHP-FPM.
- FrankenPHP and RoadRunner stop on `SIGTERM` themselves; FrankenPHP uses `CADDY_GRACE_PERIOD`.
- Unverified: how long RoadRunner waits for running requests.

### Requirement: State and read-only root

The repo SHALL follow these rules for: state and read-only root.

#### Scenario: State and read-only root
- **WHEN** this area is changed
- **THEN** all of the following hold:
- Docs SHALL say sessions, uploads and cache live outside the container so any replica can answer any request.
- Unverified: `readOnlyRootFilesystem: true`. If tried, mount `emptyDir` on `/run`, `/tmp`, `/var/log`, `/var/tmp` and check the start log.

## Verification
- `tests/scaling-test.sh` checks health, load balancing, client address, HTTPS and graceful stop through Traefik (`tests/docker-compose.scaling.yml`, app in `tests/scaling/`). Variant comes from the image name. RoadRunner runs without app checks.

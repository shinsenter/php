#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Offline tests (no Docker, no build). Exit code is non-zero when any fails.
#   tests/run.sh                 run all
#   tests/run.sh versions        run one: lint, versions, backports, config, scaling, ssh, defaults,
#                                size, fingerprint, helpers, updates
# Other scripts source this file to reuse the check helpers; the tests run only
# when it is executed directly.
#
# Counters start at zero in every test; `finish` prints the summary and returns non-zero
# when a check failed.

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="$(basename "$0")"
PASSED=0
FAILED=0

fail() {
    FAILED=$((FAILED + 1))
    echo "FAIL: $*" >&2
}

# Check "<description>" <command...>: passes when the command succeeds
check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        PASSED=$((PASSED + 1))
    else
        fail "$description"
    fi
}

# check_not "<description>" <command...>: passes when the command fails
check_not() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        fail "$description"
    else
        PASSED=$((PASSED + 1))
    fi
}

# check_eq "<description>" <expected> <actual>
check_eq() {
    if [ "$2" = "$3" ]; then
        PASSED=$((PASSED + 1))
    else
        fail "$1 (expected '$2', got '$3')"
    fi
}

# check_re "<description>" <text> <regex>
check_re() {
    if [[ "$2" =~ $3 ]]; then
        PASSED=$((PASSED + 1))
    else
        fail "$1 ('$2')"
    fi
}

# Has "<description>" <file> <text>: passes when the file contains the text (fixed string)
has() { check "$1" grep -qF -- "$3" "$2"; }

# Lacks "<description>" <file> <text>: passes when the file does not contain the text
lacks() { check_not "$1" grep -qF -- "$3" "$2"; }

# join_lines: the lines of stdin on one line, separated by spaces
join_lines() { tr '\n' ' ' | sed 's/ $//'; }

finish() {
    echo "$NAME: $PASSED passed, $FAILED failed"
    [ "$FAILED" -eq 0 ]
}

# lint: syntax check of every tracked shell script,
# and the no-tabs rule for the scripts of this project.
test_lint() {
    cd "$BASE_DIR" || exit 1

    while IFS= read -r -d '' file; do
        [ -f "$file" ] || continue
        case "$file" in
            build/docker-squash/*) continue ;;  # third-party
        esac

        first="$(head -n 1 "$file" 2>/dev/null | LC_ALL=C tr -d '\0')"
        case "$first" in
            '#!'*bash*) check "bash -n $file" bash -n "$file" ;;
            '#!'*sh*)   check "sh -n $file" sh -n "$file" ;;
        esac
    done < <(git ls-files -z)

    check_eq "files with a tab character" "" \
        "$(grep -l "$(printf '\t')" tests/*.sh tests/tools/*.sh build/*.sh)"

    finish
}

# versions: build/versions.sh and the version helpers of build/helpers.sh
test_versions() {
    source "$BASE_DIR/build/helpers.sh"
    source "$BASE_DIR/build/versions.sh"
    local newest="${MAINTAINED_PHP_VERSIONS[0]}" oldest_maintained="${MAINTAINED_PHP_VERSIONS[${#MAINTAINED_PHP_VERSIONS[@]} - 1]}"

    # Lists
    check "maintained list is not empty" [ "${#MAINTAINED_PHP_VERSIONS[@]}" -gt 0 ]
    check "outdated list is not empty" [ "${#OUTDATED_PHP_VERSIONS[@]}" -gt 0 ]
    check_eq "ALL_PHP_VERSIONS size" \
        "$((${#MAINTAINED_PHP_VERSIONS[@]} + ${#OUTDATED_PHP_VERSIONS[@]}))" "${#ALL_PHP_VERSIONS[@]}"
    check_eq "duplicated versions" "" "$(printf '%s\n' "${ALL_PHP_VERSIONS[@]}" | sort | uniq -d)"
    for version in "${OUTDATED_PHP_VERSIONS[@]}"; do
        check "$version is outdated" is_outdated_php "$version"
        check "$version is older than $oldest_maintained" verlt "$version" "$oldest_maintained"
    done
    for version in "${MAINTAINED_PHP_VERSIONS[@]}"; do
        check_not "$version is not outdated" is_outdated_php "$version"
    done
    check_not "unknown version is not outdated" is_outdated_php "9.9"

    # select_php_versions: outdated first, unknown versions fail
    check_eq "select: all versions" "${#ALL_PHP_VERSIONS[@]}" "$(select_php_versions '' | wc -l | tr -d ' ')"
    check_eq "select: outdated before maintained" "${OUTDATED_PHP_VERSIONS[0]} $newest" \
        "$(select_php_versions "$newest ${OUTDATED_PHP_VERSIONS[0]}" | join_lines)"
    check_eq "select: commas and duplicates" "$newest" "$(select_php_versions "$newest,$newest" | join_lines)"
    check_not "select: unknown version" select_php_versions 9.9

    # Alpine images start at PHP 7.1
    for version in 5.6 7.0; do check_not "no alpine $version" has_alpine_php "$version"; done
    for version in 7.1 7.4 "$newest"; do check "alpine $version" has_alpine_php "$version"; done

    # Version compare
    for pair in "7.4 8.0" "7.9 7.10" "8.0 8.0"; do check "verlte $pair" verlte $pair; done
    for pair in "7.4 8.0" "7.9 7.10"; do check "verlt $pair" verlt $pair; done
    check_not "verlte 8.1 8.0" verlte 8.1 8.0
    check_not "verlt 8.0 8.0" verlt 8.0 8.0
    check "active 8.3" is_active_version 8.3
    for version in 8.2 7.4; do check_not "active $version" is_active_version "$version"; done

    # Nginx and Apache keywords, with a stub of the download page (no network)
    fetch_with_cache() {
        echo '<h4>Mainline version</h4><a href="/download/nginx-1.31.8.tar.gz">x</a><h4>Stable version</h4><a href="/download/nginx-1.30.6.tar.gz">x</a><h4>Legacy versions</h4><a href="/download/nginx-1.28.3.tar.gz">'
    }
    check_eq "nginx mainline" "1.31.8" "$(resolve_nginx_version mainline)"
    check_eq "nginx stable" "1.30.6" "$(resolve_nginx_version stable)"
    for value in 1.29.0 os ''; do check_eq "nginx '$value' passes through" "$value" "$(resolve_nginx_version "$value")"; done
    fetch_with_cache() { echo '<h1>Apache HTTP Server 2.4.71</h1><a href="https://dlcdn.apache.org/httpd/httpd-2.4.71.tar.gz">x</a><a href="x/httpd-2.4.71.tar.bz2">'; }
    check_eq "apache stable" "2.4.71" "$(resolve_apache_version stable)"
    for value in 2.4.60 os ''; do check_eq "apache '$value' passes through" "$value" "$(resolve_apache_version "$value")"; done
    unset -f fetch_with_cache

    # Helper cache downloads, with stubs (no network)
    local cache_dir file
    cache_dir="$(mktemp -d)"
    HELPER_CACHE_DIR="$cache_dir"
    resolve_nginx_version() { echo 1.31.8; }
    resolve_apache_version() { echo 2.4.71; }
    get_github_latest_tag() { echo v3.2.1.0; }
    download_file() { echo "$1" >"$2"; }
    fetch_with_cache() { echo "bad  wp-cli.phar"; }

    cache_nginx_source 2>/dev/null; cache_apache_source 2>/dev/null; cache_s6_sources 2>/dev/null
    for file in nginx-1.31.8.tar.gz ngx_brotli.tar.gz httpd-2.4.71.tar.gz \
        s6-v3.2.1.0-s6-overlay-noarch.tar.xz s6-v3.2.1.0-syslogd-overlay-noarch.tar.xz \
        s6-v3.2.1.0-s6-overlay-x86_64.tar.xz s6-v3.2.1.0-s6-overlay-aarch64.tar.xz; do
        check "cache: $file" [ -f "$cache_dir/$file" ]
    done
    cache_wpcli_source 2>/dev/null
    check_not "cache: wp-cli with a wrong checksum is removed" [ -f "$cache_dir/wp-cli.phar" ]
    download_file() { echo "phar" >"$2"; }
    fetch_with_cache() { echo "$(echo phar | shasum -a 512 | awk '{print $1}')  wp-cli.phar"; }
    cache_wpcli_source 2>/dev/null
    check "cache: wp-cli with a matching checksum is kept" [ -f "$cache_dir/wp-cli.phar" ]
    NGINX_VERSION=os; resolve_nginx_version() { echo os; }
    rm -f "$cache_dir"/nginx-* "$cache_dir"/ngx_brotli*
    cache_nginx_source 2>/dev/null
    check_eq "cache: nginx os is not downloaded" "" "$(ls "$cache_dir" | grep '^nginx-\|^ngx_brotli' || true)"
    rm -rf "$cache_dir"
    unset -f fetch_with_cache download_file get_github_latest_tag resolve_nginx_version resolve_apache_version

    finish
}

# backports: rules for src/php-backports/ (see openspec/specs/backports/spec.md).
# It does not apply the patches: that needs the source tree of that PHP version.
test_backports() {
    source "$BASE_DIR/build/versions.sh"

    ROOT="$BASE_DIR/src/php-backports"
    NAME_RE='^[0-9]{4}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])-(10|90)-[A-Za-z0-9._-]+\.patch$'

    for dir in "$ROOT"/php*/; do
        [ -d "$dir" ] || continue
        folder="$(basename "$dir")"
        version="${folder#php}"

        check_re "$folder: folder name is php<major.minor>" "$version" '^[0-9]+\.[0-9]+$'
        for maintained in "${MAINTAINED_PHP_VERSIONS[@]}"; do
            check_not "$folder: $version is still maintained" \
                [ "${maintained%-rc}" = "$version" ]
        done
        check "$folder: has at least one patch" \
            bash -c 'ls "$1"/*.patch' _ "$dir"

        for file in "$dir"*; do
            name="$(basename "$file")"
            rel="$folder/$name"

            check_re "$rel: name is <YYYYMMDD>-<10|90>-<name>[.alpine|.debian].patch" \
                "$name" "$NAME_RE"
            check "$rel: is mentioned in README.md" grep -qF "$name" "$ROOT/README.md"
            check "$rel: has a diff" grep -q '^diff ' "$file"
            check_not "$rel: touches NEWS" grep -q '^diff .* [ab]/NEWS' "$file"
            check_not "$rel: touches a .phpt test" grep -q '^diff .*\.phpt' "$file"

            # Security fixes (order 90) start with Backport-Fix lines
            case "$name" in
                ????????-90-*)
                    check "$rel: starts with Backport-Fix:" \
                        bash -c 'head -n 1 "$1" | grep -q "^Backport-Fix: ."' _ "$file"
                    while IFS= read -r line; do
                        text="${line#Backport-Fix: }"
                        check "$rel: Backport-Fix text is under 80 characters" \
                            [ "${#text}" -lt 80 ]
                    done < <(sed -n '/^diff /q;/^Backport-Fix: /p' "$file")
                    ;;
            esac
        done
    done

    finish
}

# config: build/config.sh paths that finish before any network call.
# Alpine images that do not exist for old PHP versions are skipped.
test_config() {
    config_value() {
        BUILD_TAG_PREFIX=local- "$BASE_DIR/build/config.sh" "$@" 2>/dev/null
    }

    for version in 5.6 7.0; do
        output="$(config_value alpine cli "$version")"
        check_eq "alpine cli $version: SKIP_BUILD" "SKIP_BUILD='1'" \
            "$(grep '^SKIP_BUILD=' <<<"$output")"
        check_eq "alpine cli $version: BUILD_DOCKERFILE" "BUILD_DOCKERFILE=''" \
            "$(grep '^BUILD_DOCKERFILE=' <<<"$output")"
        check_eq "alpine cli $version: BUILD_TAG" \
            "BUILD_TAG='shinsenter/php:local-$version-cli-alpine'" \
            "$(grep '^BUILD_TAG=' <<<"$output")"
    done

    # s6-overlay archive: the platform decides, not uname (an arm64 builder reports aarch64 for arm/v7, #478)
    local snippet
    snippet="$(sed -n '/# Detect the target architecture/,/^    untar() {/p' \
        "$BASE_DIR/src/php/common/os-s6-overlay.dockerfile" | sed '$d')"
    s6_arch() { (TARGETARCH="$1" TARGETVARIANT="$2" machine="$3"; uname() { echo "$machine"; }; eval "$snippet"; echo "$S6_ARCH"); }
    check_eq "s6 arch arm/v7 on an arm64 builder" arm "$(s6_arch arm v7 aarch64)"
    check_eq "s6 arch arm/v6" armhf "$(s6_arch arm v6 aarch64)"
    check_eq "s6 arch arm64" aarch64 "$(s6_arch arm64 '' x86_64)"
    check_eq "s6 arch without platform args" arm "$(s6_arch '' '' armv7l)"

    finish
}

# scaling: files that make the images work behind Kubernetes, load balancers and Traefik.
# Most checks look for a setting in a config file. They guard the contract (ports, paths, defaults),
# not how the files are written.
test_scaling() {
    cd "$BASE_DIR" || exit 1
    local nginx=src/php/with-nginx apache=src/php/with-apache f8p=src/php/with-f8p rr=src/php/with-roadrunner common=src/php/common
    local image config hook name value

    # Health endpoints
    has "nginx: health server on HEALTH_PORT" "$nginx/rootfs/etc/hooks/server/init-nginx" 'listen ${HEALTH_PORT};'
    has "nginx: /healthz" "$nginx/rootfs/etc/hooks/server/init-nginx" 'location = /healthz'
    has "nginx: /readyz uses the FPM ping path" "$nginx/rootfs/etc/hooks/server/init-nginx" '${PING_PATH}'
    check_not "nginx: no health paths on the main port" grep -q 'healthz\|readyz' "$nginx/rootfs/etc/nginx/custom.d/01-common.conf"
    has "apache: health vhost on HEALTH_PORT" "$apache/rootfs/etc/apache2/sites-enabled/01-health.conf" 'VirtualHost *:${HEALTH_PORT}'
    has "apache: /healthz" "$apache/rootfs/etc/apache2/sites-enabled/01-health.conf" 'healthz'
    has "apache: /readyz" "$apache/rootfs/etc/apache2/sites-enabled/01-health.conf" '"/readyz"'
    has "frankenphp: health site on its own port" "$f8p/rootfs/etc/caddy/Caddyfile" 'http://:{$HEALTH_PORT:2020}'
    has "roadrunner: status plugin" "$rr/roadrunner-config.dockerfile" 'status.address=0.0.0.0:${HEALTH_PORT:-2020}'
    check "health port: every image sets HEALTH_PORT 2020" test "$(grep -l "HEALTH_PORT *'2020'" src/php/with-*/*-config.dockerfile | wc -l | tr -d ' ')" = 4
    for image in nginx apache f8p roadrunner; do
        check_not "$image: health port is not exposed" grep -qE '^EXPOSE (2020|2114)$' "src/php/with-$image.dockerfile"
        # No active HEALTHCHECK, only a commented example that reads HEALTH_CHECK_URL
        check_not "$image: no active HEALTHCHECK" grep -q '^HEALTHCHECK' "src/php/with-$image.dockerfile"
        check "$image: HEALTHCHECK example" grep -q '^# *CMD with-env sh -c .curl -sf "$HEALTH_CHECK_URL"' "src/php/with-$image.dockerfile"
    done
    for config in "$nginx/nginx-config" "$apache/apache-config" "$f8p/f8p-config" "$rr/roadrunner-config"; do
        has "$config: HEALTH_CHECK_URL" "$config.dockerfile" 'HEALTH_CHECK_URL'
    done
    has "compose: healthcheck reads HEALTH_CHECK_URL" tests/docker-compose.scaling.yml 'HEALTH_CHECK_URL'

    # Reverse proxies: HTTPS from X-Forwarded-Proto, and no proxy is trusted by default (#456)
    has "nginx: HTTPS from X-Forwarded-Proto" "$nginx/rootfs/etc/nginx/custom.d/00-proxy-proto.conf" 'x_forwarded_proto'
    has "nginx: php location passes HTTPS" "$nginx/rootfs/etc/nginx/custom.d/01-common.conf" 'fastcgi_param HTTPS'
    has "apache: HTTPS from X-Forwarded-Proto" "$apache/rootfs/etc/apache2/apache2.conf" 'X-Forwarded-Proto'
    check_not "nginx: no proxy is trusted by default" grep -qE '^[[:space:]]*set_real_ip_from' "$nginx/rootfs/etc/nginx/nginx.conf"
    check_not "apache: no proxy is trusted by default" grep -qE '^[[:space:]]*RemoteIPTrustedProxy' "$apache/rootfs/etc/apache2/apache2.conf"
    check_not "roadrunner: private ranges are not trusted by default" grep -q '10.0.0.0/8' "$rr/rootfs/etc/hooks/server/init-roadrunner"
    has "frankenphp: trusted proxies come from TRUSTED_PROXIES only" "$f8p/rootfs/etc/caddy/Caddyfile" 'trusted_proxies static {$CADDY_TRUSTED_PROXIES}'
    has "nginx: proxies.d is included" "$nginx/rootfs/etc/nginx/nginx.conf" 'proxies.d/*.conf'

    # Stop signals and the shutdown delay
    has "nginx: graceful stop signal" "$nginx/nginx-config.dockerfile" 'down-signal SIGQUIT'
    has "apache: graceful stop signal" "$apache/apache-config.dockerfile" 'down-signal SIGWINCH'
    has "php-fpm: graceful stop signal" "$common/php-extensions.dockerfile" 'down-signal SIGQUIT'
    for config in with-nginx/nginx-config with-apache/apache-config with-f8p/f8p-config with-roadrunner/roadrunner-config; do
        has "$config: shutdown-delay dependency" "src/php/$config.dockerfile" 's6-service shutdown-delay requires'
    done
    for image in nginx apache f8p roadrunner; do
        has "$image: includes web-shutdown-delay" "src/php/with-$image.dockerfile" 'INCLUDE ./common/web-shutdown-delay'
    done
    check "shutdown delay hook is executable" test -x "$common/rootfs/etc/hooks/s6-exit-shutdown-delay/00-delay"
    has "shutdown delay default" "$common/web-shutdown-delay.dockerfile" "SHUTDOWN_DELAY '0'"
    # The stop timeout must stay below the 30 s that Kubernetes waits by default
    for name in S6_KILL_GRACETIME S6_SERVICES_GRACETIME; do
        value="$(sed -n "s/.*env-default $name \([0-9]*\).*/\1/p" "$common/os-s6-overlay.dockerfile")"
        check "$name is between 10000 and 29000 (got '$value')" test "${value:-0}" -ge 10000 -a "${value:-0}" -le 29000
    done

    # Traefik: keep-alive stays above the 90 s that Traefik keeps its idle backend connections
    value="$(sed -n "s/^env-default NGINX_KEEPALIVE_TIMEOUT '\([0-9]*\)'.*/\1/p" "$nginx/nginx-config.dockerfile")"
    check "nginx: keep-alive default is above 90 s" test "${value:-0}" -gt 90
    value="$(sed -n "s/^env-default APACHE_KEEPALIVE_TIMEOUT '\([0-9]*\)'.*/\1/p" "$apache/apache-config.dockerfile")"
    check "apache: keep-alive default is above 90 s" test "${value:-0}" -gt 90
    # Traefik labels: web servers opt in, the admin tools opt out
    for image in src/php/with-nginx.dockerfile src/php/with-apache.dockerfile; do
        check "label: $image traefik.enable=true" grep -q '^LABEL traefik.enable=true' "$image"
    done
    for image in src/webapps/phpmyadmin/phpmyadmin.dockerfile src/webapps/coolify/coolify.dockerfile; do
        check "label: $image traefik.enable=false" grep -q '^LABEL traefik.enable=false' "$image"
    done

    # trusted-proxies: one expansion shared by the four servers, so "private" works everywhere
    local tp="$common/rootfs/usr/local/utils/trusted-proxies" stub
    stub="$(mktemp -d)"
    printf '#!/bin/sh\necho "$@" >&2\n' >"$stub/debug-echo"
    chmod +x "$stub/debug-echo"
    tp_run() { PATH="$stub:$PATH" TRUSTED_PROXIES="$1" sh "$tp" 2>/dev/null | join_lines; }
    check_eq "trusted-proxies: private" "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 fd00::/8" "$(tp_run private)"
    check_eq "trusted-proxies: a mixed list" "203.0.113.0/24 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 fd00::/8 2001:db8::/32" "$(tp_run '203.0.113.0/24,private 2001:db8::/32')"
    check_eq "trusted-proxies: a bad item is skipped" "10.1.2.3" "$(tp_run '10.1.2.3,bad!,a;b')"
    check_eq "trusted-proxies: empty list" "" "$(tp_run '')"
    check "trusted-proxies: a bad item gives a warning on stderr" test -n "$(PATH="$stub:$PATH" TRUSTED_PROXIES='bad!' sh "$tp" 2>&1 >/dev/null)"
    rm -rf "$stub"
    for hook in "$nginx/rootfs/etc/hooks/server/init-nginx" "$apache/rootfs/etc/hooks/server/init-apache" \
        "$f8p/rootfs/etc/hooks/server/init-f8p" "$rr/rootfs/etc/hooks/server/init-roadrunner"; do
        check "trusted-proxies: $(basename "$hook") uses the utility" grep -q '\$(trusted-proxies)' "$hook"
    done

    check "files: spec, compose, docs and test script" test -f openspec/specs/scaling/spec.md -a -f tests/docker-compose.scaling.yml -a -f docs/traefik.md -a -x tests/scaling-test.sh
    finish
}

# ssh: the sshd hook must never leave password auth on for an account locked with '*'.
# musl crypt() returns '*' for passwords over 256 bytes, which would match the shadow field.
# The hook runs with stub commands and a temporary root, so it needs no Docker.
test_ssh() {
    cd "$BASE_DIR" || exit 1
    local hook="$BASE_DIR/src/php/common/rootfs/etc/hooks/post-boot/00-ssh-server"
    local utils="$BASE_DIR/src/php/common/rootfs/usr/local/utils"
    local tmp stub
    tmp="$(mktemp -d)"
    stub="$tmp/bin"
    mkdir -p "$stub"
    trap 'rm -rf "$tmp"' RETURN

    # Commands the hook calls: the real is-true, a shadow file as state, no-ops for the rest
    cp "$utils/is-true" "$stub/is-true"
    for cmd in has-cmd has-s6 s6-service debug-echo pkg-add groupadd useradd ssh-keygen chown; do
        printf '#!/bin/sh\nexit 0\n' > "$stub/$cmd"
    done
    printf '#!/bin/sh\nexit 1\n' > "$stub/is-debug"
    printf '#!/bin/sh\necho 1000\n' > "$stub/id"
    printf '#!/bin/sh\nexit 0\n' > "$stub/with-env"
    printf '#!/bin/sh\nfor a; do :; done; echo "$a"\n' > "$stub/realpath"
    printf '#!/bin/sh\nif [ "$1" = shadow ]; then echo "$2:$(cat "$SHADOW"):::"; else echo "$2:x:1000:1000::$HOME_STUB:/bin/bash"; fi\n' > "$stub/getent"
    printf '#!/bin/sh\n[ "$1" = "-p" ] && printf %%s "$2" > "$SHADOW"\nexit 0\n' > "$stub/usermod"
    printf '#!/bin/sh\nread -r line; printf %%s "\\$6\\$hash" > "$SHADOW"\n' > "$stub/chpasswd"
    chmod +x "$stub"/*

    # run_hook <initial shadow field> <env assignments...>: prints the generated sshd config
    run_hook() {
        local shadow="$1"
        shift
        printf %s "$shadow" > "$tmp/shadow"
        mkdir -p "$tmp/home" "$tmp/run"
        # /run is not writable on every host, so point the config at the temporary root
        sed "s#/run#$tmp/run#g; s#/var$tmp/run#$tmp/run#g" "$hook" > "$tmp/hook.sh"
        env -i PATH="$stub:/usr/bin:/bin" SHADOW="$tmp/shadow" HOME_STUB="$tmp/home" APP_USER=www-data \
            ENABLE_SSHD=1 "$@" bash "$tmp/hook.sh" >/dev/null 2>&1
        cat "$tmp/run/sshd_env.conf" 2>/dev/null
    }

    # ssh_case "<description>" <yes|no> <shadow field> [env assignments...]
    ssh_case() {
        local description="$1" want="$2" shadow="$3"
        shift 3
        check "ssh: $description" grep -qx "PasswordAuthentication $want" <<< "$(run_hook "$shadow" "$@")"
    }
    ssh_case "password auth without a password is off" no '!' SSHD_PASSWORD_AUTH=1
    ssh_case "'*' account with password auth requested is off" no '*' SSHD_PASSWORD_AUTH=1
    ssh_case "empty SSHD_PASSWORD is off" no '!' SSHD_PASSWORD_AUTH=1 SSHD_PASSWORD=
    ssh_case "password auth stays on with a password" yes '!' SSHD_PASSWORD_AUTH=1 SSHD_PASSWORD=secret hash=abc
    ssh_case "default is off" no '!'
    ssh_case "account with an existing hash keeps password auth" yes '$6$salt$realhash' SSHD_PASSWORD_AUTH=1

    finish
}

# defaults: settings that stay opt-in so existing setups keep working (#456)
test_defaults() {
    cd "$BASE_DIR" || exit 1
    local wrapper=src/php/common/rootfs/usr/local/utils/msmtp-wrapper

    lacks "smtp: TLS is not forced when only a user or password is set" "$wrapper" '--tls=on'
    has "smtp: SMTP_TLS is passed to msmtp" "$wrapper" '--tls=$SMTP_TLS'
    lacks "nginx: no open_file_cache" src/php/with-nginx/rootfs/etc/nginx/nginx.conf 'open_file_cache'
    has "apache: request read timeout is off by default" src/php/with-apache/apache-config.dockerfile "APACHE_REQUEST_READ_TIMEOUT 'header=0 body=0'"
    lacks "php: session strict mode is not forced" src/php/common/php-ini-directives.dockerfile 'PHP_SESSION_USE_STRICT_MODE'

    finish
}

# size: the size helpers of build/helpers.sh, on a fixed manifest (offline)
test_size() {
    source "$BASE_DIR/build/helpers.sh"

    check_eq "manifest size is config plus layers" "600" \
        "$(echo '{"config":{"size":100},"layers":[{"size":200},{"size":300}]}' | manifest_size)"
    check_eq "manifest without layers is the config size" "100" \
        "$(echo '{"config":{"size":100}}' | manifest_size)"
    check_eq "invalid JSON gives no size" "" "$(echo 'not json' | manifest_size)"

    finish
}

# fingerprint: which files change the context hash of an image (offline, on a temporary copy)
test_fingerprint() {
    source "$BASE_DIR/build/helpers.sh"
    local tmp ctx
    tmp="$(mktemp -d)"
    cp -R "$BASE_DIR/src/php" "$tmp/php"
    ctx="$tmp/php"

    # Changes <file>: change the file, then print the images whose hash changed (base, nginx)
    changes() {
        local before after result=
        before="$(get_context_hash "$ctx" "$ctx/base-php.dockerfile") $(get_context_hash "$ctx" "$ctx/with-nginx.dockerfile")"
        echo "# changed" >> "$ctx/$1"
        after="$(get_context_hash "$ctx" "$ctx/base-php.dockerfile") $(get_context_hash "$ctx" "$ctx/with-nginx.dockerfile")"
        [ "${before% *}" = "${after% *}" ] || result="base"
        [ "${before#* }" = "${after#* }" ] || result="$result nginx"
        echo "${result# }"
    }
    check_eq "a common fragment changes both images" "base nginx" "$(changes common/php-extensions.dockerfile)"
    check_eq "nginx files change the nginx image only" "nginx" "$(changes with-nginx/rootfs/etc/nginx/nginx.conf)"
    check_eq "an nginx fragment changes the nginx image only" "nginx" "$(changes with-nginx/nginx-config.dockerfile)"
    check_eq "apache files change neither image" "" "$(changes with-apache/rootfs/etc/apache2/apache2.conf)"
    check_eq "a top level Dockerfile is hashed apart" "" "$(changes with-nginx.dockerfile)"
    check_eq "markdown does not change the hash" "" "$(changes common/NOTES.md)"

    rm -rf "$tmp"
    finish
}

# helpers: the pure functions of build/helpers.sh (offline, no network)
test_helpers() {
    source "$BASE_DIR/build/helpers.sh"
    local tmp
    tmp="$(mktemp -d)"

    # parse_json: first lines of a jq query, fails without a result
    check_eq "parse_json first value" "a" "$(parse_json '[{"n":"a"},{"n":"b"}]' 1 '.[].n')"
    check_eq "parse_json two values" "a b" "$(parse_json '[{"n":"a"},{"n":"b"}]' 2 '.[].n' | join_lines)"
    check_not "parse_json fails without a result" parse_json '[]' 1 '.[].n'

    # github_env: shell form outside Actions, the file and BUILD_ENV_FILE inside
    check_eq "github_env outside Actions" "FOO='a b'" "$(GITHUB_ENV= github_env FOO a b)"
    GITHUB_ENV="$tmp/env" BUILD_ENV_FILE="$tmp/build" github_env FOO a b >/dev/null
    check_eq "github_env writes GITHUB_ENV" "FOO=a b" "$(cat "$tmp/env")"
    check_eq "github_env writes BUILD_ENV_FILE" "FOO=a b" "$(cat "$tmp/build")"

    # path_hash: hidden files and Markdown do not count
    mkdir "$tmp/d"; echo 1 > "$tmp/d/a"; echo 2 > "$tmp/d/.hidden"; echo 3 > "$tmp/d/n.md"
    check_eq "path_hash lists one file" "1" "$(path_hash "$tmp/d" | wc -l | tr -d ' ')"

    # cache_file: the file lands in HELPER_CACHE_DIR
    download_file() { echo "$1" > "$2"; }
    HELPER_CACHE_DIR="$tmp/hc" cache_file "http://x/y" y.txt
    check_eq "cache_file puts the file in the cache" "http://x/y" "$(cat "$tmp/hc/y.txt")"

    # dockerhub_tag_missing: only the 404 answer of Docker Hub counts, with a stub of dockerhub_api (no network)
    tag_missing() { ( dockerhub_api() { [ -n "$API_ANSWER" ] && echo "$API_ANSWER"; }; API_ANSWER="$1"; dockerhub_tag_missing library/php 8.6-zts ); }
    check "dockerhub_tag_missing: a 404 answer is missing" tag_missing '{"message":"httperror 404: tag '"'"'8.6-zts'"'"' not found"}'
    check_not "dockerhub_tag_missing: a tag with a digest is not missing" tag_missing '{"name":"8.5-zts","digest":"sha256:abc"}'
    check_not "dockerhub_tag_missing: a rate limit is not missing" tag_missing '{"message":"httperror 429: too many requests"}'
    check_not "dockerhub_tag_missing: no answer is not missing" tag_missing ''

    # plan_matrix <platforms> <jq query on the first or second entry>
    plan() { plan_matrix "$1" | jq -r "$2"; }
    check_eq "plan_matrix: amd64 on x64" "ubuntu-26.04||linux-amd64" "$(plan linux/amd64 '.[0] | "\(.runner)|\(.qemu)|\(.slug)"')"
    check_eq "plan_matrix: arm64 on arm" "ubuntu-26.04-arm|" "$(plan linux/amd64,linux/arm64/v8 '.[1] | "\(.runner)|\(.qemu)"')"
    check_eq "plan_matrix: arm/v7 under QEMU" "arm" "$(plan linux/arm/v7 '.[0].qemu')"
    check_eq "plan_matrix: ppc64le under QEMU" "ppc64le" "$(plan linux/ppc64le '.[0].qemu')"
    check_eq "plan_matrix: empty list" "[]" "$(plan_matrix '')"

    # build_plan <platforms> [skip]: the lines are skip=... and matrix=...
    check_eq "build_plan: skip defaults to 0" "skip=0" "$(build_plan linux/amd64 | sed -n 1p)"
    check_eq "build_plan: skip=1 is kept" "skip=1" "$(build_plan linux/amd64 1 | sed -n 1p)"
    check_eq "build_plan: one entry per platform" "3" "$(build_plan linux/amd64,linux/arm/v7,linux/arm64/v8 0 | sed -n 2p | sed 's/^matrix=//' | jq length)"
    check_eq "build_plan: no platform skips" "skip=1" "$(build_plan '' 0 | sed -n 1p)"
    check_eq "build_plan: no platform keeps a dummy entry" "none" "$(build_plan '' 0 | sed -n 2p | sed 's/^matrix=//' | jq -r '.[0].slug')"

    # parse_ipe_unsupported: a module is unsupported when its line does not list the version
    local data='# comment
apcu 8.4 8.5
sodium 7.1
redis 8.4 8.5 8.6
gd 8.4 8.5 8.6
mbstring 8.6'
    unsupported() { echo "$data" | parse_ipe_unsupported "$1" | join_lines; }
    check_eq "parse_ipe_unsupported 8.6" "apcu sodium" "$(unsupported 8.6)"
    check_eq "parse_ipe_unsupported 8.5" "sodium mbstring" "$(unsupported 8.5)"
    check_eq "parse_ipe_unsupported ignores -rc" "apcu sodium" "$(unsupported 8.6-rc)"
    check_eq "parse_ipe_unsupported unknown version" "" "$(unsupported 9.0)"
    check_eq "parse_ipe_unsupported empty input" "" "$(printf '' | parse_ipe_unsupported 8.6)"

    # get_ipe_unsupported and get_php_skip_modules, with the data file seeded in the cache.
    # download_file fails, so a cache older than 2 hours gives nothing (nothing is skipped).
    mkdir -p "$tmp/ipe"
    seed() { echo "$data" > "$tmp/ipe/ipe-supported-extensions"; }
    ipe() { (download_file() { return 1; }; HELPER_CACHE_DIR="$tmp/ipe" "$@" | join_lines); }
    seed
    check_eq "get_ipe_unsupported uses a fresh cache" "apcu sodium" "$(ipe get_ipe_unsupported 8.6)"
    check_eq "get_php_skip_modules keeps the modules of the image" "apcu sodium" "$(ipe get_php_skip_modules 8.6)"
    check_eq "get_php_skip_modules without a column" "" "$(ipe get_php_skip_modules 9.9)"
    touch -t 202001010000 "$tmp/ipe/ipe-supported-extensions"
    check_eq "get_ipe_unsupported ignores a cache older than 2 hours" "" "$(ipe get_ipe_unsupported 8.6)"

    # php-extensions.dockerfile: the skip filter drops unsupported modules, but never one PHP already has
    local filter
    filter="$(awk '/^# Skip the modules/{f=1} f{print} f&&/^fi$/{exit}' "$BASE_DIR/src/php/common/php-extensions.dockerfile")"
    check "skip filter block found" test -n "$filter"
    skipped() { # <skip list> <loaded modules>: the modules left after the filter
        bash -c 'loaded=" $2 "; php() { [[ "$loaded" == *" $3 "* ]]; }; modules=(apcu mbstring sodium gd); PHP_SKIP_MODULES="$1"; PHP_VERSION=8.6
'"$filter"'
echo "${modules[*]}"' _ "$1" "$2" 2>/dev/null | tail -1
    }
    check_eq "skip filter drops unsupported modules" "sodium gd" "$(skipped 'apcu mbstring sodium' 'sodium')"
    check_eq "skip filter keeps a module PHP has" "mbstring sodium gd" "$(skipped 'apcu mbstring sodium' 'mbstring sodium')"
    check_eq "skip filter without a list changes nothing" "apcu mbstring sodium gd" "$(skipped '' 'sodium')"

    # cache_run_inputs and cache_server_digests: which digests they look up (stubs, no network)
    cache_dockerhub_digest() { echo "$*"; }
    get_github_latest_tag() { :; }; cache_middleware_sources() { :; }; cache_apache_source() { :; }
    cache_nginx_source() { :; }; cache_s6_sources() { :; }; cache_wpcli_source() { :; }
    local lookups expected
    lookups="$(cache_run_inputs 8.5 7.0 2>/dev/null)"
    for expected in "library/php 8.5-cli" "library/php 7.0-zts" "library/alpine latest" "library/ubuntu latest" \
        "dunglas/frankenphp 1-php8.5" "dunglas/frankenphp 1-php8.5-alpine"; do
        check "cache_run_inputs looks up '$expected'" grep -qxF "$expected" <<< "$lookups"
    done
    check_not "cache_run_inputs: no frankenphp image for PHP before 8.2" grep -qF "dunglas/frankenphp 1-php7.0" <<< "$lookups"
    lookups="$(cache_server_digests dev- 8.5 7.0)"
    for expected in "shinsenter/phpfpm-nginx dev-php8.5" "shinsenter/phpfpm-apache dev-php7.0" "shinsenter/roadrunner dev-php8.5-alpine"; do
        check "cache_server_digests looks up '$expected'" grep -qxF "$expected" <<< "$lookups"
    done
    check_not "cache_server_digests: no alpine image for PHP 7.0" grep -qF "dev-php7.0-alpine" <<< "$lookups"
    unset -f cache_dockerhub_digest get_github_latest_tag cache_middleware_sources cache_apache_source \
        cache_nginx_source cache_s6_sources cache_wpcli_source
    source "$BASE_DIR/build/helpers.sh"

    rm -rf "$tmp"
    finish
}

# scan: build/scan-images.sh with a stub of docker (no Trivy, no network)
test_scan() {
    local tmp stub
    tmp="$(mktemp -d)"
    stub="$tmp/bin"
    mkdir -p "$stub"
    trap 'rm -rf "$tmp"' RETURN

    # docker stub: logs the call, "bad" images have CVEs (exit 10), "broken" images fail (exit 1)
    cat > "$stub/docker" <<'EOF'
#!/bin/sh
echo "$*" >> "$DOCKER_LOG"
case "$*" in
    *--download-db-only*) exit 0 ;;
    *bad*)    echo "TABLE of $*"; exit 10 ;;
    *broken*) echo "boom" >&2; exit 1 ;;
esac
exit 0
EOF
    chmod +x "$stub/docker"

    printf '%s\n' ghcr.io/x/good:1 ghcr.io/x/bad:1 ghcr.io/x/broken:1 ghcr.io/x/good:1 > "$tmp/list"
    : > "$tmp/log"
    PATH="$stub:$PATH" DOCKER_LOG="$tmp/log" GITHUB_STEP_SUMMARY="$tmp/summary" \
        "$BASE_DIR/build/scan-images.sh" "$tmp/list" 2 >/dev/null 2>&1
    check_eq "scan: the database is downloaded once" "1" "$(grep -c -e '--download-db-only' "$tmp/log")"
    check_eq "scan: a duplicate image is scanned once" "1" "$(grep -c 'good:1' "$tmp/log")"
    check_eq "scan: every unique image is scanned with the shared database" "3" "$(grep -c -e '--skip-db-update' "$tmp/log")"
    has "scan: an image with CVEs is listed" "$tmp/summary" "Vulnerabilities in ghcr.io/x/bad:1"
    lacks "scan: a clean image is not listed" "$tmp/summary" "Vulnerabilities in ghcr.io/x/good:1"
    has "scan: a failed scan is reported" "$tmp/summary" "scan failed: ghcr.io/x/broken:1"
    has "scan: the totals count unique images" "$tmp/summary" "1 of 3 images"

    : > "$tmp/empty"
    check "scan: an empty list is not an error" env PATH="$stub:$PATH" DOCKER_LOG="$tmp/log" "$BASE_DIR/build/scan-images.sh" "$tmp/empty"
    finish
}

# updates: the start and cleanup commands of build/check-updates.sh, with a stub of the GitHub CLI (offline)
test_updates() {
    local tmp stub
    tmp="$(mktemp -d)"
    stub="$tmp/bin"
    mkdir -p "$stub"
    trap 'rm -rf "$tmp"' RETURN

    # gh stub: logs the call, answers the list queries from GH_ACTIVE, GH_LAST and GH_IDS
    cat > "$stub/gh" <<'EOF'
#!/bin/sh
echo "$*" >> "$GH_LOG"
case "$*" in
    *"--limit 20"*)   echo "$GH_ACTIVE" ;;
    *"--limit 1 "*)   echo "$GH_LAST" ;;
    *"--limit 1000"*) printf '%s\n' $GH_IDS ;;
esac
EOF
    chmod +x "$stub/gh"

    # iso_ago <seconds>: the time that long ago, like createdAt of a run
    iso_ago() { local t=$(($(date +%s) - $1)); date -u -d "@$t" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -r "$t" +%Y-%m-%dT%H:%M:%SZ; }
    # run_updates <active runs> <createdAt of the last failed run> <ids> <command...>: prints the calls that change something
    run_updates() {
        local active="$1" last="$2" ids="$3"
        shift 3
        : > "$tmp/log"
        PATH="$stub:$PATH" GH_LOG="$tmp/log" GH_ACTIVE="$active" GH_LAST="$last" GH_IDS="$ids" \
            bash -c 'source "$1"; shift; "$@"' _ "$BASE_DIR/build/check-updates.sh" "$@" >/dev/null 2>&1
        grep -E '^(workflow run|run delete)' "$tmp/log" | join_lines
    }

    check_eq "start: a running build is not started again" "" "$(run_updates 2 '' '' start_build "8.5")"
    check_eq "start: a build that failed an hour ago is not retried" "" "$(run_updates 0 "$(iso_ago 3600)" '' start_build "8.5")"
    check_eq "start: a build that failed 4 hours ago is started" \
        "workflow run build-all.yml --ref main -f php_versions=8.5 8.4" "$(run_updates 0 "$(iso_ago 14400)" '' start_build "8.5 8.4")"
    check_eq "start: no earlier failure starts the build" \
        "workflow run build-all.yml --ref main -f php_versions=8.5" "$(run_updates 0 '' '' start_build "8.5")"

    check_eq "cleanup: deletes each run" "run delete 11 run delete 12" "$(run_updates 0 '' '11 12' cleanup_runs 3)"
    check_eq "cleanup: a bad number deletes nothing" "" "$(run_updates 0 '' '11' cleanup_runs abc)"
    check_not "cleanup: a bad number fails" bash -c 'source "$1"; cleanup_runs abc' _ "$BASE_DIR/build/check-updates.sh"

    finish
}

# Each test runs in a subshell: its counters and sourced files stay private
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    status=0
    for name in ${@:-lint versions backports config scaling ssh defaults size fingerprint helpers updates scan}; do
        echo "== $name"
        (NAME="$name"; "test_$name") || status=1
    done
    exit $status
fi

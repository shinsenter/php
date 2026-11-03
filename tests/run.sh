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
#   tests/run.sh versions        run one: lint, versions, backports, config, scaling
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

# check "<description>" <command...>: passes when the command succeeds
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

# versions: build/versions.sh and the version helpers of build/helpers.sh.
test_versions() {
    source "$BASE_DIR/build/helpers.sh"
    source "$BASE_DIR/build/versions.sh"

    # Lists
    check "maintained list is not empty" [ "${#MAINTAINED_PHP_VERSIONS[@]}" -gt 0 ]
    check "outdated list is not empty" [ "${#OUTDATED_PHP_VERSIONS[@]}" -gt 0 ]
    check_eq "ALL_PHP_VERSIONS size" \
        "$((${#MAINTAINED_PHP_VERSIONS[@]} + ${#OUTDATED_PHP_VERSIONS[@]}))" \
        "${#ALL_PHP_VERSIONS[@]}"
    check_eq "duplicated versions" "" \
        "$(printf '%s\n' "${ALL_PHP_VERSIONS[@]}" | sort | uniq -d)"

    for outdated in "${OUTDATED_PHP_VERSIONS[@]}"; do
        check "$outdated is outdated" is_outdated_php "$outdated"
        for maintained in "${MAINTAINED_PHP_VERSIONS[@]}"; do
            check "$outdated is older than $maintained" verlt "$outdated" "$maintained"
        done
    done
    for maintained in "${MAINTAINED_PHP_VERSIONS[@]}"; do
        check_not "$maintained is not outdated" is_outdated_php "$maintained"
    done
    check_not "unknown version is not outdated" is_outdated_php "9.9"

    # Alpine images start at PHP 7.1
    check_not "alpine 5.6" has_alpine_php 5.6
    check_not "alpine 7.0" has_alpine_php 7.0
    check "alpine 7.1" has_alpine_php 7.1
    check "alpine 7.4" has_alpine_php 7.4
    check "alpine 8.5" has_alpine_php 8.5
    check "alpine 8.6-rc" has_alpine_php 8.6-rc

    # Version compare
    check "verlte 7.4 8.0" verlte 7.4 8.0
    check "verlte 8.0 8.0" verlte 8.0 8.0
    check_not "verlte 8.1 8.0" verlte 8.1 8.0
    check "verlt 7.9 7.10" verlt 7.9 7.10
    check_not "verlt 8.0 8.0" verlt 8.0 8.0
    check "verlt 8.5 8.6-rc" verlt 8.5 8.6-rc
    check "active 8.3" is_active_version 8.3
    check_not "active 8.2" is_active_version 8.2
    check_not "active 7.4" is_active_version 7.4

    # Nginx keywords, with a stub of the download page (no network)
    fetch_with_cache() {
        echo '<h4>Mainline version</h4><table><tr><td><a href="/download/nginx-1.31.8.tar.gz">nginx-1.31.8</a></td></tr></table><h4>Stable version</h4><table><tr><td><a href="/download/nginx-1.30.6.tar.gz">nginx-1.30.6</a></td></tr></table><h4>Legacy versions</h4><a href="/download/nginx-1.28.3.tar.gz">'
    }
    check_eq "nginx mainline" "1.31.8" "$(resolve_nginx_version mainline)"
    check_eq "nginx stable" "1.30.6" "$(resolve_nginx_version stable)"
    check_eq "nginx number" "1.29.0" "$(resolve_nginx_version 1.29.0)"
    check_eq "nginx os" "os" "$(resolve_nginx_version os)"
    check_eq "nginx empty" "" "$(resolve_nginx_version '')"
    unset -f fetch_with_cache

    # Helper cache downloads, with stubs (no network)
    local cache_dir
    cache_dir="$(mktemp -d)"
    HELPER_CACHE_DIR="$cache_dir"
    resolve_nginx_version() { echo 1.31.8; }
    get_github_latest_tag() { echo v3.2.1.0; }
    download_file() { echo "$1" >"$2"; }
    fetch_with_cache() { echo "bad  wp-cli.phar"; }

    cache_nginx_source 2>/dev/null
    check "cache: nginx source" [ -f "$cache_dir/nginx-1.31.8.tar.gz" ]
    cache_s6_sources 2>/dev/null
    check "cache: s6 noarch" [ -f "$cache_dir/s6-v3.2.1.0-s6-overlay-noarch.tar.xz" ]
    check "cache: s6 syslogd" [ -f "$cache_dir/s6-v3.2.1.0-syslogd-overlay-noarch.tar.xz" ]
    check "cache: s6 x86_64" [ -f "$cache_dir/s6-v3.2.1.0-s6-overlay-x86_64.tar.xz" ]
    check "cache: s6 aarch64" [ -f "$cache_dir/s6-v3.2.1.0-s6-overlay-aarch64.tar.xz" ]
    cache_wpcli_source 2>/dev/null
    check_not "cache: wp-cli with a wrong checksum is removed" [ -f "$cache_dir/wp-cli.phar" ]
    download_file() { echo "phar" >"$2"; }
    fetch_with_cache() { echo "$(echo phar | shasum -a 512 | awk '{print $1}')  wp-cli.phar"; }
    cache_wpcli_source 2>/dev/null
    check "cache: wp-cli with a matching checksum is kept" [ -f "$cache_dir/wp-cli.phar" ]
    NGINX_VERSION=os; resolve_nginx_version() { echo os; }
    rm -f "$cache_dir"/nginx-*
    cache_nginx_source 2>/dev/null
    check_eq "cache: nginx os is not downloaded" "" "$(ls "$cache_dir" | grep '^nginx-' || true)"
    rm -rf "$cache_dir"
    unset -f fetch_with_cache download_file get_github_latest_tag resolve_nginx_version
    source "$BASE_DIR/build/helpers.sh"

    finish
}

# backports: rules for src/php-backports/ (see .claude/docs/backports.md).
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

    finish
}

# scaling: files that make the images work behind Kubernetes, load balancers and Traefik.
test_scaling() {
    cd "$BASE_DIR" || exit 1
    local nginx=src/php/with-nginx apache=src/php/with-apache common=src/php/common

    check "nginx: health server on HEALTH_PORT" grep -q 'listen ${HEALTH_PORT};' "$nginx/rootfs/etc/hooks/server/init-nginx"
    check "nginx: /healthz" grep -q 'location = /healthz' "$nginx/rootfs/etc/hooks/server/init-nginx"
    check "nginx: /readyz uses the FPM ping path" grep -q 'SCRIPT_NAME *${PING_PATH}' "$nginx/rootfs/etc/hooks/server/init-nginx"
    check_not "nginx: no health paths on the main port" grep -q 'healthz\|readyz' "$nginx/rootfs/etc/nginx/custom.d/01-common.conf"
    check "nginx: HTTPS from X-Forwarded-Proto" grep -q 'x_forwarded_proto' "$nginx/rootfs/etc/nginx/custom.d/00-proxy-proto.conf"
    check "nginx: php location passes HTTPS" grep -q 'fastcgi_param HTTPS *\$client_https' "$nginx/rootfs/etc/nginx/custom.d/01-common.conf"
    check "nginx: TRUSTED_PROXIES" grep -q 'TRUSTED_PROXIES' "$nginx/rootfs/etc/hooks/server/init-nginx"
    check "nginx: proxies.d is included" grep -q 'proxies.d/\*.conf' "$nginx/rootfs/etc/nginx/nginx.conf"
    check "nginx: proxies.d is created" grep -q '/etc/nginx/proxies.d' "$nginx/nginx-config.dockerfile"
    check "nginx: graceful stop signal" grep -q 'down-signal SIGQUIT' "$nginx/nginx-config.dockerfile"
    check "nginx: HEALTH_CHECK_URL" grep -q "HEALTH_CHECK_URL 'http://127.0.0.1:\${HEALTH_PORT}/healthz'" "$nginx/nginx-config.dockerfile"
    check "nginx: real_ip fallback keeps the proxy file valid" grep -q '00-proxy-proto.conf' "$nginx/rootfs/etc/hooks/post-build/00-fix-nginx"

    check "apache: health vhost on HEALTH_PORT" grep -q 'VirtualHost \*:${HEALTH_PORT}' "$apache/rootfs/etc/apache2/sites-enabled/01-health.conf"
    check "apache: /healthz" grep -q 'healthz' "$apache/rootfs/etc/apache2/sites-enabled/01-health.conf"
    check "apache: /readyz" grep -q '"/readyz"' "$apache/rootfs/etc/apache2/sites-enabled/01-health.conf"
    check "apache: HTTPS from X-Forwarded-Proto" grep -q 'X-Forwarded-Proto' "$apache/rootfs/etc/apache2/apache2.conf"
    check "apache: TRUSTED_PROXIES" grep -q 'TRUSTED_PROXIES' "$apache/rootfs/etc/hooks/server/init-apache"
    check "apache: graceful stop signal" grep -q 'down-signal SIGWINCH' "$apache/apache-config.dockerfile"
    check "apache: HEALTH_CHECK_URL" grep -q "HEALTH_CHECK_URL 'http://127.0.0.1:\${HEALTH_PORT}/healthz'" "$apache/apache-config.dockerfile"

    check "frankenphp: health site on its own port" grep -q 'http://:{$HEALTH_PORT:2020}' src/php/with-f8p/rootfs/etc/caddy/Caddyfile
    check "frankenphp: HEALTH_CHECK_URL" grep -q 'HEALTH_CHECK_URL .*HEALTH_PORT}/healthz' src/php/with-f8p/f8p-config.dockerfile
    check "frankenphp: trusted proxies" grep -q 'trusted_proxies static private_ranges' src/php/with-f8p/rootfs/etc/caddy/Caddyfile
    check "frankenphp: TRUSTED_PROXIES" grep -q 'CADDY_TRUSTED_PROXIES' src/php/with-f8p/rootfs/etc/hooks/server/init-f8p
    check "frankenphp: grace period" grep -q 'grace_period' src/php/with-f8p/rootfs/etc/caddy/Caddyfile
    check "roadrunner: status plugin" grep -q 'status.address=0.0.0.0:${HEALTH_PORT:-2020}' src/php/with-roadrunner/roadrunner-config.dockerfile
    check "roadrunner: HEALTH_CHECK_URL" grep -q 'HEALTH_CHECK_URL .*HEALTH_PORT}/health?plugin=http' src/php/with-roadrunner/roadrunner-config.dockerfile
    check "health port: every image sets HEALTH_PORT 2020" test "$(grep -l "HEALTH_PORT *'2020'" src/php/with-*/*-config.dockerfile | wc -l | tr -d ' ')" = 4
    for image in nginx apache f8p roadrunner; do
        check_not "$image: health port is not exposed" grep -qE '^EXPOSE (2020|2114)$' "src/php/with-$image.dockerfile"
    done
    check "roadrunner: TRUSTED_PROXIES" grep -q 'trusted_subnets' src/php/with-roadrunner/rootfs/etc/hooks/server/init-roadrunner

    # the images have no active HEALTHCHECK, only a commented example that reads HEALTH_CHECK_URL
    for image in nginx apache f8p roadrunner; do
        check_not "$image: no active HEALTHCHECK" grep -q '^HEALTHCHECK' "src/php/with-$image.dockerfile"
        check "$image: HEALTHCHECK example" grep -q '^# *CMD with-env sh -c .curl -sf "$HEALTH_CHECK_URL"' "src/php/with-$image.dockerfile"
    done
    check "compose: healthcheck reads HEALTH_CHECK_URL" grep -q 'HEALTH_CHECK_URL' tests/docker-compose.scaling.yml

    # every web server registers itself as a dependency of the shutdown delay
    for config in with-nginx/nginx-config with-apache/apache-config with-f8p/f8p-config with-roadrunner/roadrunner-config; do
        check "$config: shutdown-delay dependency" grep -q 's6-service shutdown-delay requires' "src/php/$config.dockerfile"
    done
    for image in nginx apache f8p roadrunner; do
        check "$image: includes web-shutdown-delay" grep -q 'INCLUDE ./common/web-shutdown-delay' "src/php/with-$image.dockerfile"
    done
    check "web-shutdown-delay fragment" test -f "$common/web-shutdown-delay.dockerfile"

    check "php-fpm: graceful stop signal" grep -q 'down-signal SIGQUIT' "$common/php-extensions.dockerfile"
    check "s6-service: down-signal type" grep -q 'down|finish|down-signal)' "$common/rootfs/usr/local/utils/s6-service"
    check "shutdown delay hook is executable" test -x "$common/rootfs/etc/hooks/s6-exit-shutdown-delay/00-delay"
    check "shutdown delay default" grep -q "SHUTDOWN_DELAY '0'" "$common/web-shutdown-delay.dockerfile"

    # the stop timeout must stay below the 30 s that Kubernetes waits by default
    for name in S6_KILL_GRACETIME S6_SERVICES_GRACETIME; do
        value="$(sed -n "s/.*env-default $name \([0-9]*\).*/\1/p" "$common/os-s6-overlay.dockerfile")"
        check "$name is between 10000 and 29000 (got '$value')" test "${value:-0}" -ge 10000 -a "${value:-0}" -le 29000
    done

    check "docs: scaling.md" test -f .claude/docs/scaling.md
    check "compose: scaling file" test -f tests/docker-compose.scaling.yml
    check "scaling-test.sh is executable" test -x tests/scaling-test.sh

    finish
}

# Each test runs in a subshell: its counters and sourced files stay private.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    status=0
    for name in ${@:-lint versions backports config scaling}; do
        echo "== $name"
        (NAME="$name"; "test_$name") || status=1
    done
    exit $status
fi

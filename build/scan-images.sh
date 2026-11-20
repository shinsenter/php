#!/usr/bin/env bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Scan a list of images with Trivy and write the HIGH and CRITICAL findings to the job summary.
# It only reports: the exit code is 0 even when CVEs are found.
# The vulnerability database is downloaded once and shared by all scans, so a long list costs one download.
#
# Usage: build/scan-images.sh <list file> [parallel scans]
#   list file       one image per line, for example ghcr.io/shinsenter/phpfpm-nginx:latest
#   parallel scans  default: the number of CPUs
# TRIVY_IMAGE overrides the Trivy image. The result goes to $GITHUB_STEP_SUMMARY, or to stdout outside Actions.
set -u

LIST="${1:?Usage: ${0##*/} <list file> [parallel scans]}"
JOBS="${2:-$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)}"
TRIVY_IMAGE="${TRIVY_IMAGE:-ghcr.io/aquasecurity/trivy:latest}"
# The summary of a job is limited to 1 MiB, one image can fill about 20 kB of it
SUMMARY_LIMIT=900000
IMAGE_LIMIT=20000

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/cache" "$WORK/out"
export WORK TRIVY_IMAGE

[ -s "$LIST" ] || { echo "No image to scan"; exit 0; }

# Download the database once
echo "Download the Trivy database"
docker run --rm -v "$WORK/cache:/root/.cache/trivy" "$TRIVY_IMAGE" image --download-db-only --quiet \
    || { echo "::warning::Cannot download the Trivy database, no image is scanned"; exit 0; }

# Scan one image, the database is read-only and shared. The exit code goes to <name>.rc (10 = CVEs found)
scan_one() {
    local image="$1" name rc=0
    name="$WORK/out/$(printf '%s' "$image" | tr '/:' '__')"
    docker run --rm -v "$WORK/cache/db:/root/.cache/trivy/db:ro" "$TRIVY_IMAGE" image \
        --skip-db-update --platform linux/amd64 --quiet --scanners vuln --severity HIGH,CRITICAL \
        --ignore-unfixed --timeout 10m --exit-code 10 --format table "$image" >"$name.txt" 2>"$name.err" || rc=$?
    echo "$image" >"$name.img"
    echo "$rc" >"$name.rc"
    echo "$image: exit $rc"
}
export -f scan_one

echo "Scan $(sort -u "$LIST" | wc -l | tr -d ' ') images, $JOBS at a time"
sort -u "$LIST" | xargs -P "$JOBS" -I{} bash -c 'scan_one "$1"' _ {}

# Summary: the images with findings, then the scans that failed
found=0 failed=0 size=0 report="$WORK/report.md"
: >"$report"
for rc_file in "$WORK"/out/*.rc; do
    [ -e "$rc_file" ] || continue
    base="${rc_file%.rc}"
    image="$(cat "$base.img")"
    case "$(cat "$rc_file")" in
        0) ;;
        10)
            found=$((found + 1))
            if [ "$size" -lt "$SUMMARY_LIMIT" ]; then
                {
                    echo "### Vulnerabilities in $image (HIGH and CRITICAL, fixed upstream)"
                    echo '```'
                    head -c "$IMAGE_LIMIT" "$base.txt"
                    echo '```'
                } >>"$report"
                size="$(wc -c <"$report" | tr -d ' ')"
            fi
            ;;
        *) failed=$((failed + 1)); echo "- scan failed: $image ($(head -c 200 "$base.err" | tr '\n' ' '))" >>"$WORK/failed.md" ;;
    esac
done

{
    echo "## Trivy scan: $found of $(sort -u "$LIST" | wc -l | tr -d ' ') images have fixable HIGH or CRITICAL CVEs, $failed scans failed"
    cat "$report"
    [ ! -s "$WORK/failed.md" ] || { echo "### Failed scans"; cat "$WORK/failed.md"; }
} >>"${GITHUB_STEP_SUMMARY:-/dev/stdout}"
exit 0

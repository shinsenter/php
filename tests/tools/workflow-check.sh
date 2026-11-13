#!/bin/sh
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Static check of the GitHub Actions files, no run needed:
# actionlint (syntax, expressions, shell in run steps) and zizmor (security).
# It needs Docker, mounts the repository read-only and changes nothing. Exit 1 when either finds a problem.
# zizmor reports medium and high findings only: the low ones are advice (for example persist-credentials on checkout).
# Settings: .github/actionlint.yaml and .github/zizmor.yml.
#
# Usage: tests/tools/workflow-check.sh

BASE_DIR="$(git rev-parse --show-toplevel)"
status=0

echo "== actionlint"
docker run --rm -v "$BASE_DIR":/repo:ro -w /repo rhysd/actionlint:latest -color || status=1

echo "== zizmor"
docker run --rm -v "$BASE_DIR":/repo:ro -w /repo ghcr.io/zizmorcore/zizmor:latest --no-progress --min-severity medium .github || status=1

exit $status

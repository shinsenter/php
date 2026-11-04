<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Tests (details)

Extra notes for `tests/`. The run commands are in `CLAUDE.md`.

Which test to run:

| Changed | Run |
|---|---|
| Any shell script, hook or util | `run.sh lint` |
| `build/versions.sh`, `build/helpers.sh` | `run.sh versions` |
| `src/php-backports/` (patch, README) | `run.sh backports` |
| `build/config.sh` | `run.sh config` |
| Web server config, health checks, shutdown (`with-*`, `s6` defaults) | `run.sh scaling` |
| Anything else in `build/`, or unsure | `run.sh` |

Each test prints `<name>: N passed, M failed`, prints a `FAIL:` line per failed check and exits non-zero on failure.
Do not edit a backport patch to satisfy a test without asking, because it changes the fingerprint of every image of that version.
Checks that need no build: `sh -n`, `bash -n`, `git apply --check`, `git diff`.

- Add a test: add a `test_<topic>` function to `tests/run.sh`, use `check`, `check_not`, `check_eq`, `check_re`, end with `finish`, then add `<topic>` to the default list at the bottom. Keep it offline: no `docker`, no network.
- The `config` test runs only the paths of `build/config.sh` that end before any network call (Alpine on PHP below 7.1). Do not add cases that reach the registry or GitHub API.
- Not covered, so still ask the user for a run: `patch -p1 --dry-run` on a source tree, image contents, runtime behavior of hooks and utils (`realpath -m` needs GNU, so `app-root` does not run on macOS). Use `tests/build-test.sh` and `tests/compose-test.sh` for those (see Working rules).
- `tests/scaling-test.sh <image> [replicas]` is a Docker test: Traefik in front of replicas (`tests/docker-compose.scaling.yml`, app in `tests/scaling/`). The offline part is `tests/run.sh scaling`. See `.claude/docs/scaling.md`.
- `tests/tools/` holds helpers (`act-dryrun.sh`, `sbom.sh`), not tests. `tests/logs/` is git-ignored output of the Docker tests. File names are `<YYYYMMDD>-<script>-...`, so `ls` sorts by test day.

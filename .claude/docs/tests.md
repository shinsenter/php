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

| Changed | Run |
|---|---|
| Any shell script, hook or util | `run.sh lint` |
| `build/versions.sh`, `build/helpers.sh` | `run.sh versions` |
| `src/php-backports/` (patch, README) | `run.sh backports` |
| `build/config.sh` | `run.sh config` |
| Context hash in `build/helpers.sh` (`get_context_hash`) | `run.sh fingerprint` |
| Size helpers in `build/helpers.sh` | `run.sh size` |
| Other pure functions in `build/helpers.sh` | `run.sh helpers` |
| `00-ssh-server` hook | `run.sh ssh` |
| Web server config, health checks, shutdown (`with-*`, `s6` defaults) | `run.sh scaling` |
| Anything else in `build/`, or unsure | `run.sh` |

Each test prints `<name>: N passed, M failed`, a `FAIL:` line per failed check, and exits non-zero on failure.
Do not edit a backport patch to satisfy a test without asking. It changes the fingerprint of every image of that version.
Checks that need no build: `sh -n`, `bash -n`, `git apply --check`, `git diff`.

- Add a test: write a `test_<topic>` function in `tests/run.sh`, use `check`, `check_not`, `check_eq`, `check_re`, end with `finish`, then add `<topic>` to the default list at the bottom. Keep it offline: no `docker`, no network.
- The `config` test runs only the paths of `build/config.sh` that end before a network call (Alpine on PHP below 7.1). Do not add cases that reach the registry or the GitHub API.
- Not covered, so ask the user for a run: `patch -p1 --dry-run` on a source tree, image contents, and the runtime behavior of hooks and utils (`realpath -m` needs GNU, so `app-root` does not run on macOS). Use `tests/build-test.sh` and `tests/compose-test.sh`.
- `tests/compose-test.sh` passes a container on any HTTP answer. With `-s` it follows redirects and passes only on 2xx, which suits webapps that redirect to an installer.
- `tests/docker-compose.yml` has a `mysql` service (MariaDB, in memory) that webapps with `depends_on` share. `compose-test.sh` starts it with them, leaves it out of the default list and removes it after each batch. A webapp that needs setup before `/` answers gets a hook in `tests/compose-hooks/`, mounted into `/etc/hooks/post-create-project/` (Sulu and Craft CMS do). The project is still owned by root when the hook runs, so a hook starts with `web-chown fix "$APP_PATH"`.
- `compose-test.sh` pulls the image first, so a local build with the same tag as a published one is replaced. Retag the build with a tag that does not exist on ghcr and pass it with `IMAGE_TAG=`.
- `tests/scaling-test.sh <image> [replicas]` is a Docker test: Traefik in front of replicas (`tests/docker-compose.scaling.yml`, app in `tests/scaling/`). Its offline part is `tests/run.sh scaling`. See `.claude/docs/scaling.md`.
- `tests/tools/` holds helpers (`sbom.sh`, `image-slim-check.sh`, `workflow-check.sh`), not tests. `workflow-check.sh` runs actionlint and zizmor on `.github/` through Docker (read-only) and needs no workflow run. After a workflow change, run it and keep it at exit 0. `tests/logs/` is git-ignored output of the Docker tests, named `<YYYYMMDD>-<script>-...` so `ls` sorts by test day.

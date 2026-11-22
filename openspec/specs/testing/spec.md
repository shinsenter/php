<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->


# Tests

## Purpose

Run commands: `AGENTS.md`. Each test prints `<name>: N passed, M failed`, a `FAIL:` line per failure, and exits non-zero on failure.

## Which test for which change
| Changed | Run |
|---|---|
| Shell script, hook, util | `run.sh lint` |
| `build/versions.sh`, `build/helpers.sh` | `run.sh versions` |
| `src/php-backports/` | `run.sh backports` |
| `build/config.sh` | `run.sh config` |
| `build/check-updates.sh` (start, cleanup, with a stub of `gh`) | `run.sh updates` |
| `get_context_hash` | `run.sh fingerprint` |
| Size helpers in `build/helpers.sh` | `run.sh size` |
| Other pure functions in `build/helpers.sh` | `run.sh helpers` |
| `00-ssh-server` hook | `run.sh ssh` |
| Web server config, health, shutdown (`with-*`, `s6` defaults) | `run.sh scaling` |
| Anything else in `build/`, or unsure | `run.sh` |

## Requirements


### Requirement: Test selection and Docker tests

The repo SHALL follow these rules for: test selection and docker tests.

#### Scenario: Test selection and Docker tests
- **WHEN** this area is changed
- **THEN** all of the following hold:
- A failing check SHALL be treated as a finding: fix the cause or tell the user. MUST NOT edit a test (or a backport patch) to make it pass without asking.
- Add a test: write `test_<topic>` in `tests/run.sh` with `check`, `check_not`, `check_eq`, `check_re`, `has`, `lacks` (a file holds a text or not) and `join_lines`, end with `finish`, add `<topic>` to the default list at the bottom. It SHALL stay offline (no `docker`, no network).
- Test the contract (ports, paths, defaults, behavior with stubs), not how a file is written: a check that greps an implementation detail breaks on every refactor. Group similar checks in a loop or a small function.
- The `config` test runs only the paths of `build/config.sh` that end before a network call (Alpine on PHP below 7.1). MUST NOT add cases that reach the registry or GitHub API.
- No-build checks: `sh -n`, `bash -n`, `git apply --check`, `git diff`.
- A local Docker test SHALL run the squash step (no `SKIP_SQUASH=1`), because the cleanup hooks run only there and `apt-get full-upgrade` can put OS packages back over the ones built from source (#479). After the build, check the version and the config of what was built from source (`apache2 -v` shows `Unix` for a source build, `apache2 -t`). `SKIP_SQUASH=1` is for a quick syntax check of a Dockerfile only, and MUST NOT back a claim that an image works.
- Not covered offline, ask the user for a run: `patch -p1 --dry-run` on a source tree, image contents, hook and util runtime (`realpath -m` needs GNU, so `app-root` fails on macOS). Use `tests/build-test.sh`, `tests/compose-test.sh`.

## Docker test notes
- `compose-test.sh` passes a container on any HTTP answer; with `-s` it follows redirects and passes only on 2xx (webapps that redirect to an installer).
- `tests/docker-compose.yml` has a shared in-memory `mysql` (MariaDB) service for webapps with `depends_on`; `compose-test.sh` starts it with them, leaves it out of the default list, removes it after each batch.
- A webapp needing setup before `/` answers gets a hook in `tests/compose-hooks/`, mounted into `/etc/hooks/post-create-project/` (Sulu, Craft CMS). The project is root-owned then, so the hook starts with `web-chown fix "$APP_PATH"`.
- `compose-test.sh` pulls the image first and replaces a local build with a published tag. Retag the build to a tag absent from ghcr and pass `IMAGE_TAG=`.
- `tests/scaling-test.sh`: see `openspec/specs/scaling/spec.md`.
- The `Compose test` workflow (`compose-test.yml`, manual, after a release build) pulls the published images and runs `compose-test.sh -n 1` for each service and OS in its own job (default: the `latest` tags, all services). `TAG_PREFIX` is `dev-` by default in the script and empty in the workflow input. A failed check never fails the run, the result goes to the job summary.
- `tests/tools/` holds helpers, not tests: `sbom.sh`, `image-slim-check.sh`, `cve-fix.sh` (trivy scan of the published images, then one Claude Code call to fix the cause), `workflow-check.sh` (actionlint and zizmor on `.github/` through Docker, read-only, no workflow run). `tests/logs/` is git-ignored, named `<YYYYMMDD>-<script>-...`.

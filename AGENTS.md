# AGENTS.md

Project context for coding agents and human contributors. Update it when a decision or the layout changes.

## Project

Docker images for PHP (shinsenter/php), built on the official `php` image. PHP 5.6 to 8.6, Debian and Alpine. Variants: `cli`, `zts`, `fpm`, `fpm-apache`, `fpm-nginx`, `roadrunner`, `frankenphp`, plus the webapp images in `src/webapps/`.

Environment variables change PHP and FPM settings, so a change needs no rebuild. `build/docker-squash` slims the images.

## Design principles

- Reuse code. One mechanism serves every PHP version, with no per-version branches in the logic.
- Same behavior across PHP versions. Differences live in data, such as a per-version patch folder.
- No bloat in the base image: no extra files or packages. Remove build packages in the layer that installs them.
- Short, readable code.
- Spend few resources: bandwidth, runner time, CPU, memory, registry and API requests. Reuse a cached lookup, skip a job with no work, set a timeout on every job.
- Comments make a long file easy to scan: one short line above a block says what the block does. Add the reason when it is not obvious: a limit, a trap, a trade-off, a link to the source. Do not narrate line by line, and do not repeat a name. Same style in every file: short, plain, practical English. A one-line label starts with a capital letter and has no final period. Several sentences go one per line, each with a period. Rules: spec `conventions`.
- Verify through the build log. Do not ship check files in the image.

## Behavioral guidelines

This file wins on a conflict.

- Think first: state assumptions, ask when unclear, show tradeoffs.
- Keep it simple: minimum code, no speculative features or abstractions.
- Change surgically: touch only what the request needs, match the existing style. Mention unrelated dead code, do not delete it.
- Work toward a goal: define a check for each step and run it.

## Specs (OpenSpec)

Specs in `openspec/specs/<capability>/spec.md` are the source of truth for behavior. Read only the one that matches the area before changing it.
Format and OpenSpec change flow (`openspec/changes/<id>/`): spec `conventions`. Edit code directly in the working tree, not `_OUTPUTS/`.

| Area | Spec |
|---|---|
| Health endpoints, proxy trust, keep-alive, `S6_*`, stop signals, Traefik, Kubernetes, GCP, AWS | `scaling` |
| `src/php-backports/php<X.Y>/` | `backports` |
| `.dockerfile-x/` | `dockerfile-x` |
| Fingerprint, `build/config.sh`, `nginx-build`, `apache-build`, patches, workflows | `build-fingerprint` |
| Which test to run, adding a test, Docker tests | `testing` |
| Formatting, comments, `KNOWN_ISSUES.md`, how to write specs | `conventions` |


## Layout

| Path | Purpose |
|---|---|
| `src/php/base-php.dockerfile` | Base PHP image. `INCLUDE`s the fragments in `common/` |
| `src/php/common/` | Shared dockerfile fragments and `rootfs/` (hooks, utils) |
| `src/php/with-*.dockerfile`, `with-*/` | Web servers: apache, nginx, roadrunner, frankenphp |
| `src/php-backports/php<X.Y>/` | Security patches for end-of-life PHP (spec `backports`) |
| `src/webapps/` | Images for PHP frameworks and applications |
| `build/config.sh` | Produces the build variables: tag, platforms, context, fingerprint |
| `build/versions.sh` | Version lists: maintained 8.6 to 8.2, outdated 8.1 to 5.6 |
| `build/helpers.sh` | Shared functions, one section per purpose: versions, remote content, downloads, IPE modules, published images, build plan, context and hashes |
| `build/check-updates.sh` | Scripts of the Watch updates workflow: `check` (default), `start`, `cleanup` |
| Other paths (patches, `nginx-build`, `.dockerfile-x/`, `tests/`, `.github/`) | spec `build-fingerprint` |

Dockerfiles use the `INCLUDE ./path/name` syntax (dockerfile-x). `Dockerfile` and `meta.dockerfile` are generated at build time and git ignores them.

Utilities inside the image: `pkg-add` and `pkg-del` (install and remove packages per OS, from `APK_PACKAGES` and `APT_PACKAGES`), `env-default`, `hook`. In image layers, use them instead of `apk` or `apt-get`, so Debian and Alpine behave the same.

## Build and test

- Trial build: `tests/build-test.sh <os> <app> <php-version> [server]`, for example `tests/build-test.sh '' with-nginx 8.4`. An empty `<os>` is Debian. It also builds the images it depends on. Variables: `SKIP_SQUASH=1`, `BUILD_TAG_PREFIX`.
- Offline tests need no Docker, so run them after a change and report the real output: `tests/run.sh`, or `tests/run.sh lint|versions|backports|config|scaling|ssh|defaults|size|fingerprint|helpers|updates`.
- All images at once: `tests/compose-test.sh` starts the servers and webapps in batches. The manual `Compose test` workflow runs it on the published images, one job per service and OS.
- A failing check is a finding. Fix the cause or tell the user. Do not edit a test to make it pass.

## Working rules

- Do not run build or compile commands on your own: `docker build`, `docker buildx`, `tests/build-test.sh`, `./configure`, `make`, building PHP from source. Ask first, with the reason and the command. Or the user runs it and asks for follow-up changes.
- Allowed without asking: `sh -n`, `bash -n`, `git apply --check`, `grep`, `diff`, `tests/run.sh` with or without a test name.
- Do not report test results without a run or a log.
- Work on a `feature/*` branch or the current branch. Never commit or push to `main`.
- Use Conventional Commits: `feat:` `fix:` `refactor:` `docs:` `test:` `chore:`.
- After each change, suggest a one-line English commit message, short: about 60 characters or fewer, one idea, no detail that the diff already shows. The type follows semver: `feat:` is a minor bump, `fix:` a patch bump, and `!` (for example `feat!:`) a major bump. `refactor:` `docs:` `test:` `chore:` do not bump the version. Commit only when the user asks.
- Every commit must carry a valid signature (`%G?` shows `G`). `git commit` signs through `commit.gpgsign`. `git commit-tree` and scripted rewrites need `-S`. After any commit or rewrite, check with `git log --format='%h %G? %s'`.
- `_OUTPUTS/` is a local scratch folder that git ignores. Do not commit it.
- Do not touch `.env`, secrets, `.secrets` or `build/.secrets.example`.
- When you fix a bug from a GitHub issue, also record it in `KNOWN_ISSUES.md` in the same change. Read the issue first and do not guess a cause. Format: spec `conventions`.

## Ship flow ("ship 6.x")

When the user says "ship 6.x" or asks for the usual flow, do every step without asking again. Start only after the tests for the change pass.

1. Commit on `6.x` in groups by topic (`feat`, `fix`, `docs`, `test`, `chore` apart). Use one-line messages, no body, no co-author line. Leave untracked scratch files and `_OUTPUTS/` out.
2. Push `6.x` and open a PR to `main`. Title: `[6.x] <summary>`. Body: plain English with Goal, Scope, Implementation, Risks, Tests, and no AI or tool attribution.
3. Squash merge with a one-line Conventional Commits subject and an empty body. Keep the `6.x` branch.
4. Update `main` (`git pull --ff-only`), then `git reset --hard main` on `6.x` and force push it (`--force-with-lease`).
5. Make no release and no tag unless the user asks. When asked, follow the release notes rules in spec `conventions`.

When a step fails (push rejected, failing checks, merge conflict), stop and report. Do not work around it.

## Hard rules

Specs hold the details. These apply even when you do not read the spec.

- `src/php-backports/php<X.Y>/`: data changes only. Do not edit `php-backports.dockerfile`, `base-php.dockerfile` or `build/config.sh` for a new patch. Do not rename, reorder or skip patches: file name order is the apply order and part of the fingerprint. Do not edit a patch to satisfy a test without asking.
- `.dockerfile-x/`: do not edit files inside `upstream/`. Changes go in `patches/`.

## Copyright and credit

This project is the work of Mai Nhut Tan <shin@shin.company>, licensed under `LICENSE` (https://code.shin.company/php/blob/main/LICENSE).

- Respect the effort behind it. If you use or copy these ideas, credit the author.
- Keep the author header at the top of every file. For a new dockerfile, script or workflow, copy it from `src/php/base-php.dockerfile` in the comment style of that file type.
- Do not remove or rewrite author, license or credit lines when you edit or generate files.

<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Tasks

- [x] Dockerfile `src/utilities/rector/rector.dockerfile` from `php8.6-cli`, installs Rector in `$APP_ROOT` and keeps git through the squash. Check: build log shows the Rector version.
- [x] Entrypoint script: validate, detect PHP project, check the version, branch, config, report, apply. Check: `sh -n` and `tests/run.sh lint`.
- [x] Default config generator for any target version, no per-version branch. Check: offline test for 7.4, 8.0, 8.4, 8.6.
- [x] Offline test for the spec scenarios (bad version, empty folder, non-PHP folder, `^8.4` with target 8.4, `^7.4 || ^8.0`, unreadable constraint, `RECTOR_FORCE=1`, dirty tree, no git with backup and restore, existing backup (keep and recreate), existing branch, custom config, env overrides, report files). Check: `tests/run.sh rector`.
- [x] Add the image to the build lists and a `README.md`. Check: `tests/run.sh config`.
- [ ] Trial build with squash (ask the user first). Check: run on a sample project mounted at `/app`, read the report files.

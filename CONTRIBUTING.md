<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Contributing

Thanks for helping. Bug reports, fixes, docs and new web application images are all welcome.

## Report a bug or ask for a feature

Open an [issue](https://code.shin.company/php/issues/new) with the image tag (for example `shinsenter/php:8.4-fpm-apache`), the OS, the command or compose file you ran, what you expected and what happened. Run with `-e DEBUG=1` for more logs.

Check [KNOWN_ISSUES.md](KNOWN_ISSUES.md) first. For a security problem, follow [SECURITY.md](SECURITY.md) instead.


## Where things are

| Path | What it holds |
|---|---|
| `src/php/` | Base PHP image, shared fragments (`common/`) and web server images (`with-*`) |
| `src/php-backports/` | Security patches for end-of-life PHP versions |
| `src/webapps/` | Images for PHP frameworks and applications |
| `build/` | Build variables and version lists (`config.sh`, `versions.sh`) |
| `tests/` | Offline checks (`run.sh`) and Docker tests |


## Make a change

1. Fork the repository and branch from `main`, for example `feature/short-name`.
2. Keep the change small and touch only what it needs.
3. Run the offline tests, no Docker needed: `tests/run.sh`, or `tests/run.sh <name>` for one area (`lint`, `backports`, `config`, `scaling` and more).
4. If you changed an image, build it for one PHP version, for example `tests/build-test.sh '' with-nginx 8.4` (an empty first argument means Debian). Keep the squash step: the cleanup hooks run only there. Try a cleanup hook change on Apache, FrankenPHP, RoadRunner and Nginx, on Debian and Alpine.
5. Open a pull request against `main`. Say what changed, why, and how you tested it, with the test output.

A failing test is a finding. Fix the cause, do not edit the test.


## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org), one line in English, for example `fix: keep sshd password auth off for accounts without a password`. `fix:` bumps the patch version, `feat:` the minor, and `!` (for example `feat!:`) the major. `refactor:`, `docs:`, `test:` and `chore:` do not bump it.

If you fix a bug from an issue, also add it to [KNOWN_ISSUES.md](KNOWN_ISSUES.md) under the release that ships the fix. Read the issue first and do not guess the cause.


## Code style

- 4 spaces in Dockerfiles and shell, 2 in YAML, no tabs. Match the file you edit.
- One command per `RUN` line, chained with `&&`. In image layers use `pkg-add` and `pkg-del`, not `apk` or `apt-get`, so Debian and Alpine behave the same.
- Comments say why, one short sentence per line. Keep the author header on every new file (copy it from `src/php/base-php.dockerfile`).
- One mechanism serves every PHP version: put differences in data (for example a patch folder), not in `if` branches.
- No extra files or packages in the base image. Check the result in the build log, not with files shipped in the image.


## Add a security backport

Only data changes. Add a patch to `src/php-backports/php<major.minor>/` and a row to the table in `src/php-backports/README.md`. Do not edit `php-backports.dockerfile`, `base-php.dockerfile` or `build/config.sh`. Do not rename or reorder patches: the file name order is the apply order and part of the image fingerprint. Name a new one `<YYYYMMDD>-<NN>-<name>.patch`. Details: [src/php-backports/README.md](src/php-backports/README.md).


## Documentation

The READMEs in `src/` are published on Docker Hub. Line 3 of each file is the short description: `<emoji> (PHP) <caption>`, under 90 characters (no `(PHP)` for the base OS images). Each web application and web server README links back to [shinsenter/php](https://hub.docker.com/r/shinsenter/php).

Write docs short and plain, like a person. See also [accessibility](docs/accessibility.md).


## License and credit

By contributing, you agree that your work is licensed under the [GNU General Public License v3.0](LICENSE). If you reuse ideas from this project, please give credit to the author.


## Support the project

If these images help you, you can help keep them maintained:

- ☕ [Donate via PayPal](https://www.paypal.me/shinsenter)
- 💖 [Sponsor on GitHub](https://github.com/sponsors/shinsenter)

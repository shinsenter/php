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

Open an [issue](https://code.shin.company/php/issues/new). A good bug report has:

- the image tag (for example `shinsenter/php:8.4-fpm-apache`) and the OS (Debian or Alpine)
- the command or compose file you ran
- what you expected, and what happened, with logs (run with `-e DEBUG=1` for more detail)

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

1. Fork the repository and create a branch from `main`, for example `feature/short-name`.
2. Keep the change small. Touch only what the change needs.
3. Run the offline tests. They need no Docker:

   ```shell
   tests/run.sh            # everything
   tests/run.sh lint       # shell scripts and hooks
   tests/run.sh versions   # build/versions.sh, build/helpers.sh
   tests/run.sh backports  # src/php-backports/
   tests/run.sh config     # build/config.sh
   tests/run.sh scaling    # health checks, proxies, stop signals
   ```

4. If you changed an image, try a build for one PHP version:

   ```shell
   tests/build-test.sh '' with-nginx 8.4    # empty first argument means Debian
   ```

   Useful variables: `SKIP_SQUASH=1`, `BUILD_TAG_PREFIX`. A change to a cleanup hook should be tried on Apache, FrankenPHP, RoadRunner and Nginx, on Debian and Alpine.
5. Open a pull request against `main`. Say what changed, why, and how you tested it. Paste the test output.

A failing test is a finding. Fix the cause. Do not edit a test to make it pass.


## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org). The type sets the version bump:

| Type | Bump |
|---|---|
| `fix:` | patch |
| `feat:` | minor |
| `feat!:`, `fix!:` | major |
| `refactor:`, `docs:`, `test:`, `chore:` | none |

One line, in English, for example `fix: keep sshd password auth off for accounts without a password`.

If you fix a bug reported in an issue, also add it to [KNOWN_ISSUES.md](KNOWN_ISSUES.md) under the release that ships the fix. Read the issue first and do not guess the cause.


## Code style

- Indent with 4 spaces in Dockerfiles and shell, 2 spaces in YAML. No tabs.
- Dockerfile: one command per `RUN` line, chained with `&&`.
- Comments explain why, one short sentence per line.
- Match the style of the file you edit.
- Keep the author header at the top of every new file. Copy it from `src/php/base-php.dockerfile`.
- In image layers, use `pkg-add` and `pkg-del` instead of `apk` or `apt-get`, so Debian and Alpine behave the same.

Design rules:

- One mechanism serves every PHP version. Put differences in data (for example a patch folder), not in `if` branches.
- No extra files or packages in the base image. Remove build packages in the layer that installs them.
- Verify through the build log. Do not ship check files in the image.


## Add a security backport

Only data changes. Add a patch file to `src/php-backports/php<major.minor>/`, then add a row to the table in `src/php-backports/README.md`. Do not edit `php-backports.dockerfile`, `base-php.dockerfile` or `build/config.sh`.

Name the file `<YYYYMMDD>-<NN>-<name>.patch` and do not rename or reorder existing patches. The file name order is the apply order and part of the image fingerprint. Details are in [src/php-backports/README.md](src/php-backports/README.md).


## Documentation

The READMEs in `src/` are published on Docker Hub. Line 3 of each file is the short description, so keep it as `<emoji> (PHP) <caption>` under 90 characters (no `(PHP)` for the base OS images). Every web application and web server README links back to [shinsenter/php](https://hub.docker.com/r/shinsenter/php).

See also [accessibility](docs/accessibility.md).


## License and credit

By contributing, you agree that your work is licensed under the [GNU General Public License v3.0](LICENSE). If you reuse ideas from this project, please give credit to the author.


## Support the project

If these images help you, you can help keep them maintained:

- ☕ [Donate via PayPal](https://www.paypal.me/shinsenter)
- 💖 [Sponsor on GitHub](https://github.com/sponsors/shinsenter)

<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# dockerfile-x image

`.dockerfile-x/` builds `shinsenter/dockerfile-x`, the `# syntax` frontend that the other dockerfiles use. It builds from the `upstream/` submodule, not from `devthefuture/dockerfile-x`, so that vulnerable Go modules can be raised.

## Rules

- Keep the image minimal and single layer. `build.dockerfile` stays a plain multi-stage file. `build.sh` squashes each platform with `build/docker-squash/docker-squash.sh` (docker-squash handles one platform per run, so `build.sh` loops over platforms, pushes by digest and joins them with `imagetools create`). Do not use `buildx --squash`.
- Clean files in the final `RUN` of `build.dockerfile` while still root. The pre-squash cleanup of docker-squash runs as the image `USER` and cannot remove root-owned files.
- Runtime packages stay at `ca-certificates` and `git`. No `bash`, no ECR credential helper, no docs, man pages or apk cache. Add a package only when the frontend or the CLI needs it, and say why in the commit.
- Keep multi-platform: `linux/amd64` and `linux/arm64/v8`. No arch-specific branches beyond `TARGETARCH`.
- Do not edit files inside `upstream/`. Changes go in `patches/`. Moving the pin means `git -C .dockerfile-x/upstream checkout <tag>`, then updating `org.opencontainers.image.version` in `build.dockerfile`.
- Fix a CVE in a Go module by raising its version in `patches/go-deps`, using the fix version that Docker Scout reports. `bump-go-deps.sh` skips modules that a source tree does not use. Do not pin fix versions you have not seen in a Scout report.
- Fix an Alpine package CVE through `apk upgrade` in the final stage, not by pinning package versions.
- Name the file `build.dockerfile`. `.gitignore` excludes `**/Dockerfile`.
- Keep the author header in `build.dockerfile`, `build.sh` and `patches/*.sh`.

## Verify

- Without a build: `sh -n .dockerfile-x/patches/bump-go-deps.sh`, `bash -n .dockerfile-x/build.sh`, `git submodule status`.
- With a build (ask first, see Working rules): run `.dockerfile-x/build.sh`, then `docker scout cves shinsenter/dockerfile-x:latest --only-severity critical,high`. The goal is no CRITICAL and a lower HIGH count than before. Report the numbers from the real output only.
- Known residual risk: the CLI is packed by `pkg` with Node 18, which is end of life. Its CVEs cannot be fixed by `apk` or `patches/go-deps`.
- Known residual risk: `github.com/moby/buildkit` stays at 0.23.2, which has 2 HIGH CVEs (CVE-2026-33747, CVE-2026-33748, fixed in 0.28.1). Raising it fails to compile: `pkg/dtp/proxy.go` in `upstream/` does not implement `ReadDirContainer`, which 0.28.1 adds to `LLBBridgeClient`. Fix it by moving the `upstream/` pin to a release that supports it, not by editing `upstream/`.

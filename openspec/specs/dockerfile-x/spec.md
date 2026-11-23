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

## Purpose

`.dockerfile-x/` builds `shinsenter/dockerfile-x`, the `# syntax` frontend of the other dockerfiles. It builds from the `upstream/` submodule instead of `devthefuture/dockerfile-x` so vulnerable Go modules can be raised.

## Requirements


### Requirement: Image build and CVE handling

The repo SHALL follow these rules for: image build and cve handling.

#### Scenario: Image build and CVE handling
- **WHEN** this area is changed
- **THEN** all of the following hold:
- The image SHALL be minimal and single layer. `build.dockerfile` stays a plain multi-stage file. `build.sh` loops over platforms, squashes each with `build/docker-squash/docker-squash.sh` (one platform per run), pushes by digest and joins with `imagetools create`. MUST NOT use `buildx --squash`.
- The final `RUN` of `build.dockerfile` SHALL clean files while root (docker-squash pre-cleanup runs as the image `USER` and cannot remove root-owned files).
- Runtime package SHALL stay `ca-certificates` only. No `git`, `bash`, ECR helper, docs, man pages or apk cache. Add a package only when the frontend or CLI needs it, and give the reason in the commit.
- Platforms SHALL stay `linux/amd64` and `linux/arm64/v8`, with no arch branches beyond `TARGETARCH`.
- MUST NOT edit files inside `upstream/`; changes go in `patches/`. To move the pin: `git -C .dockerfile-x/upstream checkout <tag>`, then update `org.opencontainers.image.version` in `build.dockerfile`.
- Go module CVE: raise the version in `patches/go-deps` using the fix version Docker Scout reports. `bump-go-deps.sh` skips modules a tree does not use. MUST NOT pin a fix version no Scout report has shown.
- Alpine package CVE: `apk upgrade` in the final stage, not pinned versions.
- The file SHALL be named `build.dockerfile` (`.gitignore` excludes `**/Dockerfile`). Keep the author header in `build.dockerfile`, `build.sh`, `patches/*.sh`.

## Verification
- No build: `sh -n .dockerfile-x/patches/bump-go-deps.sh`, `bash -n .dockerfile-x/build.sh`, `git submodule status`.
- Build (ask first): `.dockerfile-x/build.sh`, then `docker scout cves shinsenter/dockerfile-x:latest --only-severity critical,high`. Goal: no CRITICAL, fewer HIGH than before. Report real numbers only.

## Known residual risk
- The CLI is packed by `pkg` with Node 18 (EOL). `apk` and `go-deps` cannot fix its CVEs.
- `github.com/moby/buildkit` stays at 0.23.2 with 2 HIGH CVEs (CVE-2026-33747, CVE-2026-33748, fixed in 0.28.1). Raising it fails to compile: `pkg/dtp/proxy.go` in `upstream/` lacks `ReadDirContainer`. Fix: move the `upstream/` pin to a release that supports it, not edit `upstream/`.
- The image has no `git`, so `git+` remote includes fail. Local includes, which the repo uses, work. This removes the `git` HIGH CVEs (2.54.1-r0, fixed in 2.56.1-r0, not yet in Alpine 3.24).
- `musl` 1.2.6-r3 has 1 HIGH CVE (CVE-2026-107891, fixed in 1.2.6-r6). Alpine 3.24 has not published the fix. `apk upgrade` picks it up on the next build. Remove this line then.

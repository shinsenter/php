# Dockerfile-x

Build files for the `shinsenter/dockerfile-x` image, a copy of [devthefuture/dockerfile-x](https://codeberg.org/devthefuture/dockerfile-x). The copy keeps the builds of the other images in this project from failing when the upstream image changes. See the upstream README for the syntax (`INCLUDE`, relative `FROM`).

## Layout

| Path | Purpose |
|---|---|
| `upstream/` | Git submodule, pinned to the upstream tag `v1.6.0` |
| `build.dockerfile` | Builds the frontend, `oras` and the CLI |
| `patches/go-deps` | Go modules raised before building (security fixes) |
| `patches/bump-go-deps.sh` | Applies `go-deps` to the frontend and `oras`; skips modules a tree does not use |
| `build.sh` | Per platform: build, squash to one layer with `build/docker-squash`, push by digest. Then joins the platforms into the tags (`linux/amd64`, `linux/arm64/v8`) |

Differences from upstream: Go modules patched, `oras` built from source, no `bash`, no ECR credential helper, docs and man pages removed.

## Usage

```Dockerfile
# syntax = shinsenter/dockerfile-x
FROM debian:latest
INCLUDE ./common-instructions.dockerfile
```

## Update

1. Move the submodule: `git -C .dockerfile-x/upstream checkout <tag>`.
2. Update `org.opencontainers.image.version` in `build.dockerfile`.
3. Run `.dockerfile-x/build.sh`, then `docker scout cves shinsenter/dockerfile-x:latest`.
4. Raise versions in `patches/go-deps` when Scout reports a new fix version.

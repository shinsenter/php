# Dockerfile-x

"Dockerfile-x" primarily refers to the [devthefuture/dockerfile-x](https://codeberg.org/devthefuture/dockerfile-x) project.

This "Dockerfile-x" project introduces an extended syntax for Dockerfiles, aiming to improve modularity and reduce code duplication through features like an INCLUDE directive for external file fragments and relative paths for FROM instructions.

---

**NOTE**: This is just a copy of [the original repository](https://hub.docker.com/r/devthefuture/dockerfile-x), used to reduce errors when building my other Docker images.

## Examples

To enable `dockerfile-x` custom syntax, you can use native docker buildkit frontend feature by adding syntax comment to the beginning of your Dockerfile:

```Dockerfile
# syntax = shinsenter/dockerfile-x
FROM ./base/dockerfile
COPY --from=./build/dockerfile#build-stage /app /app
INCLUDE ./other/dockerfile
```

---

Basic INCLUDE

```Dockerfile
# syntax = shinsenter/dockerfile-x
FROM debian:latest
INCLUDE ./common-instructions.dockerfile
CMD ["bash"]
```

---

Using stages from another Dockerfile

```Dockerfile
# syntax = shinsenter/dockerfile-x
FROM ./base/dockerfile#dev AS development
FROM ./base/dockerfile#prod AS production
COPY --from=development /app /app
CMD ["start-app"]
```

---

Re-aliasing a stage

```Dockerfile
# syntax = shinsenter/dockerfile-x
FROM ./complex-setup/dockerfile#old-stage-name AS new-name
COPY ./configs /configs
```

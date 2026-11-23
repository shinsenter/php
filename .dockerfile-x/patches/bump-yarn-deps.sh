#!/bin/sh
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Pins vulnerable Node modules listed in patches/yarn-deps as resolutions, then updates yarn.lock.
# Run in the package root, before yarn fetch. The fetch plugin then rewrites package.json from the lock.
set -eu

grep -vE '^(#|$)' "$(dirname "$0")/yarn-deps" | node -e '
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json"));
pkg.resolutions = {};
for (const dep of fs.readFileSync(0, "utf8").split("\n").filter(Boolean)) {
  const i = dep.lastIndexOf("@");
  pkg.resolutions[dep.slice(0, i)] = dep.slice(i + 1);
}
fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
'

yarn install --mode=update-lockfile

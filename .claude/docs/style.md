<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Formatting and comments (details)

Short form: `CLAUDE.md`, section "Working rules".

- Format every file you create or edit, and match the surrounding file.
- Dockerfiles: one command per `RUN` line chained with `&&`. Continuation lines indent 4 spaces, deeper arguments 4 more.
- Shell: 4 spaces. YAML: 2 spaces. No tabs.
- Comment blocks: one sentence per line, no wrapping at a fixed width. Keep sentences short.
- A sentence over about 100 columns breaks at a comma, a semicolon or before a conjunction such as "so", "because", "when" or "and". Never break inside a path, a quoted string or a short phrase.
- Several very short sentences (about 40 columns or less each) can share a line, up to about 100 columns.

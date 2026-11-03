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

The short form is in `CLAUDE.md`, section "Working rules".

- Indent and format every file you create or edit, and match the surrounding file.
- Dockerfiles: one command per `RUN` line chained with `&&`, continuation lines indented 4 spaces, deeper arguments 4 more.
- Shell: 4 spaces. YAML: 2 spaces. No tabs.
- Comment blocks: break lines by sentence. Start each sentence on a new line and do not wrap a sentence at a fixed width. Keep sentences short.
- If a sentence is still too long for one line (over about 100 columns), break it at a natural point: after a comma or semicolon, or before a conjunction such as "so", "because", "when" or "and". Do not break inside a path, a quoted string or a short phrase.
- If several sentences are very short (about 40 columns or less each), put them on the same line, up to about 100 columns.

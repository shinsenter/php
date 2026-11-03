<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# KNOWN_ISSUES.md workflow (details)

The short form is in `CLAUDE.md`, section "Working rules".

When the user asks to fix a bug reported by a user (a GitHub issue), also record it in `KNOWN_ISSUES.md` in the same change.

- Add the entry under the release that will ship the fix, or under `Open` until the fix is merged.
- Each entry has the issue link, the symptom, the cause (or "not recorded"), and the fix.
- Do not write commit hashes, because a squash merge changes them.
- Read the issue and its comments first, and do not guess a cause.

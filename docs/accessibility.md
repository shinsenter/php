<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Accessibility

This project ships Docker images and documentation. It has no user interface, so accessibility here means documentation that everyone can read and use, including with a screen reader, a text browser or a translation tool. We have not run a formal audit.

## What we aim for

- Headings follow a clear order (one `#`, then `##`, then `###`), so readers can jump between sections.
- Link text says where the link goes. We avoid "click here".
- Code blocks name their language (`shell`, `yaml`, `Dockerfile`), and commands can be copied as they are.
- Images have alt text. Information in an image is also written in the text.
- Meaning does not depend on color or emoji alone. Emoji decorate a line, and the text still says the same thing without them.
- Short sentences in plain English, with terms explained the first time they appear.
- Tables stay small and have a header row.

## Tell us about a problem

If something in the docs is hard to read or use, open an [issue](https://code.shin.company/php/issues/new) or send a pull request. Say which page you used and what got in the way. See [CONTRIBUTING.md](CONTRIBUTING.md).

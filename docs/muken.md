<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# muken (無間)

muken puts the `shinsenter/php` images on a server you own, with no downtime and no manual steps. It lives in its own repository:

- Code, releases and guide: https://github.com/shinsenter/muken
- Site: https://shinsenter.github.io/muken/

You describe your app in a short file and run one command. muken installs Docker and Traefik on the server, starts the new version next to the old one, moves visitors over when the new one is healthy, and goes back by itself when it is not. It knows every image and app of this project (WordPress, Laravel, Symfony, Drupal, Nextcloud and more).

```shell
muken init     # answer a few questions
muken up       # prepare the server and deploy
```

Download a binary from the [Releases page](https://github.com/shinsenter/muken/releases). To run these images behind Traefik by hand instead, read [Running the images behind Traefik](traefik.md).

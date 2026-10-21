# Responsible Disclosure Policy


## Reporting Security Vulnerabilities

We take security seriously in our open-source project. If you discover a security vulnerability, please help us by responsibly disclosing it. We appreciate your efforts in keeping our project safe for everyone.


## How to Report a Vulnerability

To report a security vulnerability:

1. **Contact us privately**: Please email us at [shin@shin.company](mailto:shin@shin.company) with details about the vulnerability. Please refrain from disclosing the issue publicly until we've had a chance to address it.

2. **Provide details**: Include as much information as possible about the vulnerability, including steps to reproduce it and its potential impact.

3. **Be responsible**: Please avoid exploiting the vulnerability beyond what is necessary to demonstrate the issue.


## What to Expect

Once we receive your report, we'll acknowledge it promptly. We'll work to assess the reported vulnerability's validity and severity and develop a fix as quickly as possible. We'll keep you updated on our progress throughout the process.


## Security Updates for PHP and Dependencies

When PHP publishes a security release, the images are rebuilt automatically after the official `php` image for that version is published on Docker Hub. The [Watch updates](https://code.shin.company/php/actions/workflows/watch-updates.yml) workflow checks for a new official image every 30 minutes and builds only the affected PHP versions. See [How Images Are Updated](README.md#how-images-are-updated).

To apply a fix as soon as it is available:

1. Pull the image again, for example `docker pull shinsenter/php:8.5-fpm`.
2. Recreate your containers, since a running container keeps the old image.
3. Check the version with `php -v`.

Before the rebuilt image is available, follow the mitigation in the PHP security advisory for your version. You can set most `php.ini` options with `PHP_*` environment variables (see the README), but check that the option really mitigates the issue in the advisory.

If a rebuild looks late, open an issue with the PHP version and the image tag. Include the link to the PHP release notes.


## Legal Safe Harbor

We won't take legal action against you for responsibly disclosing security vulnerabilities in our project. We appreciate your contributions to making our project more secure.

Thank you for your help in keeping our project safe.

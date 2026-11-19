<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->


# Conventions

## Purpose

Formatting, KNOWN_ISSUES and spec-writing rules for this repo.

## Requirements


### Requirement: Formatting and comments

The repo SHALL follow these rules for: formatting and comments.

#### Scenario: Formatting and comments
- **WHEN** this area is changed
- **THEN** all of the following hold:
- Every file created or edited SHALL match the surrounding file. Dockerfiles: one command per `RUN` line chained with `&&`; continuation lines indent 4 spaces, deeper arguments 4 more. Shell 4 spaces. YAML 2 spaces. No tabs.
- Comment blocks: one sentence per line, no fixed-width wrap, short sentences. A sentence over about 100 columns breaks at a comma, semicolon or before a conjunction ("so", "because", "when", "and"); never inside a path, quoted string or short phrase. Several very short sentences (about 40 columns or less) can share a line up to about 100 columns.

### Requirement: KNOWN_ISSUES.md

The repo SHALL follow these rules for: known_issues.md.

#### Scenario: KNOWN_ISSUES.md
- **WHEN** this area is changed
- **THEN** all of the following hold:
- Fixing a bug from a GitHub issue SHALL record it in `KNOWN_ISSUES.md` in the same change.
- Entry goes under the release that ships the fix, or `Open` until merged. It has the issue link, symptom, cause (or "not recorded") and fix.
- MUST NOT write commit hashes (squash merge changes them).
- Read the issue and its comments first; MUST NOT guess a cause.

### Requirement: Spec workflow (OpenSpec)

The repo SHALL follow these rules for: spec workflow (openspec).

#### Scenario: Spec workflow (OpenSpec)
- **WHEN** this area is changed
- **THEN** all of the following hold:
- Specs in `openspec/specs/<capability>/spec.md` are the source of truth for behavior. Use `SHALL`/`MUST` for rules, `Scenario` for testable cases, `Why:` for one-line reasons. Keep each spec short; unverified facts say "Unverified".
- A change to behavior or contract (env var, endpoint, fingerprint, backport rule) SHALL start as `openspec/changes/<id>/` with `proposal.md` (why, scope), `tasks.md` (checklist, each with its check) and delta files `specs/<capability>/spec.md` using `## ADDED|MODIFIED|REMOVED Requirements`. After merge, fold the deltas into `openspec/specs/` and move the folder to `openspec/changes/archive/`.
- Typo, docs, chore and bug fixes that keep behavior skip the change folder but SHALL update the spec if it states the old behavior.

### Requirement: Release notes

A release SHALL have a short `CHANGELOG.md` entry and a GitHub release body in the same shape.

#### Scenario: Write the notes for a release
- **WHEN** a version is prepared (for example 6.2.0)
- **THEN** the changelog lists only what differs from the previous version, taken from the commits since its tag, one short line per change, about seven lines
- **AND** names, variables and issue numbers stay only when a user needs them
- **AND** the release body is `## What's Changed` (one line per merged PR: `* <title> by @<author> in <PR url>`, read from git history between the two tags, not from the generate-notes API), then `## Highlights` (the changelog lines), then `**Full Changelog:** https://github.com/shinsenter/php/compare/<previous>...<new>`
- **AND** the release is created as a draft with the target `main`, and published only after the PR is merged and the images are built
- **AND** an older release body changes only when the user asks, and the old body is kept in `_OUTPUTS/` first

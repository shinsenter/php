<!--
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
-->

# Rector upgrade

## ADDED Requirements

### Requirement: Inputs

The image SHALL take all settings from environment variables and mounts.

#### Scenario: Run with the minimum input
- **WHEN** the user mounts the project at `/app` and sets `RECTOR_TARGET_PHP` (for example `8.4`)
- **THEN** the container runs the full upgrade and exits, with no prompt

#### Scenario: Another project path
- **WHEN** `RECTOR_PROJECT_PATH` is set
- **THEN** the container uses that path instead of `/app`

#### Scenario: Target version missing or invalid
- **WHEN** `RECTOR_TARGET_PHP` is empty or not `<major>.<minor>` from 5.6 to 8.6
- **THEN** the container exits non-zero before it touches git or files, and the message shows the accepted format

### Requirement: Project detection

The container SHALL check that the project path is a PHP project before it touches git.

#### Scenario: PHP project
- **WHEN** the project path has a `composer.json`, or at least one `.php` file outside `vendor/`, `node_modules/` and `.git/`
- **THEN** the container goes on and prints which marker it found

#### Scenario: Not a PHP project
- **WHEN** the path is missing, empty, not a directory, or has no marker
- **THEN** the container exits non-zero with a message that names the path and the markers it looked for
- **AND** it changes nothing

#### Scenario: Paths set by the user
- **WHEN** `RECTOR_PATHS` lists folders that hold no `.php` file
- **THEN** the container exits non-zero and names the empty folders

Why: a wrong mount (empty folder, wrong level of a monorepo) fails in one second, before the branch.

### Requirement: Already at target

The container SHALL stop with success when the project already requires the target PHP version or higher.

#### Scenario: Constraint at or above the target
- **WHEN** `composer.json` has `require.php` and the lower bound of every alternative (`||`) is at or above `RECTOR_TARGET_PHP` (for example `^8.4` or `>=8.5` with target 8.4)
- **THEN** the container prints the constraint and the target, says there is nothing to upgrade, and exits 0
- **AND** it creates no branch and writes no report

#### Scenario: Constraint below the target
- **WHEN** at least one alternative allows a version below the target (for example `^7.4 || ^8.0`)
- **THEN** the container goes on

#### Scenario: Cannot decide
- **WHEN** there is no `composer.json`, no `require.php`, or a constraint with no lower bound or that the container cannot read
- **THEN** the container prints a warning that it could not read the project's PHP version, and goes on
- **AND** it MUST NOT guess the version from the code

#### Scenario: Run anyway
- **WHEN** `RECTOR_FORCE=1`
- **THEN** the container skips this check

Why: the check reads only `require.php`; `config.platform.php` and the PHP version of the host are ignored. Exit 0 because this is not an error. The check runs after project detection and before git.

### Requirement: Composer PHP constraint

After Rector succeeds, the container SHALL raise `require.php` in `composer.json` to `^<RECTOR_TARGET_PHP>` when the constraint allows an older PHP.

#### Scenario: Constraint below the target
- **WHEN** `require.php` has a lower bound below the target and `RECTOR_UPDATE_COMPOSER` is not `0`
- **THEN** only the value of `require.php` is replaced, and the rest of the file keeps its format
- **AND** without git, `composer.json` is saved in the backup first, even when Rector changes no other file

#### Scenario: Turned off, or nothing to read
- **WHEN** `RECTOR_UPDATE_COMPOSER=0`, or there is no `require.php`
- **THEN** `composer.json` is not changed

#### Scenario: Cannot edit
- **WHEN** the container cannot find or write `require.php`
- **THEN** it prints a warning and leaves the file as it was

Why: Rector changes code, not the constraint, so a project would stay on the old version. `require-dev`, `config.platform.php` and `composer.lock` are left alone: the lock needs `composer update`, which needs the network and the user's decision.

### Requirement: No git

The container SHALL run in place when the project is not a git repository (no repository, or Subversion), and MUST save the original of every file it will change first.

#### Scenario: Not a git repository
- **WHEN** the project is not a git repository and Rector found changes
- **THEN** the container prints a warning, makes no branch, and copies each file Rector will change to `<report>/backup/files/` with its relative path
- **AND** it writes `<report>/backup/restore`, a `sh` script that copies the saved files back to the project (default: two folders above the script, or a folder given as argument)
- **AND** it MUST NOT run `git init`

#### Scenario: Backup already exists
- **WHEN** `<report>/backup/files/` exists from an earlier run
- **THEN** with `RECTOR_BACKUP_EXISTING=keep` (default) the container keeps the saved originals and adds only the files it does not have
- **AND** with `recreate` it deletes the backup and saves the files again from the working folder
- **AND** any other value exits non-zero before anything changes

Why: keep is the default because a recreated backup of an already upgraded project would overwrite the real originals.

#### Scenario: File list unknown
- **WHEN** Rector reports changes but the container cannot list the files (Unverified: the layout of `rector.json`, with the diff as fallback)
- **THEN** the container exits non-zero and changes nothing

### Requirement: Rector install

The image SHALL contain Rector, installed at build time into `$APP_ROOT`. The container MUST NOT download anything at start and MUST NOT write Rector into the user's project.

#### Scenario: Default build
- **WHEN** the image is built
- **THEN** the build installs the latest `rector/rector` with Composer into `$APP_ROOT`, and the build log prints the Rector version

#### Scenario: Pinned build
- **WHEN** the build arg `RECTOR_VERSION` is set (for example `2.1.0`)
- **THEN** the build installs that version instead

#### Scenario: Start without network
- **WHEN** the container starts with no network
- **THEN** the upgrade runs normally

#### Scenario: Version in the report
- **WHEN** the container runs Rector
- **THEN** it prints the Rector version, so the report shows which rules were used

Why: a start needs no network and gives the same result each time for one image tag. "Latest" means latest at build time, so a new Rector release needs a rebuild.

### Requirement: Git branch

The container SHALL do the upgrade on a new branch and MUST NOT write to the current branch.

#### Scenario: Clean repository
- **WHEN** the project is a git repository with a clean working tree
- **THEN** the container creates `migration-to-php-<version>` (override: `RECTOR_BRANCH`) from the current HEAD and checks it out
- **AND** the original branch stays unchanged

#### Scenario: Dirty tree or existing branch
- **WHEN** the tree has uncommitted changes, or the branch name already exists
- **THEN** the container exits non-zero and changes nothing
- **AND** `RECTOR_ALLOW_DIRTY=1` carries the uncommitted changes onto the new branch

Why: deleting the branch undoes an unwanted upgrade.

### Requirement: Rector config

The container SHALL use `rector.php` in the project folder when it exists and a generated default otherwise.

#### Scenario: Custom config
- **WHEN** the project folder has a `rector.php`
- **THEN** Rector runs with that file as is, and `RECTOR_TARGET_PHP` only picks the branch name
- **AND** there is no other way to give a config: no variable and no mount point

#### Scenario: Default config
- **WHEN** the project has no `rector.php`
- **THEN** the container generates one outside the project that adds the PHP sets with `withPhpSets()`, which covers every version up to the target (the set of the target included), tells Rector that the project is on the target PHP, and applies the prepared sets `deadCode` and `codeQuality`, without the rule that adds `declare(strict_types=1)`
- **AND** it uses only the supported Rector API, so a run prints no deprecation warning
- **AND** one generator serves every target version

#### Scenario: Tune Rector by environment
- **WHEN** `RECTOR_PATHS`, `RECTOR_SKIP` (comma-separated), `RECTOR_ARGS` (extra CLI flags) or `RECTOR_MEMORY_LIMIT` are set
- **THEN** the default config and the Rector command use them
- **AND** without `RECTOR_PATHS`, paths are the existing folders among `app`, `src`, `lib`, `config`, `public`, `tests`, and `vendor` is skipped
- **AND** these variables do not change a custom config file, except `RECTOR_ARGS` and `RECTOR_MEMORY_LIMIT`

### Requirement: Report before apply

The container SHALL write the Rector output to files before it changes any source file.

#### Scenario: Run order
- **WHEN** the config is ready
- **THEN** the container runs Rector in dry-run mode and saves `rector.diff`, `rector.json` and `rector-version.txt` in `RECTOR_REPORT_DIR` (default `<project>/.rector-report/`), and the apply output in `rector-apply.log`
- **AND** it then applies the changes with the same config
- **AND** it prints the report path and the changed file count

#### Scenario: Baseline
- **WHEN** the run finishes
- **THEN** no baseline file is written in this version (Rector baseline support is Unverified)

#### Scenario: Report folder stays out of git
- **WHEN** the report folder is inside the project
- **THEN** the container adds it to `.git/info/exclude`, so the working tree shows only the upgrade

#### Scenario: Rector fails
- **WHEN** Rector exits non-zero in either run
- **THEN** the container exits with the same code and leaves the branch, files and reports as they are

### Requirement: No commit

The container MUST NOT commit or push. Changes stay in the working tree of the new branch for the user to review.

### Requirement: Mount ownership

Files written to the mount SHALL keep the owner of the mounted folder.

#### Scenario: Run on a host folder
- **WHEN** the mount belongs to a host user
- **THEN** the container runs Rector as that uid and gid, and git accepts the folder without a `safe.directory` error

### Requirement: Image size

The image MUST add only Rector, git and the entrypoint to the `cli` image. Composer stays, because it is part of the base image.

#### Scenario: Inspect the image
- **WHEN** the build is done
- **THEN** the Composer cache is cleared in the layer that installs Rector, `git` survives the squash cleanup, and no test files ship in the image

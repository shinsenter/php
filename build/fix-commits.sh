#!/bin/sh
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
set -eu

BASE_DIR="$(git rev-parse --show-toplevel)"
SEPARATOR="---END---"

############################################################
# Defaults
############################################################
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "HEAD" ]; then
    BASE_BRANCH="$CURRENT_BRANCH"
else
    BASE_BRANCH="main"
fi
COMMITTER_NAME=""
COMMITTER_EMAIL=""
NEW_BRANCH="${BASE_BRANCH}-working"
WORKING_DIR="${BASE_DIR}/fix-commits.working"
PATCH_DIR="${WORKING_DIR}/patches"
MAPPING_FILE="${WORKING_DIR}/commit-map.txt"
WITH_TAGS=true
EXPORT_FILE=""
RESUME_FILE=""
UNDO_TAGS=false
PUSH_TAGS=false
DRY_RUN=false

############################################################
# Utility
############################################################
cleanup() {
    status=$?
    if [ $status -ne 0 ]; then
        echo ""
        echo "Aborted (status $status). Cleaning up..."
    fi
    rm -rf "$PATCH_DIR/.messages" "$PATCH_DIR/.msgblock" "$PATCH_DIR"/*.tmp 2>/dev/null || true
}
# trap cleanup INT TERM EXIT

print_progress() {
    current=$1 total=$2 width=40
    percent=$(( current * 100 / total ))

    if [ "$current" -eq "$total" ]; then
        printf "\r["
        printf "%0.s#" $(seq 1 $width)
        printf "] %3d%% (%d/%d)\n" "$percent" "$current" "$total"
    else
        filled=$(( current * width / total ))
        empty=$(( width - filled ))
        printf "\r["
        printf "%0.s#" $(seq 1 $filled)
        printf "%0.s " $(seq 1 $empty)
        printf "] %3d%% (%d/%d)" "$percent" "$current" "$total"
    fi
}

############################################################
# Prefix & subject formatting
############################################################
has_prefix() {
    case "$1" in
        *\(release\):*) return 0 ;;
        feat:*|fix:*|chore:*|docs:*|refactor:*|test:*|perf:*|style:*|ci:*|build:*) return 0 ;;
        *) return 1 ;;
    esac
}

suggest_type() {
    subj=$1
    echo "$subj" | grep -iq "^revert" && { echo "revert"; return; }
    echo "$subj" | grep -iq "fix" && { echo "fix"; return; }
    echo "$subj" | grep -iq "add" && { echo "feat"; return; }
    echo "$subj" | grep -iq "update\|change" && { echo "chore"; return; }
    echo "$subj" | grep -iq "doc" && { echo "docs"; return; }
    echo "$subj" | grep -iq "test" && { echo "test"; return; }
    echo "$subj" | grep -iq "refactor" && { echo "refactor"; return; }
    echo "chore"
}

format_with_prefix() {
    subj=$1
    if has_prefix "$subj"; then
        echo "$subj"
    else
        PREFIX=$(suggest_type "$subj")
        SUBJECT_LOWER=$(printf '%s' "$subj" | tr '[:upper:]' '[:lower:]')
        echo "$PREFIX: $SUBJECT_LOWER"
    fi
}

get_clean_tags() {
    commit=$1
    TAGS=$(git tag --points-at "$commit" || true)
    [ -n "$TAGS" ] && printf '%s' "$TAGS" | paste -sd ", " - | sed 's/\bv//g'
}

format_revert_subject() {
    commit=$1 subject=$2 TAG_CLEAN=$3
    CLEANED=$(printf '%s' "$subject" | sed -E 's/^[Rr]evert[[:space:]]+//')

    if echo "$CLEANED" | grep -q '^"'; then
        INNER=$(printf '%s' "$CLEANED" | sed -E 's/^"([^"]*)".*/\1/')
        SUFFIX=$(printf '%s' "$CLEANED" | sed -E 's/^"[^"]*"(.*)$/\1/')
    else
        INNER=$CLEANED
        SUFFIX=""
    fi

    INNER_FINAL=$(format_with_prefix "$INNER")

    set +e
    REFS=$(git log -n 1 --pretty=%b "$commit" \
        | grep -i "This reverts commit" \
        | awk '{print $4}' \
        | paste -sd ", " -)
    set -e

    if [ -n "$TAG_CLEAN" ]; then
        printf "chore(main): release %s (revert: \"%s\"%s)\n" "$TAG_CLEAN" "$INNER_FINAL" "$SUFFIX"
    else
        printf "revert: \"%s\"%s\n" "$INNER_FINAL" "$SUFFIX"
    fi
    [ -n "$REFS" ] && printf "This reverts commit %s\n" "$REFS" || true
}

process_subject() {
    commit=$1 subject=$2
    TAG_CLEAN=$(get_clean_tags "$commit" || true)

    if echo "$subject" | grep -iq "^revert"; then
        format_revert_subject "$commit" "$subject" "$TAG_CLEAN"
        return 0
    fi

    INNER_FINAL=$(format_with_prefix "$subject")

    if [ -n "$TAG_CLEAN" ]; then
        PREFIX=$(printf '%s' "$INNER_FINAL" | cut -d: -f1)
        printf "chore(main): release %s (%s)\n" "$PREFIX" "$TAG_CLEAN" "$INNER_FINAL"
    else
        printf "%s\n" "$INNER_FINAL"
    fi
}

############################################################
# Commit file parsing
############################################################
get_message_block() {
    commit=$1
    file=$2
    awk -v c="$commit" '
        $1 == c {
            getline
            msg=$0
            while (getline > 0 && $0 != "'$SEPARATOR'") {
                if ($0 != "") { msg = msg "\n" $0 }
            }
            print msg
            exit
        }
    ' "$file"
}

############################################################
# Workflow: export/import
############################################################
export_commits() {
    file=$1
    echo "Exporting commit messages to $file..."
    rm -f "$file"
    COMMITS=$(git rev-list --reverse "$BASE_BRANCH")
    TOTAL=$(echo "$COMMITS" | wc -l | tr -d ' ')
    i=0
    for c in $COMMITS; do
        i=$((i+1))
        SUBJECT=$(git log -n 1 --pretty=%s "$c")
        echo "$c" >> "$file"
        process_subject "$c" "$SUBJECT" >> "$file"
        echo "$SEPARATOR" >> "$file"
        echo "" >> "$file"
        print_progress $i $TOTAL
    done
    echo "Done. Edit '$file' then run with --resume-from-file."
}

apply_new_messages() {
    file=$1
    [ ! -s "$file" ] && { echo "Error: resume file '$file' does not exist or is empty."; exit 1; }

    echo "Reading messages from $file..."
    tmpfile="$PATCH_DIR/.messages"; rm -f "$tmpfile"
    current_commit="" msgblock="$PATCH_DIR/.blockmsg"; rm -f "$msgblock"
    line_no=0

    while IFS= read -r line || [ -n "$line" ]; do
        line_no=$((line_no+1))
        [ -z "$line" ] && continue
        if [ "$line" = "$SEPARATOR" ]; then
            [ -z "$current_commit" ] && { echo "Error: line $line_no: $SEPARATOR found without commit hash."; exit 1; }
            [ ! -s "$msgblock" ] && { echo "Error: line $line_no: commit $current_commit has no message."; exit 1; }
            { echo "$current_commit"; cat "$msgblock"; } >> "$tmpfile"; echo "$SEPARATOR" >> "$tmpfile"
            current_commit=""; rm -f "$msgblock"; : > "$msgblock"
        elif [ -z "$current_commit" ]; then
            current_commit=$line
        else
            echo "$line" >> "$msgblock"
        fi
    done < "$file"
    [ -n "$current_commit" ] && { echo "Error: file ended unexpectedly (missing $SEPARATOR for $current_commit)."; exit 1; }
    rm -f "$msgblock"
    PATCHES=$(ls "$PATCH_DIR"/*.patch 2>/dev/null || true)
    TOTAL=$(echo "$PATCHES" | wc -w | tr -d ' ')
    i=0
    for f in $PATCHES; do
        i=$((i+1))
        COMMIT=$(grep "^From " "$f" | awk '{print $2}')
        get_message_block "$COMMIT" "$tmpfile" > "$PATCH_DIR/.msgblock"
        [ ! -s "$PATCH_DIR/.msgblock" ] && { echo "Error: no new message for commit $COMMIT."; exit 1; }
        awk -v msgfile="$PATCH_DIR/.msgblock" '
            BEGIN {
                n=0
                while ((getline line < msgfile) > 0) {
                    n++; arr[n]=line
                }
                close(msgfile)
                skipping=0
            }
            /^Subject:/ {
                print "Subject: " arr[1]
                for (i=2; i<=n; i++) print arr[i]
                skipping=1
                next
            }
            skipping && /^---/ { skipping=0 }
            skipping && /^diff/ { skipping=0 }
            skipping { next }
            { print }
        ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
        print_progress $i $TOTAL
    done
    rm -f "$tmpfile" "$PATCH_DIR/.msgblock"
}

interactive_edit() {
    echo "Running in interactive mode..."
    PATCHES=$(ls "$PATCH_DIR"/*.patch 2>/dev/null || true)
    TOTAL=$(echo "$PATCHES" | wc -w | tr -d ' ')
    i=0
    for f in $PATCHES; do
        i=$((i+1))
        SUBJECT=$(grep "^Subject:" "$f" | sed 's/Subject: //;s/\[PATCH [0-9]*\/[0-9]*\] //')
        SUGGESTED=$(format_with_prefix "$SUBJECT")
        echo; echo "Commit $i/$TOTAL"; echo "Patch: $f"; echo "Original subject: $SUBJECT"
        printf "Suggested (press Enter to accept): %s " "$SUGGESTED"
        read INPUT || true
        NEW_SUBJECT=${INPUT:-$SUGGESTED}
        sed "s|^Subject:.*|Subject: $NEW_SUBJECT|" "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    done
}

############################################################
# Patch management
############################################################
prepare_patches() {
    rm -rf "$PATCH_DIR" "$MAPPING_FILE"
    mkdir -p "$PATCH_DIR"
    git format-patch --root "$BASE_BRANCH" -o "$PATCH_DIR"
}

apply_patches() {
    if [ "$DRY_RUN" = true ]; then
        echo "Dry run mode: patches prepared at $PATCH_DIR"
        exit 0
    fi

    # check if working branch exists
    if git show-ref --verify --quiet "refs/heads/$NEW_BRANCH"; then
        echo "Branch '$NEW_BRANCH' already exists."
        printf "Do you want to delete it and continue? [y/N]: "
        read answer
        case "$answer" in
            y|Y|yes|YES)
                git branch -D "$NEW_BRANCH"
                ;;
            *)
                echo "Aborted by user."
                exit 1
                ;;
        esac
    fi

    echo "Creating orphan branch '$NEW_BRANCH'..."
    git checkout --orphan "$NEW_BRANCH"
    git reset --hard

    echo "Cleaning up whitespace in patches..."
    for f in "$PATCH_DIR"/*.patch; do
        # remove trailing spaces/tabs
        sed -i.bak 's/[[:space:]]*$//' "$f" && rm -f "$f.bak"
        # remove trailing blank lines
        awk 'NF{p=1}p' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    done

    echo "Applying patches..."
    GIT_OPTIONS="--committer-date-is-author-date --whitespace=fix"
    if [ -n "$COMMITTER_NAME" ] && [ -n "$COMMITTER_EMAIL" ]; then
        GIT_COMMITTER_NAME="$COMMITTER_NAME" \
        GIT_COMMITTER_EMAIL="$COMMITTER_EMAIL" \
        git am $GIT_OPTIONS "$PATCH_DIR"/*.patch
    else
        git am $GIT_OPTIONS "$PATCH_DIR"/*.patch
    fi

    echo "Building commit mapping..."
    git rev-list --reverse "$BASE_BRANCH" > "$WORKING_DIR/.old"
    git rev-list --reverse "$NEW_BRANCH" > "$WORKING_DIR/.new"
    paste "$WORKING_DIR/.old" "$WORKING_DIR/.new" > "$MAPPING_FILE"
    rm -f "$WORKING_DIR/.old" "$WORKING_DIR/.new"
}

############################################################
# Tag management
############################################################
reattach_tags() {
    echo "Reattaching tags..."
    while read -r OLD_HASH NEW_HASH; do
        TAGS=$(git tag --points-at "$OLD_HASH" || true)
        [ -n "$TAGS" ] && for TAG in $TAGS; do git tag -f "$TAG" "$NEW_HASH"; echo "Moved tag $TAG -> $NEW_HASH"; done
    done < "$MAPPING_FILE"
}

push_tags() {
    echo "Pushing tags..."
    git push origin --tags; echo "Push complete."
}

undo_tags() {
    echo "Undoing local tags..."
    git tag -l | xargs -r git tag -d; git fetch origin --tags; echo "Tags restored from origin."
}

############################################################
# Argument parser
############################################################
while [ $# -gt 0 ]; do
    case $1 in
        -C|--committer)
            COMM=$2; shift 2
            COMMITTER_NAME=$(printf '%s' "$COMM" | sed -E 's/ <.*$//')
            COMMITTER_EMAIL=$(printf '%s' "$COMM" | sed -E 's/.*<([^>]*)>.*/\1/')
            ;;
        --committer=*)
            COMM=${1#*=}; shift 1
            COMMITTER_NAME=$(printf '%s' "$COMM" | sed -E 's/ <.*$//')
            COMMITTER_EMAIL=$(printf '%s' "$COMM" | sed -E 's/.*<([^>]*)>.*/\1/')
            ;;
        -b|--base-branch)
            BASE_BRANCH=$2; shift 2 ;;
        --base-branch=*)
            BASE_BRANCH=${1#*=}; shift 1 ;;
        -n|--new-branch)
            NEW_BRANCH=$2; shift 2 ;;
        --new-branch=*)
            NEW_BRANCH=${1#*=}; shift 1 ;;
        -p|--patch-dir)
            PATCH_DIR=$2; shift 2 ;;
        --patch-dir=*)
            PATCH_DIR=${1#*=}; shift 1 ;;
        -m|--mapping-file)
            MAPPING_FILE=$2; shift 2 ;;
        --mapping-file=*)
            MAPPING_FILE=${1#*=}; shift 1 ;;
        -w|--without-tags)
            WITH_TAGS=false; shift 1 ;;
        -d|--dry-run)
            DRY_RUN=true; shift 1 ;;
        -e|--export)
            if [ $# -gt 1 ] && [ "$(printf %.1s "$2")" != "-" ]; then
                EXPORT_FILE=$2; shift 2
            else
                EXPORT_FILE="${WORKING_DIR}/commits.txt"; shift 1
            fi
            ;;
        --export=*)
            EXPORT_FILE=${1#*=}
            shift 1
            ;;
        -r|--resume-from-file)
            if [ $# -gt 1 ] && [ "$(printf %.1s "$2")" != "-" ]; then
                RESUME_FILE=$2; shift 2
            else
                RESUME_FILE="${WORKING_DIR}/commits.txt"; shift 1
            fi
            ;;
        --resume-from-file=*)
            RESUME_FILE=${1#*=}; shift 1 ;;
        -t|--push-tags)
            PUSH_TAGS=true; shift 1 ;;
        -u|--undo-tags)
            UNDO_TAGS=true; shift 1 ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "  -C, --committer 'Name <email>'  Override committer identity"
            echo "  -b, --base-branch BRANCH        Base branch (default: current or main)"
            echo "  -n, --new-branch BRANCH         New branch (default: reworded-history)"
            echo "  -p, --patch-dir DIR             Patch directory (default: patches)"
            echo "  -m, --mapping-file FILE         Mapping file (default: commit-map.txt)"
            echo "  -w, --without-tags              Do not reattach tags"
            echo "  -e, --export [FILE]             Export commit messages (default: commits.txt)"
            echo "  -r, --resume-from-file [FILE]   Resume from file (default: commits.txt)"
            echo "  -t, --push-tags                 Push tags"
            echo "  -u, --undo-tags                 Undo local tags and restore from origin"
            echo "  -h, --help                      Show this help"
            exit 0 ;;
        *)
            echo "Unknown argument: $1"; exit 1 ;;
    esac
done

############################################################
# Main workflow
############################################################
mkdir -p "$WORKING_DIR"

if [ "$UNDO_TAGS" = true ]; then
    undo_tags
    exit 0
fi

if [ -n "$EXPORT_FILE" ]; then
    export_commits "$EXPORT_FILE"
    exit 0
fi

prepare_patches
if [ -n "$RESUME_FILE" ]; then
    apply_new_messages "$RESUME_FILE"
else
    interactive_edit
fi

apply_patches
[ "$WITH_TAGS" = true ] && reattach_tags || true
[ "$PUSH_TAGS" = true ] && push_tags || true

echo "Done."
echo "- New history on branch '$NEW_BRANCH'"
echo "- Commit mapping saved to '$MAPPING_FILE'"
[ "$WITH_TAGS" = true ] && echo "- All tags have been reattached." || echo "- Tags were not reattached."

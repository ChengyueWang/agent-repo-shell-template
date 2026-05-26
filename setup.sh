#!/bin/bash
set -uo pipefail
# NOTE: no `-e` — we want to soft-fail per entry so inaccessible repos
# (private, gone, network down) don't abort the whole bootstrap.

# =============================================================================
# CONFIG — edit these arrays to declare what this shell mounts.
# =============================================================================

# Repos under active development. Format: "name|url|branches"
# branches is comma-separated; one worktree per branch. Defaults to "main".
# All listed branches MUST exist on the remote.
#
# Defaults below set you up to develop the Agent Repo Shell extension itself
# (a working demonstration of the two-layer pattern). Replace with your own
# target(s) — anything from "myapp|git@github.com:USER/myapp.git|main" to
# multi-branch entries like "myapp|...|main,feature-x,bugfix-y".
TARGETS=(
  "agent-repo-shell|https://github.com/ChengyueWang/agent-repo-shell.git|main"
)

# Read-only upstream repos. Format: "path|url|branch"
# Added as git submodules under references/repos/. branch is optional.
REFERENCES=(
  "html-effectiveness|https://github.com/ThariqS/html-effectiveness.git"
)

# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OK_TARGETS=()
SKIP_TARGETS=()
OK_REFS=()
SKIP_REFS=()

clone_target() {
    local name="$1" url="$2" branches_csv="${3:-main}"
    local dir="targets/$name"

    if [ ! -d "$dir/.bare" ]; then
        mkdir -p "$dir"
        if ! git clone --bare "$url" "$dir/.bare" </dev/null; then
            echo "  [skip] $name: clone failed (no access? wrong URL? offline?)"
            rm -rf "$dir"
            SKIP_TARGETS+=("$name")
            return
        fi
    else
        echo "  $name: bare repo exists, fetching"
        git -C "$dir/.bare" fetch --all --prune --quiet \
            || echo "  [warn] $name: fetch failed (continuing)"
    fi

    IFS=',' read -ra branches <<< "$branches_csv"
    for branch in "${branches[@]}"; do
        branch="$(echo "$branch" | xargs)"  # trim
        if [ -d "$dir/$branch" ]; then
            echo "  $name/$branch: worktree exists"
            continue
        fi
        if git -C "$dir/.bare" worktree add "../$branch" "$branch" 2>/dev/null; then
            echo "  $name/$branch: worktree created"
        else
            echo "  [skip] $name/$branch: branch not on remote"
        fi
    done
    OK_TARGETS+=("$name")
}

add_reference() {
    local path="$1" url="$2" branch="${3:-}"
    local dest="references/repos/$path"
    if [ -d "$dest" ]; then
        echo "  $path: already exists"
        OK_REFS+=("$path")
        return
    fi
    local rc=0
    if [ -n "$branch" ]; then
        git submodule add -b "$branch" "$url" "$dest" || rc=$?
    else
        git submodule add --depth 1 "$url" "$dest" || rc=$?
    fi
    if [ "$rc" -eq 0 ]; then
        OK_REFS+=("$path")
    else
        echo "  [skip] $path: submodule add failed"
        SKIP_REFS+=("$path")
    fi
}

echo "=== Targets ==="
if (( ${#TARGETS[@]} > 0 )); then
    for entry in "${TARGETS[@]}"; do
        IFS='|' read -r name url branches <<< "$entry"
        clone_target "$name" "$url" "${branches:-}"
    done
else
    echo "  (none configured)"
fi

echo ""
echo "=== References ==="
if (( ${#REFERENCES[@]} > 0 )); then
    for entry in "${REFERENCES[@]}"; do
        IFS='|' read -r path url branch <<< "$entry"
        add_reference "$path" "$url" "${branch:-}"
    done
else
    echo "  (none configured)"
fi

echo ""
echo "=== Summary ==="
echo "  targets:    ${#OK_TARGETS[@]} ok, ${#SKIP_TARGETS[@]} skipped"
echo "  references: ${#OK_REFS[@]} ok, ${#SKIP_REFS[@]} skipped"
if (( ${#SKIP_TARGETS[@]} > 0 )); then
    echo "  skipped targets:    ${SKIP_TARGETS[*]}"
fi
if (( ${#SKIP_REFS[@]} > 0 )); then
    echo "  skipped references: ${SKIP_REFS[*]}"
fi
echo ""
echo "Next steps:"
echo "  1. Edit the TARGETS / REFERENCES arrays at the top of setup.sh"
echo "     and re-run this script to add more."
echo "  2. Install the Agent Repo Shell VSCode extension."
echo "  3. Open this folder in VSCode, run"
echo "     Cmd/Ctrl+Shift+P → 'Agent Repo Shell: Open View'"
echo ""
echo "Create a new worktree on an existing target:"
echo "  git -C targets/<name>/.bare worktree add ../<branch> -b explore/<branch>"

#!/usr/bin/env bash
# Continue across independent entries; return nonzero if any entry fails.
set -uo pipefail

# Active repositories: "name|url|branches". Branches default to main.
# Example: "myapp|git@github.com:YOUR-ORG/myapp.git|main,develop"
TARGETS=(
)

# Upstream submodules: "path|url|optional-branch".
REFERENCES=(
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1
CHECK=false
case "${1:-}" in
    '') ;;
    --check) CHECK=true ;;
    *) echo "Usage: $0 [--check]" >&2; exit 2 ;;
esac
if (( $# > 1 )); then echo "Usage: $0 [--check]" >&2; exit 2; fi

# Allow nested reference/branch paths, but never escape their parent directory.
valid_path() {
    [[ "$1" =~ ^[a-zA-Z0-9_-][a-zA-Z0-9._/-]*$ ]] &&
        [[ "/$1/" != *'/../'* && "/$1/" != *'/./'* && "$1" != */ && "$1" != *//* ]]
}

fail() { echo "  [fail] $*" >&2; return 1; }

verify_worktree() {
    local path="$1" bare="$2" branch="$3" common actual
    [[ -f "$path/.git" ]] || { fail "$path is not a linked worktree"; return 1; }
    common=$(git -C "$path" rev-parse --path-format=absolute --git-common-dir) || return 1
    actual=$(git -C "$path" symbolic-ref --quiet --short HEAD) || return 1
    [[ "$common" == "$(cd "$bare" && pwd -P)" && "$actual" == "$branch" ]] || {
        fail "$path has a different repository or branch"; return 1;
    }
}

clone_target() {
    local name="$1" url="$2" csv="${3:-main}" dir tmp branch remote rc=0
    local -a branches
    valid_path "$name" && [[ "$name" != */* && -n "$url" ]] || {
        fail "invalid target entry: $name"; return 1;
    }
    dir="targets/$name"
    IFS=',' read -r -a branches <<< "$csv"
    for branch in "${branches[@]}"; do
        valid_path "$branch" && git check-ref-format --branch "$branch" >/dev/null 2>&1 || {
            fail "$name: invalid branch $branch"; return 1;
        }
    done
    if [[ -L "$dir" || -L "$dir/.bare" ]]; then
        fail "$dir: refusing a symlink mount"; return 1
    fi
    if [[ ! -e "$dir/.bare" ]]; then
        if $CHECK; then fail "$name: missing bare repository"; return 1; fi
        mkdir -p "$dir" || return 1
        # Only the newly allocated temporary directory is cleaned up on failure.
        tmp=$(mktemp -d "$dir/.clone-XXXXXX") || return 1
        if ! git clone --bare -- "$url" "$tmp" </dev/null; then
            rm -rf -- "$tmp"
            fail "$name: clone failed; existing files preserved"; return 1
        fi
        mv -- "$tmp" "$dir/.bare" || return 1
    fi
    [[ "$(git -C "$dir/.bare" rev-parse --is-bare-repository 2>/dev/null)" == true ]] || {
        fail "$name: .bare is not a bare repository"; return 1;
    }
    remote=$(git -C "$dir/.bare" remote get-url origin) || return 1
    [[ "$remote" == "$url" ]] || { fail "$name: origin differs from configuration"; return 1; }
    if ! $CHECK; then
        # Bare clone does not install the normal remote-tracking fetch mapping.
        git -C "$dir/.bare" config --replace-all remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*' || return 1
        git -C "$dir/.bare" fetch --prune origin || {
            fail "$name: fetch failed"; return 1;
        }
    fi
    for branch in "${branches[@]}"; do
        if [[ -e "$dir/$branch" || -L "$dir/$branch" ]]; then
            verify_worktree "$dir/$branch" "$dir/.bare" "$branch" || rc=1
        elif $CHECK; then
            fail "$name/$branch: missing worktree"; rc=1
        elif ! git -C "$dir/.bare" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
            fail "$name/$branch: branch not on remote"; rc=1
        elif git -C "$dir/.bare" show-ref --verify --quiet "refs/heads/$branch"; then
            if git -C "$dir/.bare" worktree add "../$branch" "$branch"; then
                git -C "$dir/.bare" branch --set-upstream-to="origin/$branch" "$branch" || rc=1
            else
                rc=1
            fi
        else
            git -C "$dir/.bare" worktree add --track -b "$branch" "../$branch" "origin/$branch" || rc=1
        fi
    done
    return "$rc"
}

add_reference() {
    local path="$1" url="$2" branch="${3:-}" dest key registered=false
    valid_path "$path" && [[ -n "$url" ]] || { fail "invalid reference: $path"; return 1; }
    dest="references/repos/$path"
    # The submodule name need not equal its checkout path.
    while read -r key value; do
        if [[ "$value" == "$dest" ]]; then
            registered=true
            [[ "$(git config -f .gitmodules --get "${key%.path}.url")" == "$url" ]] || {
                fail "$path: registered URL differs from configuration"; return 1;
            }
            break
        fi
    done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null || true)
    if $registered; then
        if [[ ! -f "$dest/.git" ]]; then
            if $CHECK; then fail "$path: submodule not initialized"; return 1; fi
            git submodule update --init -- "$dest" || return 1
        fi
    else
        if $CHECK; then fail "$path: submodule not registered"; return 1; fi
        [[ ! -e "$dest" && ! -L "$dest" ]] || { fail "$dest already exists and is not registered"; return 1; }
        if [[ -n "$branch" ]]; then
            git submodule add -b "$branch" -- "$url" "$dest" || return 1
        else
            git submodule add -- "$url" "$dest" || return 1
        fi
    fi
    [[ "$(git -C "$dest" remote get-url origin)" == "$url" ]] || {
        fail "$path: checkout origin differs from configuration"; return 1;
    }
}

ok=0
failed=0
for entry in "${TARGETS[@]}"; do
    IFS='|' read -r name url branches <<< "$entry"
    if clone_target "$name" "$url" "${branches:-main}"; then
        echo "  [ok] target $name"; ok=$((ok + 1))
    else
        failed=$((failed + 1))
    fi
done
for entry in "${REFERENCES[@]}"; do
    IFS='|' read -r path url branch <<< "$entry"
    if add_reference "$path" "$url" "${branch:-}"; then
        echo "  [ok] reference $path"; ok=$((ok + 1))
    else
        failed=$((failed + 1))
    fi
done
echo "Mounts: $ok ok, $failed failed"
(( failed == 0 ))

# Agent Repo Shell

A workspace for coordinating independent code repositories. The shell tracks
shared tasks, skills, and knowledge; each mounted target owns its code and remote.

## Quick start

1. Use this GitHub template, clone your new repository, and open its directory.
2. Edit `TARGETS` and, optionally, `REFERENCES` in `setup.sh` (both default to empty).
3. Replace the project paragraph in `AGENTS.md` with your context and target responsibilities.
4. Run `./setup.sh`, then `python3 tools/check_workspace.py`.

Requires Bash, Git 2.31+ and Python 3.9+ for the read-only checker. Authenticate to private
remotes using your normal Git configuration. No editor extension is required.

```bash
# TARGETS entries: name|url|comma-separated-branches (default: main)
TARGETS=("myapp|git@github.com:YOUR-ORG/myapp.git|main,develop")
# REFERENCES entries: path|url|optional-branch
REFERENCES=("upstream|https://github.com/YOUR-ORG/upstream.git|main")
```

All configured target branches must already exist on the remote. Setup fetches
remote refs and creates missing worktrees; it never pulls, merges, or resets an
existing worktree. A failure does not prevent other entries from being attempted,
and any failed entry produces a nonzero exit status. Inspect the summary.
Existing reference submodules are initialized without updating an already populated
checkout. New references are registered with `git submodule add`; review and commit
`.gitmodules` and submodule entries in the shell.

## Layout and ownership

```text
AGENTS.md                    shared project instructions
CLAUDE.md                    imports AGENTS.md; Claude-specific additions only
skills/<name>/SKILL.md        canonical reusable procedures and supporting resources
.agents/skills/<name>         relative symlink to ../../skills/<name>
.claude/skills/<name>         relative symlink to ../../skills/<name>
tasks/{todo,doing,done}/      execution queue
knowledge/                   durable findings and cross-repository decisions
references/papers/          source papers
references/repos/           upstream submodules
tools/                       shell maintenance utilities
targets/<name>/.bare/        repository backing the target worktrees (ignored)
targets/<name>/<branch>/     code worktrees, each with its own remote (ignored)
scratch/                     local temporary outputs (ignored)
```

Target-specific specifications, implementation plans, tests, analysis programs,
and reproducibility records belong in the owning target. Large run products use
explicit storage paths. Live service state remains in its responsible service or
durable storage. Do not treat source-control snapshots as current service state.

There is no session-history directory or capture hook. Preserve useful findings
in `knowledge/` and follow-up work in `tasks/`. Obsidian is optional.

## Skills

Maintain one real directory per skill, including a `SKILL.md` with `name` and
`description` YAML frontmatter. Create both discovery links from the shell root:

```bash
ln -s ../../skills/my-skill .agents/skills/my-skill
ln -s ../../skills/my-skill .claude/skills/my-skill
```

Commit the source and symlinks together. Use a checkout/filesystem that preserves
Git symlinks; the workspace checker reports flattened or broken discovery links.
Skill-specific scripts or references live inside that skill; generated results do not.

## Worktrees

Create a new branch from the remote main branch:

```bash
git -C targets/myapp/.bare worktree add ../experiment -b explore/experiment origin/main
```

Merge from the receiving worktree, then remove the finished worktree:

```bash
git -C targets/myapp/main merge explore/experiment
git -C targets/myapp/.bare worktree remove ../experiment
```

Branch paths such as `feature/example` are supported. Do not configure overlapping
worktree paths such as both `feature` and `feature/example`.

## Verification

```bash
python3 tools/check_workspace.py
```

Checks configured mounts and remotes, worktree identity, ignored local storage,
skill frontmatter, and both discovery directories. It reports problems without
fetching, creating, deleting, or repairing anything.

The [Agent Repo Shell VSCode extension](https://marketplace.visualstudio.com/items?itemName=ChengyueWang.agent-repo-shell)
is an optional workspace browser. Its Sessions view has no captured sessions in
this template.

## License

MIT — see [LICENSE](LICENSE). Replace illustrative content to suit your project.

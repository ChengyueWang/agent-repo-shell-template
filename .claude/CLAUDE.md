# Project — agent shell template

This is an **agent shell**: a repo that holds your brain (specs / tasks /
skills / knowledge), not your code. The code being modified lives under
`targets/` as git worktrees, mounted by `setup.sh`.

## Structure

- `specs/` — source-of-truth design docs (one per feature or interface)
- `tasks/{todo,doing,done}/` — flat work queue, files migrate between dirs
- `skills/` — reusable procedures the agent can invoke (explore, distill, ...)
- `knowledge/`
  - `rules/` — **always-on hard constraints**, read every session
  - `*.md` — style guides, patterns, architecture notes (read on demand)
- `references/`
  - `repos/` — pinned upstream repos as submodules (read-only)
  - `notes/` — papers, snippets, exports
- `history/<session-id>/` — auto-captured prompts.md and responses.md per
  session (gitignored). Populated by the Stop hook in
  `tools/hooks/save-assistant-response.py`.
- `targets/<name>/<branch>/` — git worktree of the codebase being modified.
  Gitignored — each target pushes back to its own remote.

## Working on a target

Targets live as worktrees off `targets/<name>/.bare/`. To create a new
exploration branch:

```bash
git -C targets/<name>/.bare worktree add ../<branch> -b explore/<branch>
```

Merge back and clean up:

```bash
git -C targets/<name>/.bare merge <branch>
git -C targets/<name>/.bare worktree remove ../<branch>
```

## Conventions

- **Brain is tracked, workspace is mounted.** This repo only commits the
  agent's brain. Target repos are independent and push to their own remotes.
- **`rules/` is load-bearing.** Files under `knowledge/rules/` are treated
  as always-on hard constraints. Everything else under `knowledge/` is read
  on demand.
- **Task files** start with the date in the name (e.g.
  `20260101-add-feature.md`). They migrate between `tasks/todo/`,
  `tasks/doing/`, `tasks/done/` as work progresses. The Agent Repo Shell
  VSCode extension provides a UI to move them with a single click.

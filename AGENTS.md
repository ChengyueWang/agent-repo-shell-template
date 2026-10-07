# Project — agent shell

Replace this paragraph with the project's purpose and the responsibility of each
configured target. `setup.sh` declares the repositories mounted in this workspace.

## Ownership

- This shell owns cross-repository tasks, reusable skills, and curated knowledge.
- `targets/<name>/<branch>/` holds independent code repositories as Git worktrees.
  Each target commits and pushes to its own remote; read its instructions before editing.
- Target-specific contracts, implementation plans, tests, analysis programs, and
  reproducibility records belong in the owning target, alongside the implementation.
- `tasks/{todo,doing,done}/` holds execution tasks named `YYYYMMDD-slug.md`.
  Record context, intended work, and acceptance; move the file as work progresses.
- `knowledge/` holds durable findings and cross-repository decisions. Read relevant
  notes on demand; maintain each fact in one source and link conclusions to evidence.
- `references/repos/` holds upstream submodules; `references/papers/` holds source
  papers. Put your own conclusions in `knowledge/`.
- `skills/<name>/SKILL.md` is the canonical skill source, with only the supporting
  resources it needs. `.agents/skills/` and `.claude/skills/` contain relative symlinks
  to those directories. Edit the source, never maintain duplicate copies.
- `tools/` holds shell maintenance utilities. Generated outputs do not belong here
  or in skill directories. Use explicit output paths; `scratch/` is ignored local storage.

## Working guidance

Read the relevant task, skill, and target instructions before acting. Keep this
file limited to shared project context and persistent constraints; put detailed
procedures in the relevant skill or target documentation.

Preserve existing data and work. Keep runtime state in the responsible service or
explicit durable storage; a checked-in snapshot is evidence, not live state.
When reporting results, identify the method and distinguish new measurements from
previously recorded values.

Run `python3 tools/check_workspace.py` to check configured mounts and skill links.
`./setup.sh` bootstraps mounts; it does not merge or reset existing worktrees.

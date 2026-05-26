# Style rules (always-on)

> Files under `knowledge/rules/` are treated by the agent as **always-on
> hard constraints** — they're read every session, no matter the task.
> Keep this file short. Move tutorial-style content to `knowledge/*.md`
> instead.

## Code

- **Minimum diff.** Change only what the task requires. No incidental
  refactoring unless explicitly asked. Reviewers should be able to read
  the diff in 30 seconds.
- **No new abstractions on speculation.** A second similar case becomes a
  helper. Two cases is not "patterns".
- **No defensive code.** Trust internal callers and framework guarantees.
  Only validate at system boundaries.
- **Comment only the *why*.** Don't restate what the code does. Comments
  that age badly are worse than no comments.

## Specs

- One spec per feature/interface. Keep them under 100 lines.
- Acceptance criteria are *user-observable*: "type X, see Y", not "the
  function returns Z".

## Tasks

- File name starts with date: `YYYYMMDD-short-slug.md`.
- Task body = context + what to do + acceptance. ~30 lines max.
- Files move between `tasks/todo/` → `doing/` → `done/` as work
  progresses (the Agent Repo Shell extension provides a UI click for this).

## Sessions

- The Stop hook captures prompts and responses to `history/<id>/`. These
  files are gitignored — they're your local working space. If a session
  produced a summary worth keeping, write it into `knowledge/` explicitly.

# knowledge/

Two kinds of files live here:

| Where | What | Loading |
|-------|------|---------|
| `rules/*.md` | **Always-on hard constraints** | Read every session, no matter the task |
| `*.md` at this level | Style guides, patterns, architecture notes, glossaries | Read on demand (the agent fetches when relevant) |

**Keep `rules/` small.** It's expensive context — every file there is in
the agent's working memory all the time. If something is true *usually
but not always*, it belongs in a regular `.md` here, not in `rules/`.

## Suggested files

Some patterns you might want here (delete what doesn't apply):

- `architecture.md` — high-level system map
- `glossary.md` — domain terms used across specs and tasks
- `conventions.md` — naming patterns, file layout rules
- `decisions.md` — ADR-style log of important choices and their reasons

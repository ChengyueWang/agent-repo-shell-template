# Agent Repo Shell — Template

Starter for the **two-layer agent repo** pattern:
- **The shell** (this repo) — brain. Specs, tasks, skills, knowledge, session history.
- **The targets** (`targets/`) — code. Each is a git worktree of an upstream repo, mounted by `setup.sh`. Targets push to their own remotes.

Pair this repo with the [**Agent Repo Shell**](https://marketplace.visualstudio.com/items?itemName=ChengyueWang.agent-repo-shell) VSCode extension for a panel that browses the shell, renders specs / tasks / sessions, and visualizes target code (mermaid call graphs, function accordions, in-content find).

## Quick start

```bash
# 1. Click "Use this template" on GitHub, create your own repo
# 2. Clone your repo locally
git clone git@github.com:<you>/<your-repo>.git
cd <your-repo>

# 3. Edit the TARGETS array at the top of setup.sh to point at your code
$EDITOR setup.sh

# 4. Bootstrap — clones each target as bare + worktrees per branch,
#    adds each reference as a git submodule.
./setup.sh

# 5. Install the Agent Repo Shell VSCode extension
#    (Cmd/Ctrl+Shift+X → search "Agent Repo Shell")

# 6. Open the folder in VSCode
#    Cmd/Ctrl+Shift+P → "Agent Repo Shell: Open View"
```

## Defaults out of the box

Out of the box, `setup.sh` clones:

- **target**: `agent-repo-shell` (the VSCode extension's own source) — so you can dogfood the extension while developing it. Replace with your own.
- **reference**: `html-effectiveness` — the visual style this extension borrows from.

Edit `setup.sh` to swap or extend.

## Structure

```
.
├── specs/                  source-of-truth design docs
├── tasks/
│   ├── todo/               work queue
│   ├── doing/              in-progress
│   └── done/               completed (move on completion — the extension provides a UI click)
├── skills/                 reusable procedures the agent invokes
├── knowledge/
│   ├── rules/              ALWAYS-ON hard constraints (read every session)
│   └── *.md                style guides, patterns, ADRs (read on demand)
├── references/
│   ├── repos/              pinned upstream repos as submodules
│   └── notes/              papers, snippets, exports
├── history/                per-session prompts.md + responses.md (gitignored)
├── targets/                code being modified — git worktrees (gitignored)
└── tools/hooks/            session capture hook for Claude Code
```

Open `.claude/CLAUDE.md` for the canonical agent-facing description.

## Session capture

`.claude/settings.json` registers `tools/hooks/save-assistant-response.py`
as the Claude Code **Stop hook**. After each turn it reads the transcript
JSONL and rebuilds:

- `history/<session-id>/prompts.md` — all your prompts, dated
- `history/<session-id>/responses.md` — extracted assistant responses

The extension's **💬 Sessions** view renders both as chat bubbles.

> If you're using **the extension on a workspace that's NOT cloned from
> this template**, the extension provides a one-click setup:
> `Cmd/Ctrl+Shift+P → "Agent Repo Shell: Install Session Capture Hook"`.

## The two-layer philosophy

- **Brain is tracked, code is mounted.** The shell repo only commits
  your agent's brain. Target repos are independent and push to their own
  remotes — including ones you can't share (private, NDA, internal).
- **Worktree-first.** Every active branch gets its own directory under
  `targets/<name>/<branch>/` so the agent can work on multiple branches
  in parallel without `checkout` thrash.
- **Rules are load-bearing.** Anything under `knowledge/rules/` is
  read every session. Everything else under `knowledge/` is on-demand.

## Worktree commands

Create a new exploration branch on an existing target:

```bash
git -C targets/<name>/.bare worktree add ../<branch> -b explore/<branch>
```

Merge and clean up:

```bash
git -C targets/<name>/.bare merge <branch>
git -C targets/<name>/.bare worktree remove ../<branch>
```

## License

MIT — see [LICENSE](LICENSE). Sample content (specs / tasks / skills /
rules) is illustrative; replace freely.

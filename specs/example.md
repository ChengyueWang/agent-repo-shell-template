# Example spec — sidebar filter input

> This is an **example spec** showing the format. The spec describes a
> feature of the Agent Repo Shell extension as if you were planning it
> from scratch. Replace with your own.

## Goal

Add a text input at the top of the sidebar that filters the rendered file
tree by name. Pressing `/` anywhere in the panel focuses the input.
Pressing `Esc` clears + blurs.

## Constraints

- Filter must run synchronously per keystroke (no debounce; the tree is
  small enough that filtering is sub-millisecond).
- Matching files keep their parent `<details>` open even when those
  sections were previously collapsed.
- A sidebar rebuild (favorite/hide toggle) must **re-apply the active
  filter automatically**, so the user doesn't see stale state.
- The filter only acts on the sidebar tree. The main content pane has its
  own find widget (`Ctrl/Cmd+F`).

## Surface

- Input element rendered just below the workspace-name eyebrow, inside the
  scrolling sidebar.
- Placeholder: `search files…`
- Hover tooltip (custom, not native `title`): two-line hint explaining
  example use + the `/` shortcut.
- Class `.filter-hide` on rows that don't match; CSS `display: none`.

## Out of scope

- Fuzzy matching (substring is enough for now).
- Highlighting matched substrings inside the filename (consider after
  v0.2 if users ask for it).
- Persisting the filter query across reloads (the panel reloads frequently
  enough that this would be confusing).

## Acceptance

- Type `extension` → only files whose name or path contains "extension"
  remain visible. Parent folders auto-expand.
- Press `Esc` → input clears, all rows visible again.
- Right-click a visible file → ★ Favorite it → sidebar rebuilds → filter
  is still applied (favorited row stays visible too).

# Add a "Clear all hidden" button to the sidebar

> This is an **example task** showing the format. Replace with your own.

## Context

Right now users can right-click a file or folder → Hide. To unhide, they
have to click the "show N hidden" toggle in the eyebrow, then right-click
each hidden entry → Unhide. That's tedious if they hid 20 things.

## What to do

Add a small "Clear all" link inside the hidden-toggle row in the eyebrow
that, when clicked, empties the `hidden` set in localStorage and rebuilds
the sidebar.

## Acceptance

- When `hidden.size === 0`, the link doesn't appear (no point).
- When `hidden.size > 0`, the link reads `clear N` next to the existing
  `show N hidden` toggle.
- Clicking confirms via a small native `confirm()` dialog (since this is
  destructive and the user might have hidden things they want to keep
  hidden long-term).
- After confirm, all rows become visible and the eyebrow toggle hides.

## Notes

- Files: `extension.js`, search for `updateHiddenToggle` and add the link
  there.
- Don't conflict with the existing `show hidden` toggle — wrap both in a
  flex container, separate with a dot delimiter.
- Persist immediately via `saveHidden()`.

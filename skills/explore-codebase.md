# Skill — explore a codebase

> This is an **example skill** showing the format. A skill is a reusable
> procedure the agent can invoke when it needs to do this kind of work.

## When to invoke

Use this skill at the start of any task that touches code you haven't
read before. Skip it if the task is purely doc / config editing.

## Steps

1. **Read the entry points first.** Find the entry point(s): `main`,
   `extension.js`'s `activate()`, the route handler in a web app, etc.
   Read top-to-bottom to map the high-level flow.

2. **Find the data model.** Where does state live? In-memory dict, a
   database schema, a JSON file, localStorage? The data model often
   explains the code structure better than the code itself.

3. **Spot the seams.** Look for `if`/`switch` on a config flag, function
   parameters with default values, conditional imports — these are the
   project's natural extension points.

4. **Sample 1-2 leaf modules.** Pick the modules that look most relevant
   to your task and read them carefully. Don't try to read everything —
   you're sampling, not surveying.

5. **Re-read the entry point.** Now that you know the data model and
   seams, the entry point reads completely differently. Spend 2 minutes
   here to consolidate.

## Anti-patterns

- **Don't grep before reading.** Grep is for finding specific known
  strings. Use it after step 1, not as a substitute for it.
- **Don't read tests first.** Tests describe contracts but they're noisy
  (mocks, fixtures, edge cases). Read the source first, tests second.
- **Don't ask Claude "what does this codebase do?"** until you've done
  step 1. The answer it gives will be too high-level to be useful, and
  you'll have learned nothing.

## Done when

You can answer: (a) what's the entry point, (b) where does state live,
(c) where are the natural extension points for the kind of change you're
about to make.

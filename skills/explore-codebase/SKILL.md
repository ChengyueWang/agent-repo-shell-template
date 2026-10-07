---
name: explore-codebase
description: Map an unfamiliar target repository for a specific change or explain its relevant architecture, tracing entry points, state, and validation paths.
---

# Explore a target codebase

Start from the user's question and identify the owning target. Read its local
instructions and relevant documentation; do not assume this shell owns its code.

Choose the most useful starting point: a named symbol, an entry point, a failing
test, or a search for the observed behavior. Trace only the paths needed to answer
the question, including state ownership and boundaries between targets.

Report the relevant files and relationships, evidence for your conclusions, and
any unresolved questions. For a requested change, identify the implementation
location and meaningful validation. Exploration alone does not authorize edits.

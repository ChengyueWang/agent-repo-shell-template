# Example — coordinate an interface change across targets

Replace this example with a dated task such as `20261006-update-client-contract.md`.

## Context

A producer target is changing an interface used by a consumer target. The shell
tracks the coordination; the interface specification and tests belong in their
respective targets.

## Work

- Identify the producing and consuming repositories and link their relevant contracts.
- Implement the change and compatibility handling in the owning targets.
- Record the target commits and validation results here when complete.

## Acceptance

The consumer handles the updated producer output, the target-specific checks pass,
and this task links the evidence. Move the task to `done/` when complete.

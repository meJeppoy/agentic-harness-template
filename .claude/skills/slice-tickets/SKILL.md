---
name: slice-tickets
description: Break an approved spec into tracer-bullet tickets (vertical slices), each declaring its blocking edges and the acceptance criteria it delivers, published to the project's tracker. Use after /write-spec.
disable-model-invocation: true
---

<!-- Adapted from mattpocock/skills@49dd158 (to-tickets), MIT. See THIRD_PARTY.md. -->

# Slice tickets

Break a spec into **tickets**: tracer-bullet vertical slices, each declaring the tickets that **block** it.

## Process

### 1. Gather context

Work from the conversation. If the user passes a spec path (`docs/designs/<feature>.md`) or issue reference, read it in full. Find the tracker in `docs/DECISIONS.md` D-003 (GitHub Issues, Linear, or local files); if it's still a placeholder, ask the user and record their answer there.

### 2. Explore the codebase

Understand the current state of the code. Use `CONTEXT.md` vocabulary and respect ADRs. Look for prefactoring that makes the work easier: "Make the change easy, then make the easy change."

### 3. Draft vertical slices

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests): vertical, not one horizontal layer.
- A completed slice is demoable or verifiable on its own.
- Each slice fits in a single fresh context window (one session).
- Prefactoring comes first.
- Each slice lists which spec acceptance criteria (AC1, AC2, ...) it delivers; together the slices cover every AC.

Give each ticket its **blocking edges**: the tickets that must complete before it can start.

**Wide refactors are the exception.** One mechanical change whose blast radius fans across the codebase (rename a column, retype a shared symbol) is sequenced **expand → migrate in batches → contract**, so CI stays green batch to batch.

### 4. Quiz the user

Present the breakdown as a numbered list: **Title**, **Blocked by**, **What it delivers**, **ACs covered**. Ask whether the granularity is right, the blocking edges are real, and any tickets should merge or split. Iterate until the user approves. Then mark the spec `Status: approved (date)`.

### 5. Publish to the tracker

- **Local files** → one file per ticket at `docs/tickets/<feature-slug>/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first), using the template below. Never one combined file.
- **GitHub Issues / Linear** → one issue per ticket in dependency order, native blocking links where the platform has them, otherwise a "Blocked by" section. Link the spec file.

Work the **frontier**: any ticket whose blockers are all done.

<ticket-template>

# <NN>: <Ticket title>

**Spec:** docs/designs/<feature-slug>.md · **Delivers:** AC1, AC3

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective.

**Blocked by:** <ticket numbers/titles>, or "None (can start immediately)".

**Status:** ready

- [ ] Acceptance criterion (observable, testable)

</ticket-template>

Avoid file paths and code snippets in tickets: they go stale.

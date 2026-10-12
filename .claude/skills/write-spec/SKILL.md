---
name: write-spec
description: Turn the grilled conversation into a spec at docs/designs/<feature>.md with numbered acceptance criteria. No interview, just synthesis of what was already discussed. Use after /grill.
disable-model-invocation: true
---

<!-- Adapted from mattpocock/skills@49dd158 (to-spec), MIT. See THIRD_PARTY.md. -->

# Write spec

Take the current conversation and codebase understanding and produce a spec. Do NOT interview the user; synthesize what you already know. If something essential was never decided, say so and suggest another `/grill` round instead of guessing.

## Process

1. Explore the repo to understand the current state of the code, if you haven't already. Use the vocabulary in `CONTEXT.md` throughout and respect ADRs in `docs/adr/` for the area you're touching.
2. Sketch the **seams** at which the feature will be tested: the public boundaries where behaviour is observed. Prefer existing seams; use the highest seam possible; the fewer, the better. Check with the user that these seams match their expectations.
3. Write the spec to `docs/designs/<feature-slug>.md` using the template below. The file is the single source of truth for the spec (DECISIONS D-007); don't duplicate it into the tracker.
4. Ask the user to approve it. **No code is written until the spec and its tickets are approved** (docs/HARNESS.md). Then suggest `/slice-tickets`.

<spec-template>

# Spec: <Feature name>

Status: draft | approved (YYYY-MM-DD)

## Intent

One paragraph, from the user's perspective: what problem this solves and why now.

## Solution

The solution, from the user's perspective.

## Acceptance criteria

Numbered, observable, testable statements. Each becomes at least one named test, and the verifier checks that mapping.

1. AC1: <a user can ... / the system rejects ...>
2. AC2: ...

## User stories

A long, numbered list covering all aspects of the feature: "As a <actor>, I want <feature>, so that <benefit>".

## Implementation decisions

Modules built or modified, their interfaces, architectural decisions, schema changes, API contracts, technical clarifications. No file paths or code snippets (they go stale), except a prototype snippet that encodes a decision more precisely than prose (state machine, schema, type shape), trimmed to the decision-rich parts.

## Testing decisions

What makes a good test here (external behaviour, not implementation details), which seams are tested, and prior art in the codebase.

## Out of scope

## Further notes

</spec-template>

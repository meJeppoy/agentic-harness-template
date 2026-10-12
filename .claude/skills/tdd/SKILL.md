---
name: tdd
description: Test-driven development (red → green → refactor). Use when building a ticket, adding a feature, or fixing a bug test-first, or when the user mentions TDD or red-green-refactor.
---

<!-- Adapted from mattpocock/skills@49dd158 (tdd), MIT. See THIRD_PARTY.md. -->

# Test-Driven Development

TDD is the red → green → refactor loop (CLAUDE.md iron rule 3). This skill makes the loop produce tests worth keeping. Every section applies on every cycle.

Read `CONTEXT.md` so test names match the domain language, respect ADRs in the area, and read the ticket's spec (`docs/designs/<feature>.md`): its numbered acceptance criteria are what the tests prove.

## What a good test is

Tests verify behaviour through public interfaces, not implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification: "user can check out with a valid cart" tells you what capability exists, and it survives refactors. Name each test after the acceptance criterion it proves (e.g. `test_ac2_empty_cart_cannot_check_out`) so the owner and the verifier can trace spec → test.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for when to mock.

## Seams: where tests go

A **seam** is the public boundary you test at. **Test only at agreed seams**: before writing a test, name the seam and confirm it with the user (or use the seams already agreed in the spec). Give each proposed seam a one-line note on what it catches and what it misses.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: it breaks on refactor while behaviour is unchanged.
- **Tautological**: the expected value is recomputed the way the code computes it (`expect(add(a, b)).toBe(a + b)`), so it can never disagree with the code. Expected values come from an independent source: a known literal, a worked example, the spec.
- **Horizontal slicing**: all tests first, then all code. Work in vertical slices: one test → one implementation → repeat.

## The loop, with the red-step marker

The Stop hook won't let a turn end while tests fail, so the red step is declared explicitly:

1. **Red.** Create the marker: `touch .claude/red-step`. Write ONE failing test for the next acceptance criterion. Run it and show it failing for the right reason (not an import error). While the marker exists, the Stop hook gates lint and typecheck only, and the user is told a red step is open.
2. **Green.** Write only enough code to pass. Run `scripts/check.sh full`. When green, remove the marker: `rm .claude/red-step`. Never leave it behind: pre-push refuses to push while it exists.
3. **Refactor.** With tests green, improve names and structure without changing behaviour; re-run checks after each change. Ponytail's ladder applies: delete before you add.

One seam, one test, one minimal implementation per cycle. Don't anticipate future tests or add speculative features. Never weaken or delete a test to get green; if a test is wrong, say so and get the user's agreement first.

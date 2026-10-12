---
name: grill
description: Relentless interview that sharpens a feature idea, plan, or design until every decision is settled, recording domain terms in CONTEXT.md and hard-to-reverse decisions as ADRs along the way. Use at the start of every feature or change, or when the user says "grill me".
disable-model-invocation: true
---

<!-- Adapted from mattpocock/skills@49dd158 (grilling + domain-modeling), MIT. See THIRD_PARTY.md. -->

# Grill

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it. Read `CONTEXT.md` and `docs/adr/` first so you speak the project's language and don't re-litigate settled decisions (`docs/DECISIONS.md` too).

## Rounds

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommended answer. Many users aren't engineers: explain trade-offs in plain language and say what each option means for them.

Each round reshapes the tree: settled decisions push the frontier outward. A question whose answer depends on another question still open in this round belongs to a _later_ round.

Finding _facts_ is your job, never the user's. When a question needs a fact from the environment (code, files, tools), dispatch a sub-agent to find it; don't ask the user for anything you could look up. Only the questions downstream of a running lookup wait for it. The _decisions_ are the user's: put each to them and wait.

## Sharpen the domain language as you go

- **Challenge against the glossary.** When the user uses a term that conflicts with `CONTEXT.md`, call it out: "Your glossary defines 'cancellation' as X, but you seem to mean Y. Which is it?"
- **Sharpen fuzzy terms.** "You're saying 'account': do you mean the Customer or the User?"
- **Probe with concrete scenarios** that force precise boundaries between concepts.
- **Cross-reference with code.** If the code contradicts what the user says, surface it.
- **Update `CONTEXT.md` the moment a term is resolved**, in its table format. One or two sentences per term, what it IS, no implementation details. Pick one name per concept and list the rejected names under "NOT to be confused with".

## ADRs, sparingly

Offer an ADR (`docs/adr/NNNN-slug.md`, next number up; one paragraph is enough: context, decision, why) only when all three hold: **hard to reverse**, **surprising without context**, and **the result of a real trade-off**. Smaller decisions are one line in `docs/DECISIONS.md`.

## Done

The grill is done when the frontier is empty: every branch visited, nothing silently assumed. Summarise the settled decisions, confirm with the user that you share an understanding, then suggest `/write-spec`. Do not start building.

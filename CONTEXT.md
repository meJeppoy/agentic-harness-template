# CONTEXT — domain language

The shared language between you and the agent. Built and maintained by `/grill-with-docs` and the domain-modeling skill — expect it to grow; prune terms that die. One term, one meaning; if two names exist for one thing, kill one.

Format:

## Glossary

| Term | Means | NOT to be confused with |
|---|---|---|
| _(seeded during your first grilling session)_ | | |

## Invariants worth naming

_(Rules of the domain that code must never violate — e.g., "an Order is immutable after submission." Added as they surface.)_

## Pointers

Architecture decisions with reasoning live in `docs/adr/`. If a term needs a paragraph of explanation, it's an ADR, not a glossary row.

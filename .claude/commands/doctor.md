---
description: Check the harness is fully working and explain how to fix anything that isn't
---

Run `scripts/doctor.sh` and show its output as-is (it's short). Then, in plain English:

- For each FAIL: what it breaks for the user and the exact fix. Offer to run fixes that are safe and local (e.g. `git config core.hooksPath scripts/git-hooks`); anything that installs software, changes GitHub settings, or touches accounts is the user's to run, so give them the command.
- For WARNs: one line on what protection is missing, most important first.
- If everything passes: say so in one line.

If `gh` checks fail inside the sandbox with a TLS/certificate error, re-run the script outside the sandbox: that's a known macOS sandbox limitation for Go programs, not a problem with the setup.

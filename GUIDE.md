# The Complete Getting-Started Guide

*From zero to your first AI-built feature — written for everyone, whether you've coded for ten years or never opened a terminal.*

This guide assumes nothing. If you already have the tools, skip Part 1. Total time from absolute zero: about an hour. After that, starting each new project takes ~15 minutes.

---

## What is this, in plain English?

Claude Code is an AI that writes software for you. It's powerful but forgetful — every conversation starts from a blank slate, and on long projects it drifts: it forgets decisions, rebuilds things that exist, says "done" when tests are failing, and over-engineers.

This template fixes that. It's a pre-built folder structure you start every project from. It gives the AI four things:

1. **A process** — before writing any code, the AI interviews you until it truly understands what you want (the "grilling"), writes it down as a spec with a checklist of what "done" means, and only builds once you approve.
2. **A memory** — decisions, progress, and your project's vocabulary live in files, not in the AI's head. Every session, the AI reads them and picks up exactly where you left off.
3. **Gates** — rules that are *enforced*, not just requested: the AI can't finish its work while tests are failing, can't read your passwords file, and can't push unchecked code to your main branch.
4. **A health check** — one command, `/doctor`, tells you if anything is missing and exactly how to fix it.

You don't need to understand how it works to use it. Follow the steps.

---

## Part 1 — Install the tools (one-time, ~20 min)

You need five things. Check what you have; install what's missing.

### 1.1 A GitHub account
Sign up free at [github.com/signup](https://github.com/signup). GitHub stores your project and its history.

### 1.2 Git, Node.js, VS Code, and the GitHub CLI

- **VS Code** (your editor): [code.visualstudio.com](https://code.visualstudio.com)
- **Git** (version control): [git-scm.com/downloads](https://git-scm.com/downloads) — Mac users: it may already be installed
- **Node.js** (needed by the installers): [nodejs.org](https://nodejs.org) — pick the LTS version
- **GitHub CLI** (lets the AI open pull requests): [cli.github.com](https://cli.github.com), then run `gh auth login` once

**Windows users:** install **WSL2** ([learn.microsoft.com/windows/wsl/install](https://learn.microsoft.com/windows/wsl/install)) and do everything inside its Ubuntu terminal. Claude Code's safety sandbox only runs on macOS, Linux, and WSL2; without it the template falls back to a weaker guard.

**Check everything** — open the Terminal app (Mac: `Cmd+Space`, type "Terminal") and run each line:

```bash
git --version     # want: any version number
node --version    # want: v20 or higher
gh --version      # want: any version number
```

If a command prints a version number, you're good. If it says "command not found," that tool isn't installed yet.

### 1.3 Claude Code

You need a Claude subscription (Pro or Max) or an API key from [claude.com](https://claude.com). Then follow the install steps at [code.claude.com/docs](https://code.claude.com/docs). Test it: type `claude` and press Enter. The first run walks you through logging in. Type `/exit` to leave.

---

## Part 2 — Create your project from the template (~5 min)

1. Open the template repo on GitHub and click the green **"Use this template"** button → **"Create a new repository."**
2. Name it after your project (e.g., `recipe-app`) and choose **Public** or **Private** — read this first:
   - **Public** (anyone can see the code): GitHub protects your main branch and scans for leaked passwords **for free**. Best protection.
   - **Private** on a free GitHub account: GitHub **can't** protect your main branch or scan for secrets. The template's local safety hook still guards your own machine, but that's a weaker net. If your project must be private, consider GitHub Pro.
   - Not sure? Public is the safer default for learning projects. `docs/REPO-SECURITY.md` has the full table.
3. Get it onto your computer. On your new repo's page, click the green **Code** button and copy the URL, then in the terminal:

```bash
git clone <paste-the-url-here>
cd <your-repo-name>
```

4. Open it in VS Code: **File → Open Folder** → pick your repo folder (or type `code .`).

---

## Part 3 — Run the setup (~15 min)

### 3.1 The init script

In VS Code, open the built-in terminal (**Terminal → New Terminal**) and run:

```bash
./scripts/init.sh
```

It asks two questions.

**Your project's main language:**
- Building something in **Python** (data work, scripts, AI tools)? → type `1`
- Building a **website or app in TypeScript/JavaScript**? → type `2`
- **Don't know?** → type `3`. The AI will pick the right toolchain with you later. This is a completely fine answer.

If you picked 1 or 2, it also installs the tools for that language (it will tell you if something like `uv` or `pnpm` is missing, with a link).

**AI review on pull requests?** Answer `N` for now. You can turn it on later (Part 6).

### 3.2 Save your setup

```bash
git add -A
git commit -m "chore: harness setup"
git push
```

Now switch on your local safety hook (it stops direct pushes to your main branch from now on, so do this *after* the push above):

```bash
git config core.hooksPath scripts/git-hooks
```

### 3.3 Install the two plugins

Start Claude Code in the same terminal:

```bash
claude
```

Claude may ask whether you trust this folder — say yes. Then type each line as its own message:

```
/plugin install superpowers@claude-plugins-official
```
```
/plugin marketplace add DietrichGebert/ponytail
```
```
/plugin install ponytail@ponytail
```

Then `/exit` and start `claude` again so they load.

> **What did I just install?** Two open-source plugins: [Superpowers](https://github.com/obra/superpowers) helps the AI execute big features safely in isolated copies of your project, and [Ponytail](https://github.com/DietrichGebert/ponytail) stops it from over-engineering. The interview-and-build process itself already lives inside your project (`.claude/skills/`), so nothing else needs installing.

### 3.4 Check everything

In Claude Code, type:

```
/doctor
```

You'll get a list of PASS / WARN / FAIL lines, each with the fix. Fix every FAIL (ask Claude to help: *"Help me fix the doctor failures"*). WARNs tell you which protections are missing — read them, fix what you can.

### 3.5 Tell the AI about YOUR project

Open `CLAUDE.md`. You'll see `{{PLACEHOLDERS}}` — fill them in plain English. One honest paragraph beats a fancy spec:

> *"RecipeBox is a website where my family stores and searches our recipes. Users: my family, ~10 people. Must work on phones."*

Also decide where your to-do items (tickets) live — **beginners: "local files"** (they stay in your project folder) — and write it in `docs/DECISIONS.md` row D-003. Put your first goal in `docs/ROADMAP.md` (one line: "v1: family members can add and search recipes").

**Shortcut:** in Claude Code say *"Read CLAUDE.md and interview me briefly to fill in every placeholder, including the tracker choice in docs/DECISIONS.md, then show me the result before saving."*

Commit again when done (Claude can do it for you on a branch).

---

## Part 4 — The first session (~30 min)

Open `KICKOFF-PROMPT.md`, copy everything between the two horizontal lines, start `claude`, and paste it.

The AI works through **four stages, stopping for your approval after each**:

| Stage | What happens | What you do |
|---|---|---|
| 1. Orient | AI reads the project files and reports what it understood | Wrong anywhere? Say so — it fixes the files |
| 2. Verify | AI runs `/doctor` and explains the results | Approve the fixes it proposes |
| 3. Baseline | AI runs the whole workflow once on a tiny change, end to end | Watch. This is the whole workflow in miniature |
| 4. First grill | AI interviews you about your first real feature — relentlessly | Answer honestly. "I don't know" is valid; it will propose options |

By the end of stage 4, your idea has become a written spec (in `docs/designs/`) with a numbered checklist of what "done" means, split into small buildable tickets — and the AI wrote down your project's vocabulary in `CONTEXT.md`. Then it wraps up with `/session-end`. **You're initialized.**

---

## Part 5 — The everyday rhythm

Every work session is the same three beats:

```
/session-start        ← health check + where you left off, what's next, what's blocked
   ...work...         ← build ONE ticket (see below)
/session-end          ← AI saves all progress to files, so next session resumes perfectly
```

And building a feature is always the same loop:

1. **`/grill`** — the interview. Do this for *every* change, even small ones. Misunderstanding is the #1 way software fails.
2. **`/write-spec`** then **`/slice-tickets`** — the conversation becomes a spec with acceptance criteria, then small tickets. **Read them and approve** — nothing gets built before you do.
3. **Build one ticket at a time.** Say: *"Let's build ticket 1 with tdd."* The AI writes a failing test first, then makes it pass — proof it works. It literally cannot finish while tests fail.
4. **Review.** Say: *"Run /code-review, /security-review, then the verifier, then /ponytail-review."* Four critics: is it correct, is it safe, does every requirement have a test, is it over-built.
5. **Merge and repeat.** The AI opens a pull request; you read the plain-English summary and press merge on GitHub.

### The five golden rules

1. **Never skip the grill.** Even for "small" changes.
2. **Never skip `/session-end`.** It's how the project remembers.
3. **One ticket per session** when starting out. Type `/clear` between tickets.
4. **Never merge what you can't explain.** Ask: *"Explain this change like I'm reviewing it."* If the answer surprises you, don't merge.
5. **When the AI goes in circles:** `/clear`, then `/session-start`, then try again smaller.

---

## Part 6 — Optional: AI review on every pull request

A second AI reads each of your pull requests and leaves comments (it never changes code or blocks merging). Each review uses your Claude plan's usage.

1. Run `HARNESS_AI_REVIEW=y ./scripts/init.sh` (re-running init is safe; it never overwrites your files).
2. In Claude Code run `/install-github-app` and follow the prompts — it connects GitHub and stores the access token as a repo secret for you.
3. Commit and push. Your next pull request gets a review comment.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Not sure what's wrong | `/doctor` — it checks everything and tells you the fix. |
| `command not found: claude` | Claude Code isn't installed or the terminal needs restarting. Re-run the Part 1 checks. |
| `./scripts/init.sh: Permission denied` | Run `chmod +x scripts/init.sh`, then retry. |
| `/grill` (or another skill) unknown | You're not in the project folder, or Claude needs a restart (`/exit`, then `claude`). |
| AI ignores the process and codes immediately | Say: *"Stop. Follow docs/HARNESS.md — /grill first."* |
| "Project checks are failing, so this turn isn't done" | Working as intended: the AI must fix the failing tests. If it can't after 3 tries it stops and tells you — ask it to explain the failure. |
| A command fails with "Operation not permitted" | The safety sandbox blocked it. Usually Claude retries with your permission; if it keeps happening, run `/sandbox` to see why. |
| `git push` says "Direct push to main blocked" | Working as intended: push a branch and open a pull request (ask Claude to do it). |
| PR won't merge, "waiting for status check" | Your CI job must be named `ci` (see `docs/REPO-SECURITY.md`). |
| Everything is confusing | In Claude Code: *"Read GUIDE.md and PLAYBOOK.md and tell me what I should do next, step by step."* The harness can explain itself. |

## Mini-glossary

**Repo** — your project folder, tracked by GitHub. · **Terminal** — the text window where you type commands. · **Grilling** — the AI interviewing you until requirements are unambiguous. · **Spec** — the written description of a feature, with numbered acceptance criteria. · **Acceptance criterion** — one testable statement of what "done" means. · **Ticket** — one small buildable task. · **TDD** — write a failing test first, then code until it passes. · **PR (pull request)** — a proposed change you approve before it becomes permanent. · **CI** — automatic checks that run on every PR. · **Merge** — accepting a PR into the real project. · **Sandbox** — a fence around the AI's commands that keeps it away from your secrets.

---

*Built on [Superpowers](https://github.com/obra/superpowers), [Ponytail](https://github.com/DietrichGebert/ponytail), and skills adapted from [Matt Pocock's skills](https://github.com/mattpocock/skills) — all MIT-licensed. Deeper reading once you're comfortable: `PLAYBOOK.md` (the full workflow) and `docs/HARNESS.md` (how the pieces divide the work and what's enforced).*

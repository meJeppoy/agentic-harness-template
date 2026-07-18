# The Complete Getting-Started Guide

*From zero to your first AI-built feature — written for everyone, whether you've coded for ten years or never opened a terminal.*

This guide assumes nothing. If you already have the tools, skip Part 1. Total time from absolute zero: about an hour. After that, starting each new project takes ~15 minutes.

---

## What is this, in plain English?

Claude Code is an AI that writes software for you inside your editor. It's powerful but forgetful — every conversation starts from a blank slate, and on long projects it drifts: it forgets decisions, rebuilds things that exist, and over-engineers.

This template fixes that. It's a pre-built folder structure you start every project from. It gives the AI three things:

1. **A process** — before writing any code, the AI interviews you until it truly understands what you want (this is the "grilling"). Then it works in small, testable steps.
2. **A memory** — decisions, progress, and your project's vocabulary live in files, not in the AI's head. Every session, the AI reads them and picks up exactly where you left off.
3. **Guardrails** — the AI can't read your passwords, can't push unreviewed code, and is trained (by the installed skills) to write the *least* code that works.

You don't need to understand how it works to use it. Follow the steps.

---

## Part 1 — Install the tools (one-time, ~20 min)

You need four things. Check what you have; install what's missing.

### 1.1 A GitHub account
Sign up free at [github.com/signup](https://github.com/signup). GitHub stores your project and its history.

### 1.2 Git, Node.js, and VS Code

- **VS Code** (your editor): download from [code.visualstudio.com](https://code.visualstudio.com)
- **Git** (version control): [git-scm.com/downloads](https://git-scm.com/downloads) — Mac users: it may already be installed; see the check below
- **Node.js** (needed by the installers): [nodejs.org](https://nodejs.org) — pick the LTS version

**Check everything** — open the Terminal app (Mac: `Cmd+Space`, type "Terminal"; Windows: install & use "Git Bash" which came with Git) and run each line:

```bash
git --version     # want: any version number
node --version    # want: v20 or higher
```

If a command prints a version number, you're good. If it says "command not found," that tool isn't installed yet.

### 1.3 Claude Code

You need a Claude subscription (Pro or Max) or an API key from [claude.com](https://claude.com). Then, in the terminal:

```bash
npm install -g @anthropic-ai/claude-code
```

Test it: type `claude` and press Enter. First run walks you through logging in. Type `/exit` to leave.

> **Stuck?** The official install docs cover every OS quirk: [code.claude.com/docs](https://code.claude.com/docs)

---

## Part 2 — Create your project from the template (~5 min)

1. Open the template repo on GitHub and click the green **"Use this template"** button → **"Create a new repository."**
2. Name it after your project (e.g., `recipe-app`), choose **Private** (you can open it later), click **Create repository**.
3. Get it onto your computer. On your new repo's page, click the green **Code** button and copy the URL, then in the terminal:

```bash
git clone <paste-the-url-here>
cd <your-repo-name>
```

4. Open it in VS Code: **File → Open Folder** → pick your repo folder. (Or type `code .` in the terminal.)

---

## Part 3 — Run the setup (~15 min)

### 3.1 The init script

In VS Code, open the built-in terminal (**Terminal → New Terminal**) and run:

```bash
./scripts/init.sh
```

It asks one question — your project's main language:

- Building something in **Python** (data work, scripts, AI tools)? → type `1`
- Building a **website or app in TypeScript/JavaScript**? → type `2`
- **Don't know?** → type `3`. The AI will pick the right toolchain with you later. This is a completely fine answer.

### 3.2 Install the three skill systems

Start Claude Code in the same terminal:

```bash
claude
```

Now install the three systems the harness is built on. Type each line as its own message:

```
/plugin install superpowers@claude-plugins-official
```
```
/plugin marketplace add DietrichGebert/ponytail
```
```
/plugin install ponytail@ponytail
```

Then exit Claude Code (`/exit`) and run this in the plain terminal:

```bash
npx skills@latest add mattpocock/skills
```

Use arrow keys + spacebar to select skills. **Select all of them, and make absolutely sure `/setup-matt-pocock-skills` is selected.** Choose "Claude Code" when asked which agent to install to.

> **What did I just install?** Three open-source skill packs: one that makes the AI interview you before building ([Matt Pocock's skills](https://github.com/mattpocock/skills)), one that helps it execute big features safely ([Superpowers](https://github.com/obra/superpowers)), and one that stops it from over-engineering ([Ponytail](https://github.com/DietrichGebert/ponytail)). You never manage these directly — the harness knows when to use each.

### 3.3 Configure

Start `claude` again and run:

```
/setup-matt-pocock-skills
```

It asks where to track your to-do items. **Beginners: choose "local files"** (everything stays in your project folder — simplest). Developers may prefer GitHub Issues. For "where to save docs," accept the default or say `docs/`.

### 3.4 Tell the AI about YOUR project

Open `CLAUDE.md` in VS Code. You'll see `{{PLACEHOLDERS}}` — fill them in plain English. Don't overthink; one honest paragraph beats a fancy spec:

> *"RecipeBox is a website where my family stores and searches our recipes. Users: my family, ~10 people. Must work on phones."*

Delete any placeholder rules you don't need. Do the same quick pass on `docs/DECISIONS.md` and put your first goal in `docs/ROADMAP.md` (one line is enough: "v1: family members can add and search recipes").

**Shortcut if the placeholders intimidate you:** start `claude` and say *"Read CLAUDE.md and interview me briefly to fill in every placeholder, then show me the result before saving."*

### 3.5 Save your setup

```bash
git add -A
git commit -m "chore: harness setup"
git push
```

*(Optional but recommended, ~20 min: follow `docs/REPO-SECURITY.md` to lock the repo down. If you're just experimenting, do it later.)*

---

## Part 4 — The first session (~30 min)

Open the file `KICKOFF-PROMPT.md`, copy everything between the two horizontal lines, start `claude`, and paste it.

The AI now works through **four stages, stopping for your approval after each**:

| Stage | What happens | What you do |
|---|---|---|
| 1. Orient | AI reads all the project files and reports back what it understood | Read its summary. Wrong anywhere? Say so — it fixes the files |
| 2. Verify | AI checks all tools and plugins are working (a PASS/FAIL table) | If anything FAILs, it proposes the fix command — approve it |
| 3. Baseline | AI sets up the project skeleton with one tiny test, end to end | Watch. This is the whole workflow in miniature |
| 4. First grill | AI interviews you about your first real feature — relentlessly | Answer honestly. "I don't know" is a valid answer; it will propose options |

Stage 4 is where the magic is. By the end, your idea has become a written spec and a list of small, buildable tasks — and the AI wrote down your project's vocabulary in `CONTEXT.md` so it speaks your language from now on.

Then it wraps up with `/session-end`. **You're initialized.**

---

## Part 5 — The everyday rhythm

Every work session, forever, is the same three beats:

```
/session-start        ← AI briefs you: where you left off, what's next, what's blocked
   ...work...         ← build ONE task from your list (see below)
/session-end          ← AI saves all progress to files, so next session resumes perfectly
```

And building a feature is always the same loop:

1. **`/grill-with-docs`** — the interview. Do this for *every* change, even small ones. Misunderstanding is the #1 way software fails; ten minutes of questions beats a day of wrong code.
2. **`/to-prd`** then **`/to-issues`** — the conversation becomes a spec, then a list of small tasks.
3. **Build one task at a time.** Say: *"Let's build issue #1 with /tdd."* The AI writes a failing test first, then makes it pass — proof it works.
4. **Review.** Say: *"Run /code-review, then the verifier, then /ponytail-review."* Three different critics check the work: does it match the spec, is it safe, is it over-built.
5. **Merge and repeat.** The AI opens a pull request; you press merge on GitHub.

When in doubt about which command fits your situation, just ask: **`/ask-matt`** routes you.

### The five golden rules

1. **Never skip the grill.** Even for "small" changes.
2. **Never skip `/session-end`.** It's how the project remembers.
3. **One task per session** when starting out. Type `/clear` between tasks.
4. **Never merge what you can't explain.** Ask: *"Explain this change like I'm reviewing it."* If the answer surprises you, don't merge.
5. **When the AI goes in circles:** `/clear`, then `/session-start`, then try again smaller.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found: claude` | Node.js isn't installed or the terminal needs restarting. Re-run the Part 1 checks. |
| `./scripts/init.sh: Permission denied` | Run `chmod +x scripts/init.sh` first, then retry. |
| `/plugin install` says already installed | You're fine — that's a pass, not an error. |
| Skills don't appear (e.g., `/grill-me` unknown) | Restart Claude Code (`/exit`, then `claude`). Plugins load at startup. |
| AI ignores the process and codes immediately | Say: *"Stop. Follow docs/HARNESS.md — grill me first."* |
| PR won't merge, "waiting for status check" | Your CI job must be named `ci` (see `docs/REPO-SECURITY.md`, the gotcha note). |
| Everything is confusing | In Claude Code: *"Read GUIDE.md and PLAYBOOK.md and tell me what I should do next, step by step."* The harness can explain itself. |

## Mini-glossary

**Repo** — your project folder, tracked by GitHub. · **Terminal** — the text window where you type commands. · **Grilling** — the AI interviewing you until requirements are unambiguous. · **PRD** — the written spec produced from the grill. · **Issue** — one small buildable task. · **TDD** — write a failing test first, then code until it passes. · **PR (pull request)** — a proposed change you approve before it becomes permanent. · **CI** — automatic checks that run on every PR. · **Merge** — accepting a PR into the real project.

---

*Built on [Superpowers](https://github.com/obra/superpowers), [Ponytail](https://github.com/DietrichGebert/ponytail), and [Matt Pocock's skills](https://github.com/mattpocock/skills) — all MIT-licensed. Deeper reading once you're comfortable: `PLAYBOOK.md` (the full workflow) and `docs/HARNESS.md` (how the three systems divide the work).*

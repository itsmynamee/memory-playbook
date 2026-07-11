# Memory Playbook

A Claude Code skill that stops `MEMORY.md` from turning into soup, stops you from
correcting the same mistake twice, and keeps watch over its own rules so nothing quietly
contradicts itself.

**Is this for you?** If you run long, multi-session Claude Code projects and you're tired of
watching memory bloat until it gets compacted and loses the nuance — or tired of saying "fix
it everywhere, not just here" every single time — yes. If you want a fully automatic,
zero-setup background memory, you probably want [claude-mem](https://github.com/thedotmack/claude-mem)
instead; this is the opposite bet — manual, transparent, plain markdown, nothing hidden.

## The problem

1. **The compaction death spiral.** A single `MEMORY.md` holding running status grows until
   it hits the read limit, gets compacted, loses detail, grows again.
2. **Repeating the same correction.** You catch a bug on one page, ask for a fix, and the
   same bug is still sitting on three other pages next week — because the lesson died with
   the conversation instead of becoming a standing check.

## Before / after

```
before:
memory/
└── MEMORY.md              # 47 KB, everything mixed together, gets compacted, loses detail

after:
memory/
├── MEMORY.md               # index only — rules + domain map, stays a few KB forever
├── project-map.md          # stable facts: what the project IS
├── playbook.md             # self-learning: corrections → lessons → pre-ship checks
├── domain-payments.md      # live status for one work area
├── domain-admin-ui.md
└── 2026-03-05-webhook-retry-fix.md   # full episode detail, unlimited size, never deleted
```

## What you get

- **Two-tier index** — `MEMORY.md` never holds status, so it never bloats. A session working
  on payments loads only the payments domain.
- **Self-learning playbook** — every owner correction becomes a recorded lesson in the same
  turn, replayed via a mandatory pre-ship self-review before every "done".
- **Bug discipline that composes with `systematic-debugging`** — root-cause first, fix, sweep
  the whole codebase for the same class, fix every instance, record it. Never "fixed the
  button on one page, left the other three broken."
- **Memory that audits itself** — every time a rule is saved it's checked against the rules it
  could contradict, and the owner is told in plain language the moment two of them disagree —
  with a recommended fix, their call. An on-demand Audit sweeps the whole store at once for
  contradictions, stale rules (the reason behind them is gone), and duplicates. No competing
  memory tool reasons about whether your rules still *agree* with each other.
- **`check_memory.sh`** — one command that catches orphaned files, naming collisions, and
  size overruns before they become a mess (structure); Audit is its meaning-level sibling.
- **Deterministic, not best-effort** — plants a one-line pointer in your project's `CLAUDE.md`
  during setup, so future sessions check for the domain map instead of relying on the skill
  happening to match.
- **Migration mode** — already have a bloated `MEMORY.md`? It reorganizes into domains without
  dropping anything, orphans included.

## Install

Global (available in every project):

```bash
git clone https://github.com/itsmynamee/memory-playbook.git ~/.claude/skills/memory-playbook
```

Project-only:

```bash
git clone https://github.com/itsmynamee/memory-playbook.git .claude/skills/memory-playbook
```

Then just keep working. On a fresh project it bootstraps memory from what it can read off
your repo; on a project with an already-bloated `MEMORY.md` it migrates instead of starting
over. Ask for it explicitly any time: *"set up memory for this project."*

## Why not just use Auto Memory / Auto Dream / claude-mem?

- **Claude Code's native Auto Memory / Auto Dream** are heading the same direction (index +
  topic files, automatic consolidation) — great once fully rolled out. This works today, and
  every file stays plain, readable, git-diffable markdown you can inspect and edit yourself,
  not a black box.
- **[claude-mem](https://github.com/thedotmack/claude-mem)** is bigger and fully automatic —
  SQLite + vector search, zero-touch capture. If you want hands-off, use it. This is for when
  you'd rather see and control exactly what gets remembered.
- **Cline-style memory banks** popularized "markdown files as an external brain" for other
  tools. This is the Claude Code-native version, with an actual self-learning loop and an
  integrity check on top, not just a file convention.

## What this is NOT

- Not a vector database or semantic search — matching is exact links (`[[name]]` / `name.md`),
  checked by a plain bash script.
- Not fully automatic — Claude follows this protocol explicitly; nothing runs in the
  background.
- Not a replacement for git history — episode files record decisions and reasoning, not diffs.

## License

MIT — see [LICENSE](LICENSE).

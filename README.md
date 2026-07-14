# Memory Playbook

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Agent: Claude Code](https://img.shields.io/badge/agent-Claude_Code-D97757.svg?logo=anthropic&logoColor=white)](https://github.com/anthropics/claude-code)

**Transparent, self-auditing project memory for Claude Code that stays small and preserves durable lessons.**

Memory Playbook keeps project knowledge in plain Markdown. A compact index
routes Claude to one relevant domain at a time; detailed incidents and decisions
live in linked episode files instead of bloating `MEMORY.md`.

Looking for the Codex edition? Use [Memory Playbook CX](https://github.com/itsmynamee/memory-playbook-cx).

## Why Memory Playbook

- **Small context footprint:** `MEMORY.md` contains rules and a domain map, never
  live status.
- **Durable decisions:** incidents, migrations, and interrupted work live in
  linked episode files.
- **Self-learning playbook:** owner corrections become reusable lessons and
  pre-ship checks instead of disappearing with the conversation.
- **Root-cause discipline:** recurring bug classes are fixed across the relevant
  codebase and recorded once for future work.
- **Self-checking rules:** Audit identifies contradictions, stale guidance, and
  duplicate sources of truth.
- **Deterministic discovery:** setup plants a small pointer in the project's
  `CLAUDE.md` so future sessions find the domain map.
- **Migration support:** existing flat or bloated memory is reorganized without
  dropping protected rules or orphaned files.
- **Plain files:** everything remains readable, diffable, portable, and
  reviewable in Git.

## How it works

```text
memory/
├── MEMORY.md          # rules + domain map only
├── project-map.md     # stable project facts
├── playbook.md        # corrections → lessons → pre-ship checks
├── domain-payments.md # current status + episode pointers
├── domain-ui.md
└── 2026-03-05-webhook-retry-fix.md
```

Claude opens only the domain relevant to the task, then follows episode links
when full detail is needed. `check_memory.sh` verifies the file graph and naming
rules; Audit handles meaning-level conflicts that require judgment.

## Install

Global, available in every project:

```bash
git clone https://github.com/itsmynamee/memory-playbook.git ~/.claude/skills/memory-playbook
```

Project-only:

```bash
git clone https://github.com/itsmynamee/memory-playbook.git .claude/skills/memory-playbook
```

Then ask Claude to set up memory for the project. On a fresh project the skill
bootstraps the smallest useful store; when memory already exists, it migrates the
current content instead of starting over.

Updates are manual because the installation is a plain Git clone:

```bash
git -C ~/.claude/skills/memory-playbook pull
```

## Modes

| Mode | Use it when | Result |
| --- | --- | --- |
| Bootstrap | The project has no durable memory | Creates the smallest useful store and a `CLAUDE.md` pointer |
| Migration | Existing memory is flat or bloated | Reorganizes it without dropping protected rules or orphaned files |
| Learning | The owner corrects a recurring mistake | Records a reusable lesson and pre-ship check |
| Audit | Rules may conflict, duplicate, or be stale | Reports semantic problems and recommends a resolution |
| Integrity check | The memory graph may be broken | Finds orphaned files, naming collisions, and size overruns |

## Example prompts

```text
Set up memory for this project.
Migrate this bloated MEMORY.md without losing anything.
Audit our saved rules for contradictions and stale guidance.
Save this correction as a reusable lesson for future work.
```

## Safety boundaries

- Memory stays in transparent project Markdown, not a database or hidden
  background service.
- Setup changes the project pointer deliberately; it does not depend on the
  skill matching by chance in every future session.
- Audit reports contradictions and lets the owner decide how to resolve them.
- Episode files preserve decisions and reasoning, not Git diffs or raw chat
  transcripts.
- The workflow is explicit, not a zero-touch capture system.

## Integrity check

```bash
bash scripts/check_memory.sh <memory-dir>
```

The checker rejects orphaned Markdown files and fake `domain-*` indexes, and
warns when index files exceed their intended size. Audit remains responsible
for semantic conflicts because those require judgment.

## Alternatives

- **Claude Code Auto Memory / Auto Dream** follows a similar index-and-topic
  direction with automatic consolidation. Memory Playbook is the transparent,
  project-controlled option.
- **[claude-mem](https://github.com/thedotmack/claude-mem)** provides automatic
  SQLite and vector-search capture. Choose it when hands-off collection matters
  more than explicit Markdown control.
- **Cline-style memory banks** established Markdown files as an external brain;
  Memory Playbook adds a self-learning loop, semantic Audit, and structural
  integrity checking.

## Scope

Memory Playbook is not a vector database, semantic-search system, background
daemon, or replacement for Git history. It is a Claude Code workflow for small,
inspectable project memory with durable decisions and explicit owner control.

## License

[MIT](LICENSE) © 2026 itsmynamee

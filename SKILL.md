---
name: domain-memory
description: Two-tier self-learning persistent memory for Claude Code projects. Use this whenever the user wants to set up, reorganize, audit, or improve Claude's file-based memory; whenever MEMORY.md is bloated, near its size limit, or keeps getting compacted; whenever the user asks Claude to "remember things properly", "learn from mistakes", "stop repeating the same corrections", or wants project knowledge to survive across sessions. Also use it when SAVING memories in a project that already follows this system (look for a domain map in MEMORY.md).
---

# Domain Memory

A protocol for Claude Code's file-based memory that solves two chronic problems:

1. **The compaction death spiral.** A single MEMORY.md that holds running status grows until it hits the read limit, gets compacted, loses nuance, grows again. Fix: the index NEVER holds status — it only holds rules and a map. Growth happens in per-domain files, each loaded only when relevant.
2. **Repeating the same corrections.** The owner corrects the same class of mistake across sessions because lessons die with the conversation. Fix: an explicit capture → store → replay loop (the playbook), so corrections become pre-ship checks instead of recurring complaints.

The memory directory is wherever this project's harness keeps it (typically `~/.claude/projects/<project-slug>/memory/`). Write memory files in the language the owner uses with you.

## The architecture (three layers + two special files)

```
memory/
├── MEMORY.md            # INDEX ONLY: usage rules + domain map + cross-domain one-liners.
│                        # Auto-loaded every session. Never holds status → never bloats.
├── project-map.md       # STABLE invariants: what the system IS (business, repos,
│                        # architecture rules, verification protocol). No status here.
├── playbook.md          # SELF-LEARNING: owner's philosophy, red flags that trigger
│                        # corrections, mandatory pre-ship self-review, lessons journal.
├── domain-<area>.md     # One per work area. Holds the LIVE "Current status (date)" +
│                        # one-line pointers to episodes + area-specific gotchas.
└── <episode files>.md   # Full detail of one piece of work/incident/decision.
                         # Indexed from their domain file, NOT from MEMORY.md.
```

Why this shape works: MEMORY.md stays a few KB forever; a session working on payments loads only the payments domain (one hop); episodes keep unlimited detail without ever entering always-loaded context.

**Deliberate deviation:** the default harness instruction says "add a pointer in MEMORY.md for every memory file". In this system, episode pointers go in the episode's DOMAIN file instead. Record this deviation inside MEMORY.md itself (the templates do) so a future session doesn't "fix" it back.

## When invoked, first determine the mode

- **Bootstrap** — no memory dir, or MEMORY.md under ~2KB / only boilerplate → scaffold fresh.
- **Migration** — MEMORY.md holds real accumulated entries in a flat list → reorganize into domains.
- **Maintenance** — the system already exists (MEMORY.md contains a domain map) → follow its rules for the save/update at hand.

## Bootstrap (fresh project)

1. Read `references/templates.md` and copy the MEMORY.md skeleton into the memory dir.
2. Write `project-map.md`: derive stable facts from the repo (what the product is, repos/services, architecture invariants that must not be violated, how work is verified before "done", key code entry points). Interview the owner only for what the code can't tell you (business context, external services); when interviewing isn't possible, write the best guess and mark it `(ASSUMED)` — a future session must be able to tell confirmed facts from guesses, and should upgrade ASSUMED entries as the owner confirms them. Status never goes here. Two edge cases: a convention not yet applied everywhere → the rule itself lives here, the unfinished tail is status in the owning domain; a stable fact mid-transition (something being decommissioned/replaced) → record the current truth here with an inline note to update/remove the line when the transition ends.
3. Write `playbook.md` from the template. Seed the philosophy/red-flags sections with anything already known about the owner's preferences; leave the lessons journal empty — it fills itself via the self-learning protocol.
4. Create 2-5 initial `domain-<area>.md` files matching the project's natural work areas (e.g. payments, admin-ui, public-site, infra). Don't over-split: a domain earns existence when it has status worth tracking; new domains can be added any time by adding one line to the map.
5. Run `<skill-dir>/scripts/check_memory.sh <memory-dir>` to verify integrity.

## Migration (existing bloated memory)

1. Read the whole existing MEMORY.md and list every memory file on disk — files missing from the index (orphans) are common and must be adopted, not dropped.
2. Cluster entries into 5-10 domains by work area. An entry that fits two domains gets a pointer in both, marked "cross-linked".
3. For each domain: create `domain-<area>.md` with a dated "Current status" section (the in-flight facts), a shipped/history list, and a "Gotchas" section (area-specific traps). Legacy files being adopted that lack frontmatter get it added (see `references/templates.md` for the required fields).
4. Rebuild MEMORY.md from the template: rules + domain map + only truly cross-domain one-liners (global gotchas, "what the owner owes" block). Everything else moves into domains. Preserve any protected/LOCKED rules verbatim — never soften them during migration.
5. Bootstrap `project-map.md` and `playbook.md` if absent (steps 2-3 above).
6. Run `<skill-dir>/scripts/check_memory.sh <memory-dir>` — zero orphans required. Watch for name collisions: only real domain indexes may match `domain-*.md` (a legacy file that accidentally matches gets renamed).

## Maintenance protocol (the rules that live in MEMORY.md)

These are the day-to-day rules. The MEMORY.md template embeds them so every future session sees them without this skill loaded; when this skill IS loaded, enforce them.

1. **Fresh session: read `project-map.md` + `playbook.md` first.** Then, before working on area X, read `domain-X.md`. Don't work on an area "from memory of the model" without this hop.
2. **Saving new memory:** write an episode file → add a one-line pointer in ITS domain file → refresh that domain's "Current status (date)".
3. **Finishing work on an area** (even with no new episode — something got deployed, tested, closed): update the domain's status + date before ending the turn.
4. **Interrupted work = a resume checklist inside the episode** + an IN PROGRESS marker in the domain status. A successor session should be able to continue from the checklist without re-deriving anything.
5. **Self-learning:** every owner correction AND every self-caught mistake (design, process, approach, code) becomes a recorded lesson in the SAME turn: philosophy/process → `playbook.md`; area-specific code trap → that domain's Gotchas; a bug that implies a class → sweep the whole codebase for the class before closing, then record the class. Before claiming anything is done, run the playbook's pre-ship self-review.
6. **MEMORY.md changes only when:** a domain is added to the map, a global rule/gotcha changes, or the owner-owes block changes. A domain growing past ~10KB → move its shipped-history into `domain-<area>-archive.md` AND link the archive from the domain file (an unlinked archive is an orphan); status + gotchas stay in the domain. Archives are exempt from the size ceiling — they exist to absorb overflow.
7. **Episodes are never deleted to save space** — only the index layers are size-managed.
8. Protected/LOCKED rules are untouchable without an explicit owner decision, including during any consolidation pass.

## The self-learning loop (what makes it more than a filing system)

- **Capture:** the trigger is any correction or self-caught miss — not just bugs. "You used the wrong tone", "this screen is inconsistent with that one", "you gave me a menu instead of a decision" are all lessons.
- **Store with taxonomy:** philosophy and collaboration style → playbook sections; recurring visual/UX classes → the design domain's checklist; code traps → domain gotchas; bug classes → a class file + immediate system-wide sweep.
- **Replay:** the playbook contains a mandatory pre-ship self-review (verification commands, "class not instance" sweep, uniformity check, honest failure-states check, memory updated). Run it before every "done" — the point is that the owner never has to ask "did you check everywhere?" again.
- **Distill:** the lessons journal is append-only in the moment; when a pattern repeats, promote it into the structured sections (or into a red-flag list) and keep the journal entry as provenance.

## Integrity checks

Run `<skill-dir>/scripts/check_memory.sh <memory-dir>` after any reorganization and periodically during maintenance. It verifies:
- **No orphans (hard fail):** every file is linked (`[[name]]` or `name.md`) from an entry file — MEMORY.md, a domain file, project-map, or playbook (the latter two count because they are always-read entry files). A file mentioning its own name does not count. Archives count as entry files deliberately: episodes moved into an archive keep their links there.
- **Domain marker (hard fail):** every `domain-*.md` (except `*-archive.md`) carries the verbatim English token `Domain index` at the start of its frontmatter `description:`. This is a machine-checked marker — keep it in English even when all memory content is in another language.
- **Size ceilings (warnings only):** MEMORY.md ~17KB, domains ~10KB (archives exempt).

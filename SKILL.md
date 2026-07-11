---
name: memory-playbook
description: Two-tier self-learning persistent memory for Claude Code projects. Use this whenever the user wants to set up, reorganize, audit, or improve Claude's file-based memory; whenever MEMORY.md is bloated, near its size limit, or keeps getting compacted; whenever the user asks Claude to "remember things properly", "learn from mistakes", "stop repeating the same corrections", or wants project knowledge to survive across sessions; whenever the user wants Claude to check whether its own saved rules contradict each other, have gone stale, or duplicate one another. Also use it when SAVING memories in a project that already follows this system (look for a domain map in MEMORY.md).
---

# Memory Playbook

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
- **Audit** — the owner asks to check/verify the memory itself ("does my memory still hold up", "check my rules"), or a periodic pass → read every rule-bearing entry at once and report contradictions, stale rules, and duplicates. Edits nothing except what the owner approves.

## Bootstrap (fresh project)

1. Read `references/templates.md` and copy the MEMORY.md skeleton into the memory dir.
2. Write `project-map.md`: derive stable facts from the repo (what the product is, repos/services, architecture invariants that must not be violated, how work is verified before "done", key code entry points). Interview the owner only for what the code can't tell you (business context, external services); when interviewing isn't possible, write the best guess and mark it `(ASSUMED)` — a future session must be able to tell confirmed facts from guesses, and should upgrade ASSUMED entries as the owner confirms them. Status never goes here. Two edge cases: a convention not yet applied everywhere → the rule itself lives here, the unfinished tail is status in the owning domain; a stable fact mid-transition (something being decommissioned/replaced) → record the current truth here with an inline note to update/remove the line when the transition ends.
3. Write `playbook.md` from the template. Seed the philosophy/red-flags sections with anything already known about the owner's preferences; leave the lessons journal empty — it fills itself via the self-learning protocol.
4. Create 2-5 initial `domain-<area>.md` files matching the project's natural work areas (e.g. payments, admin-ui, public-site, infra). Don't over-split: a domain earns existence when it has status worth tracking; new domains can be added any time by adding one line to the map.
5. Ensure the project's `CLAUDE.md` (create a minimal one if none exists) contains the memory pointer from `references/templates.md` — skip if an equivalent line is already present. This makes the next session check MEMORY.md for a domain map before saving instead of relying on semantic skill-matching alone.
6. Run `<skill-dir>/scripts/check_memory.sh <memory-dir>` to verify integrity.

## Migration (existing bloated memory)

1. Read the whole existing MEMORY.md and list every memory file on disk — files missing from the index (orphans) are common and must be adopted, not dropped.
2. Cluster entries into 5-10 domains by work area. An entry that fits two domains gets a pointer in both, marked "cross-linked". While clustering, watch for entries that contradict each other (common in memory that grew unmanaged) — flag those to the owner using the same format as the ongoing Contradiction check (Maintenance rule 9) before finalizing domains.
3. For each domain: create `domain-<area>.md` with a dated "Current status" section (the in-flight facts), a shipped/history list, and a "Gotchas" section (area-specific traps). Legacy files being adopted that lack frontmatter get it added (see `references/templates.md` for the required fields).
4. Rebuild MEMORY.md from the template: rules + domain map + only truly cross-domain one-liners (global gotchas, "what the owner owes" block). Everything else moves into domains. Preserve any protected/LOCKED rules verbatim — never soften them during migration.
5. Bootstrap `project-map.md` and `playbook.md` if absent (steps 2-3 above).
6. Ensure the project's `CLAUDE.md` (create a minimal one if none exists) contains the memory pointer from `references/templates.md` — skip if already present. Migrated projects need this even more: earlier sessions here were relying on semantic skill-matching alone.
7. Run `<skill-dir>/scripts/check_memory.sh <memory-dir>` — zero orphans required. Watch for name collisions: only real domain indexes may match `domain-*.md` (a legacy file that accidentally matches gets renamed).

## Maintenance protocol (the rules that live in MEMORY.md)

These are the day-to-day rules. The MEMORY.md template embeds them so every future session sees them without this skill loaded; when this skill IS loaded, enforce them.

1. **Fresh session: read `project-map.md` + `playbook.md` first.** Then, before working on area X, read `domain-X.md`. Don't work on an area "from memory of the model" without this hop.
2. **Saving new memory:** write an episode file → add a one-line pointer in ITS domain file → refresh that domain's "Current status (date)".
3. **Finishing work on an area** (even with no new episode — something got deployed, tested, closed): update the domain's status + date before ending the turn.
4. **Interrupted work = a resume checklist inside the episode** + an IN PROGRESS marker in the domain status. A successor session should be able to continue from the checklist without re-deriving anything.
5. **Self-learning:** every owner correction AND every self-caught mistake (design, process, approach, code) becomes a recorded lesson in the SAME turn: philosophy/process → `playbook.md`; area-specific code trap → that domain's Gotchas. For a bug: root-cause it first (the `systematic-debugging` skill owns that investigation — this loop starts once the cause is certain), fix it, then sweep the whole codebase for the same class before closing, and record the class. Before claiming anything is done, run the playbook's pre-ship self-review.
6. **MEMORY.md changes only when:** a domain is added to the map, a global rule/gotcha changes, or the owner-owes block changes. A domain growing past ~10KB → move its shipped-history into `domain-<area>-archive.md` AND link the archive from the domain file (an unlinked archive is an orphan); status + gotchas stay in the domain. Archives are exempt from the size ceiling — they exist to absorb overflow.
7. **Episodes are never deleted to save space** — only the index layers are size-managed.
8. Protected/LOCKED rules are untouchable without an explicit owner decision, including during any consolidation pass.
9. **Contradiction check:** whenever a save adds or edits a rule-bearing entry (a domain Gotcha, a playbook red flag/philosophy line, a project-map invariant, or a LOCKED rule), re-read the other rule-bearing entries it could collide with — project-map, playbook, the touched domain, any cross-linked domain, MEMORY.md's global gotchas/LOCKED block — before ending the turn. Two entries saying incompatible things? Don't silently pick one: tell the owner immediately, compactly, in plain language — what the two rules are, why they conflict, your recommended resolution. The owner decides; only edit memory once they do. Two refinements keep this from being noise: (a) also ask *"is the entry I'm touching still true?"* — a rule whose reason has since disappeared is stale even if nothing contradicts it, flag it the same way; (b) when the clash is between an `(ASSUMED)` fact and an owner-confirmed one, ASSUMED loses automatically — just fix it and note it, don't make the owner adjudicate. Only equal-standing clashes (two confirmed, or two assumed) need their call. When the owner's resolution is an intentional override — the new rule is *meant* to replace the old — record it, don't just edit silently: remove the old rule, or if it must stay (it's LOCKED, lives in another domain, or an episode references it) mark it `(SUPERSEDED by [[<new>]] — <date>: <why>)` so no future check ever re-flags the pair. Superseding a LOCKED rule is itself an owner decision (rule 8 still applies) — the marker only records a transition they approved. If the owner defers the decision, park the conflict in MEMORY.md's owner-owes block prefixed `CONFLICT:` (or `STALE?:` for a suspected-stale entry) so it survives the session instead of dying with the conversation.

## The self-learning loop (what makes it more than a filing system)

- **Capture:** the trigger is any correction or self-caught miss — not just bugs. "You used the wrong tone", "this screen is inconsistent with that one", "you gave me a menu instead of a decision" are all lessons.
- **Store with taxonomy:** philosophy and collaboration style → playbook sections; recurring visual/UX classes → the design domain's checklist; code traps → domain gotchas; bug classes → a class file + immediate system-wide sweep.
- **Replay:** the playbook contains a mandatory pre-ship self-review (verification commands, "class not instance" sweep, uniformity check, honest failure-states check, memory updated, contradiction check). Run it before every "done" — the point is that the owner never has to ask "did you check everywhere?" again.
- **Distill:** the lessons journal is append-only in the moment; when a pattern repeats, promote it into the structured sections (or into a red-flag list) and keep the journal entry as provenance.

## Audit mode (semantic integrity — the sibling of the structural check)

`check_memory.sh` checks STRUCTURE (orphans, sizes, markers); it cannot tell whether two rules make sense together. Audit is the meaning-level pass. The per-save Contradiction check (Maintenance rule 9) only ever sees the ONE entry being written — so conflicts that predate the rule, or that accumulated during unmanaged growth, are invisible to it forever. Audit closes that gap: read every rule-bearing entry at once — project-map invariants, playbook philosophy + red flags, every domain's Gotchas, MEMORY.md's global gotchas + LOCKED block — and report, compactly and in plain language:

1. **Contradictions** — two entries asserting incompatible things (rule 9, run across the whole store instead of one save).
2. **Stale rules** — an entry that still reads as true but the reason behind it is gone (a Gotcha about a since-fixed bug, an invariant naming a decommissioned service). Flag "looks stale — still true?", never delete on your own.
3. **Duplicates** — two entries saying the same thing in different words or domains: harmless today, a future contradiction the day one changes and the other doesn't. Propose merging to a single source with a cross-link.

Output is a short numbered list — each item names the entries involved, why it's a problem, and the recommended fix. The owner decides each; Audit edits memory only for what they approve. Resolve `(ASSUMED)`-vs-confirmed automatically (ASSUMED loses) and just note it — only equal-standing conflicts reach the owner. **Skip any pair where one side carries a `(SUPERSEDED by …)` marker** — that clash was already decided on purpose, and re-flagging a settled decision every run is the fastest way to train the owner to ignore Audit entirely (the whole feature dies to alarm fatigue). Deferred items parked in the owner-owes block (`CONFLICT:` / `STALE?:`) get re-surfaced here, never silently dropped. These checks are deliberately NOT in `check_memory.sh`: they need judgement, not grep. Run Audit when the owner asks, at the end of a Migration, or periodically on a long-lived store.

## Integrity checks (structural)

Run `<skill-dir>/scripts/check_memory.sh <memory-dir>` after any reorganization and periodically during maintenance. It verifies:
- **No orphans (hard fail):** every file is linked (`[[name]]` or `name.md`) from an entry file — MEMORY.md, a domain file, project-map, or playbook (the latter two count because they are always-read entry files). A file mentioning its own name does not count. Archives count as entry files deliberately: episodes moved into an archive keep their links there.
- **Domain marker (hard fail):** every `domain-*.md` (except `*-archive.md`) carries the verbatim English token `Domain index` at the start of its frontmatter `description:`. This is a machine-checked marker — keep it in English even when all memory content is in another language.
- **Size ceilings (warnings only):** MEMORY.md ~17KB, domains ~10KB (archives exempt).

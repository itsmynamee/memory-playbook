# Templates

Copy these skeletons when bootstrapping or migrating. Replace `<...>` placeholders. Write the actual content in the language the owner uses with you — EXCEPT the `Domain index` token at the start of every domain file's `description:`, which is machine-checked by `check_memory.sh` and must stay verbatim English.

Frontmatter: every memory file carries `name`, `description`, `metadata.type` — EXCEPT MEMORY.md itself, which is the harness index and carries no frontmatter. `metadata.type` vocabulary (harness convention): `user` (who the owner is), `feedback` (how to work with them — the playbook), `project` (work/state/architecture — domains, episodes, project-map), `reference` (pointers to external resources).

## MEMORY.md skeleton

```markdown
# Memory index

## How this memory works (memory-playbook system)

Two-tier: **MEMORY.md = rules + domain map only** (never holds working status, so it never
hits the size limit). **Domain files (`domain-*.md`) = live status of their area** + one-line
pointers to episode files. Usage rules:

1. **Fresh session: read [project-map](project-map.md) (what this system is) +
   [playbook](playbook.md) (how we work, what triggers corrections) first.** Then, before
   working on area X, read `domain-X.md`. Don't work on an area "from model memory" without
   this step.
2. **Saving new memory:** write an episode file → add a one-line pointer in ITS domain file
   (NOT in MEMORY.md!) → refresh that domain's "Current status". This is a deliberate,
   owner-approved deviation from the default "pointer in MEMORY.md" instruction — do NOT
   "fix" it back.
3. **Finishing work on an area** (even without a new episode — deployed, tested, closed):
   update its domain's Current status + date before ending the turn.
4. **Interrupted work = a mandatory resume checklist in the episode** + IN PROGRESS marker
   in the domain.
5. **Self-learning:** every owner correction OR self-caught mistake = a lesson recorded in
   the SAME turn: philosophy/process → playbook; area-specific code trap → domain Gotchas;
   bug class → root-cause first (see `systematic-debugging`), then system-wide sweep + class
   file. Before every "done" — run the playbook's pre-ship self-review.
6. **MEMORY.md changes only when:** a new domain appears, a global rule changes, or the
   owner-owes block changes. Domain past ~10KB → move shipped-history to
   `domain-<area>-archive.md` AND link the archive from the domain file.
7. Episode spanning two domains → pointer in both, marked cross-linked. A file with no
   pointer in any domain = an orphan — don't create them. Episodes are never deleted to
   save space.
8. LOCKED rules below are untouchable without explicit owner permission (including during
   memory consolidation).
9. **Contradiction check:** after any save touching a Gotcha, playbook red flag, project-map
   invariant, or LOCKED rule — compare it against the other rule-bearing entries it could
   collide with. Conflict found (or the entry has gone stale — its reason is gone)? Tell the
   owner right away: compact, plain language, what's wrong and why, plus your recommended fix.
   Owner decides; never silently overwrite. `(ASSUMED)` loses to a confirmed fact automatically.
   When a new rule is *meant* to replace an old one, mark the old `(SUPERSEDED by [[<new>]] —
   <date>: <why>)` so it's never re-flagged; if the owner defers, park it in the owner-owes
   block prefixed `CONFLICT:` (or `STALE?:`) so it survives the session.
   For a full-store sweep of all rules at once, ask the memory-playbook skill for an Audit.

## 🔒 LOCKED — never edit, weaken, or delete without asking the owner first

<move protected process rules here as they accumulate — verbatim. Each entry carries WHEN it
was locked, WHO set it, and WHY (the reason), so a later Audit can tell a genuine conflict from
a legitimate evolution instead of guessing. Format: `- <rule> (locked <date> by <who>: <why>)`.>

## Domain map (look here, dive into the file — status lives THERE)

- [project-map](project-map.md) — **START HERE**: business, repos, architecture invariants,
  verification protocol, key code entry points.
- [playbook](playbook.md) — **self-learning**: owner philosophy, red flags, mandatory
  pre-ship self-review.
- [domain-<area>](domain-<area>.md) — <one-line scope of the area>.

## Global gotchas (not tied to one domain)

- <only truly cross-domain one-liners>

## What the OWNER currently owes (single place; details in domains)

- <external-dashboard actions, pending decisions — with domain references>
- `CONFLICT:` / `STALE?:` <a memory conflict or suspected-stale rule the owner deferred —
  the two entries, the recommended fix, awaiting their call. Re-surfaced by the next Audit.>
```

## domain-<area>.md skeleton

```markdown
---
name: domain-<area>
description: Domain index - <scope>. Dive in here for any <area> work.
metadata:
  type: project
---

**Current status (<YYYY-MM-DD>):**
- [[<episode-name>]] — <IN PROGRESS / SHIPPED / CLOSED>: <one line, incl. what's unpushed/
  unapplied and what the next step is>.
- <At bootstrap, before any episode exists, use exactly one line:>
  Nothing in flight (bootstrapped <YYYY-MM-DD>).

**Shipped / history:**
- [[<episode-name>]] — <one-line hook>.

**Gotchas:**
- [[<gotcha-or-inline>]] — <the trap and the rule>.
```

## project-map.md skeleton

```markdown
---
name: project-map
description: "START HERE in a fresh session - what <project> IS: business, repos, architecture invariants, verification protocol. Stable facts only, no status."
metadata:
  type: project
---

**Business:** <what the product is, who the owner is, how they communicate, key constraint>.

**Repos/services:** <each repo: what it serves, hosts, deploy target, database project ids>.

**Architecture invariants (do NOT violate):**
- <security topology, e.g. who may talk to the DB and how>
- <money/data-integrity rules if any>
- <migration/deploy discipline>
- <UI language(s) and text conventions>
- <Mark any fact not confirmed by the owner or the code as `(ASSUMED)`; upgrade to confirmed
  as the owner verifies them.>

**Verification protocol (before "done"):** <exact commands, e.g. typecheck → test → build;
how visuals are verified; anything banned>.

**Key code entry points:** <the 5-10 paths a fresh session needs first>.
```

## playbook.md skeleton

```markdown
---
name: playbook
description: "Self-learning playbook - owner's philosophy, how to present work, red flags that trigger corrections, and the mandatory pre-ship self-review. APPEND lessons freely; NEVER delete/soften an entry without asking the owner."
metadata:
  type: feedback
---

Living distillation of every owner correction. **Goal: the owner never has to ask "check it",
"make it consistent", "fix it everywhere" - that is a standard part of every task.** Upkeep
rule: a new correction (theirs or self-caught) → add the lesson here (philosophy/process) or
to the domain's Gotchas (code specifics), in the SAME turn. Delete/soften only with owner
permission.

## Product philosophy

- <what the owner values: e.g. uniformity without exceptions, honest failure states,
  predictability>

## How to present work

- <answer shape, language register, decision-vs-menu preference, honesty norms>

## What triggers corrections (red flags - self-check BEFORE delivering)

1. <accumulate the concrete recurring correction patterns here>

## Mandatory pre-ship self-review (before every "done")

1. **Verification:** <the project's full command triad — no exceptions, even for one-liners>.
2. **Class, not instance:** root-cause it first (that investigation belongs to the
   `systematic-debugging` skill) — fix only once the cause is certain, then sweep: does
   this same problem/pattern exist elsewhere? Fix every instance before closing.
3. **Uniformity:** new UI checked against the design checklist; states complete; measured,
   not eyeballed.
4. **Honest states:** what does the user see on failure/empty/slow for this exact flow?
5. **Memory:** domain status updated; episode written; this turn's lessons recorded.
6. **Committed** (follow the project's push convention).
7. **No new contradictions / stale rules:** any rule-bearing memory edit this turn checked
   against the rules it touches; owner already notified of any conflict or stale entry found,
   with a recommended fix.

## Lessons (append-only journal; promote into sections above when a pattern emerges)

- <YYYY-MM-DD>: <lesson>
```

## Episode file skeleton

```markdown
---
name: <kebab-name-with-date-if-timebound>
description: <one line that lets recall and a skimming session know exactly what's inside>
metadata:
  type: project
---

<Full detail: what/why/how, decisions with reasoning, commit hashes, migration numbers.>

<If interrupted mid-work on OUR side:>
## Resume checklist (in order)
1. <exact, self-contained steps a successor session can follow without this conversation>

<If instead the only remaining steps are the owner's (episode technically done on our side):
no IN PROGRESS marker in the domain — say WAITING ON OWNER there, put the owner's action in
MEMORY.md's owner-owes block, and keep a short closing checklist here (what to update where
once the owner acts).>
```

## CLAUDE.md memory pointer (idempotent — add once during Bootstrap/Migration, skip if present)

Skill-matching on the description is best-effort: a future session only reroutes into the
Maintenance protocol if it happens to notice the domain map before saving. Planting this line
in the project's `CLAUDE.md` makes that check deterministic instead. Grep `CLAUDE.md` for
"domain map" first — if an equivalent line already exists (this step already ran, or the
owner wrote one), skip it.

```markdown
## Memory
Before saving any memory, check this project's MEMORY.md for a domain map. If one exists,
follow the memory-playbook skill's Maintenance protocol (episode file → pointer in its domain
→ refresh that domain's status) instead of writing directly into MEMORY.md.
```

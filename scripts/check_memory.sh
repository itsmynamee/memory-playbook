#!/bin/bash
# Integrity check for a domain-memory directory.
# Usage: check_memory.sh <memory-dir>
# FAILS (exit 1) on: missing MEMORY.md, orphaned files, fake domain-* files.
# WARNS (exit 0) on: size ceilings exceeded - those are maintenance nudges, not breakage.
set -euo pipefail

DIR="${1:?usage: check_memory.sh <memory-dir>}"
cd "$DIR"

[ -f MEMORY.md ] || { echo "FAIL: no MEMORY.md in $DIR"; exit 1; }

fail=0
warn=0

echo "== Orphan check: every file reachable from an entry file (MEMORY.md, any domain-*.md, project-map.md, playbook.md) =="
# A reference counts only as an explicit link: [[name]] or name.md - fixed-string matched,
# so short names are never masked by longer ones (pay vs payments) and dots are literal.
# A file mentioning its own name does NOT count - self-references can't adopt an orphan.
entry_files=(MEMORY.md)
for e in domain-*.md project-map.md playbook.md; do [ -e "$e" ] && entry_files+=("$e"); done
for f in *.md; do
  n="${f%.md}"
  [ "$n" = "MEMORY" ] && continue
  refs=()
  for e in "${entry_files[@]}"; do [ "$e" != "$f" ] && refs+=("$e"); done
  if ! grep -qF -- "[[${n}]]" "${refs[@]}" 2>/dev/null \
     && ! grep -qF -- "${n}.md" "${refs[@]}" 2>/dev/null; then
    echo "ORPHAN: $n (no [[${n}]] or ${n}.md link in any entry file)"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "OK: no orphans"

echo "== Size ceilings (warnings) =="
mem_size=$(wc -c < MEMORY.md | tr -d ' ')
echo "MEMORY.md: ${mem_size} bytes"
if [ "$mem_size" -gt 17000 ]; then
  echo "WARN: MEMORY.md over ~17KB - it is holding status it shouldn't; move content into domains"
  warn=1
fi
for f in domain-*.md; do
  [ -e "$f" ] || continue
  case "$f" in *-archive.md) continue ;; esac  # archives exist to absorb overflow - no ceiling
  s=$(wc -c < "$f" | tr -d ' ')
  if [ "$s" -gt 10000 ]; then
    echo "WARN: $f is ${s} bytes (>10KB) - split shipped-history into ${f%.md}-archive.md (and link it from ${f})"
    warn=1
  fi
done

echo "== Naming collisions: only real domain indexes (or their archives) may match domain-*.md =="
# The machine marker is the verbatim English token "Domain index" at the start of the
# description - kept in English even when memory content is in another language.
for f in domain-*.md; do
  [ -e "$f" ] || continue
  case "$f" in *-archive.md) continue ;; esac
  if ! grep -q '^description: .*Domain index' "$f"; then
    echo "FAIL: $f matches the domain-* prefix but its description does not start with the 'Domain index' marker"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  if [ "$warn" -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "PASSED WITH WARNINGS (see above)"; fi
  exit 0
else
  echo "ISSUES FOUND (see above)"
  exit 1
fi

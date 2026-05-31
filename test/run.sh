#!/usr/bin/env bash
# test/run.sh — smoke tests for brunnr-init.
#
# Installs the kit into throwaway directories and asserts the install
# contract: schema placement, symlink vs copy modes, fresh-vault seeding,
# {{DATE}} rendering, idempotency (seed-once preserved, refresh-always
# refreshed), and the self-install guard. No external dependencies.
#
# Usage: test/run.sh   (exit 0 = all pass)

set -u

HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
KIT="$(dirname "$HERE")"
INIT="$KIT/bin/brunnr-init"
TODAY="$(date +%F)"

T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT

tests=0; fails=0
check(){ local d="$1"; shift; tests=$((tests+1))
  if "$@" >/dev/null 2>&1; then printf '  \033[32mok\033[0m   %s\n' "$d"
  else printf '  \033[31mFAIL\033[0m %s\n' "$d"; fails=$((fails+1)); fi; }
not(){ ! "$@"; }
h1(){ [ "$(head -1 "$1")" = "$2" ]; }

echo "brunnr-init tests (kit: $KIT)"

# --- 1. default (symlink) install into a fresh vault ----------------------
V="$T/sym"; "$INIT" "$V" >/dev/null 2>&1
echo "[symlink mode]"
check "AGENTS.md created"               test -e "$V/AGENTS.md"
check "AGENTS.md is a symlink"          test -L "$V/AGENTS.md"
check "AGENTS.md is the schema"         h1 "$V/AGENTS.md" "# Wiki Schema"
check "CLAUDE.md mirrors the schema"    h1 "$V/CLAUDE.md" "# Wiki Schema"
check "procedures/ is a symlink"        test -L "$V/procedures"
check "procedures/ingest.md present"    test -f "$V/procedures/ingest.md"
check "procedures/query.md present"     test -f "$V/procedures/query.md"
check "procedures/lint.md present"      test -f "$V/procedures/lint.md"
check "claude shim installed"           test -f "$V/.claude/skills/wiki-ingest/SKILL.md"
check "raw/ created"                    test -d "$V/raw"
check "VAULT.md seeded"                 test -f "$V/VAULT.md"
check "wiki/index.md seeded"            test -f "$V/wiki/index.md"
check "wiki/log.md seeded"              test -f "$V/wiki/log.md"
check "index.md has today's date"       grep -q "$TODAY" "$V/wiki/index.md"
check "no literal {{DATE}} remains"     not grep -rq "{{DATE}}" "$V/wiki"
check "log.md notes brunnr init"        grep -q "Vault initialized from brunnr" "$V/wiki/log.md"
# symlink contract: kit-owned files are links, vault-local files are real
check "CLAUDE.md is a symlink"          test -L "$V/CLAUDE.md"
check "shim dir is a symlink"           test -L "$V/.claude/skills/wiki-ingest"
check "VAULT.md is real (seed-once)"    not test -L "$V/VAULT.md"
check "index.md is real (seed-once)"    not test -L "$V/wiki/index.md"
check "log.md is real (seed-once)"      not test -L "$V/wiki/log.md"

# --- 2. forced copy mode ---------------------------------------------------
V="$T/cp"; "$INIT" --copy "$V" >/dev/null 2>&1
echo "[copy mode]"
check "AGENTS.md is a regular file"     not test -L "$V/AGENTS.md"
check "AGENTS.md is the schema"         h1 "$V/AGENTS.md" "# Wiki Schema"
check "CLAUDE.md is a regular file"     not test -L "$V/CLAUDE.md"
check "procedures/ is copied, not link" not test -L "$V/procedures"
check "procedures/ingest.md present"    test -f "$V/procedures/ingest.md"

# --- 3. idempotency: seed-once preserved, refresh-always refreshed ---------
# (copy mode so we can safely tamper without editing the kit through a symlink)
V="$T/idem"; "$INIT" --copy "$V" >/dev/null 2>&1
printf 'MY VAULT NOTES\n'              > "$V/VAULT.md"        # user owns this
printf '# Index\n\nmy custom index\n'  > "$V/wiki/index.md"  # user owns this
printf 'a source\n'                    > "$V/raw/source.md"
printf '# A page\n'                    > "$V/wiki/apage.md"
printf 'TAMPERED\n'                    > "$V/AGENTS.md"       # kit must win here
"$INIT" --copy "$V" >/dev/null 2>&1                          # re-run
echo "[idempotent re-run]"
check "VAULT.md preserved (seed-once)"      grep -q "MY VAULT NOTES" "$V/VAULT.md"
check "index.md preserved (seed-once)"      grep -q "my custom index" "$V/wiki/index.md"
check "raw/ source preserved"               test -f "$V/raw/source.md"
check "wiki page preserved"                 test -f "$V/wiki/apage.md"
check "AGENTS.md refreshed (refresh-always)" not grep -q "TAMPERED" "$V/AGENTS.md"
check "AGENTS.md is the schema again"       h1 "$V/AGENTS.md" "# Wiki Schema"

# --- 4. refuses to install into the kit itself (isolated copy) -------------
FK="$T/fakekit"; cp -R "$KIT" "$FK"; rm -rf "$FK/.git"
echo "[self-install guard]"
check "non-zero exit when target == kit"        not "$FK/bin/brunnr-init" "$FK"
check "guard left the kit untouched"            not test -e "$FK/VAULT.md"

# --- summary ---------------------------------------------------------------
echo
if [ "$fails" -eq 0 ]; then
  printf '\033[32mPASS\033[0m  %d checks\n' "$tests"; exit 0
else
  printf '\033[31mFAIL\033[0m  %d/%d checks failed\n' "$fails" "$tests"; exit 1
fi

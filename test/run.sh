#!/usr/bin/env bash
# test/run.sh — smoke tests for brunnr-init.
#
# Installs the kit into throwaway directories and asserts the install
# contract: schema placement, symlink vs copy modes, fresh-well seeding,
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

# Sandbox HOME so brunnr-init's `brunnr` PATH symlink lands here, not in the real
# ~/.local/bin. Add it to PATH so we can exercise the installed `brunnr` command.
export HOME="$T/home"; mkdir -p "$HOME/.local/bin"; PATH="$HOME/.local/bin:$PATH"

tests=0; fails=0
check(){ local d="$1"; shift; tests=$((tests+1))
  if "$@" >/dev/null 2>&1; then printf '  \033[32mok\033[0m   %s\n' "$d"
  else printf '  \033[31mFAIL\033[0m %s\n' "$d"; fails=$((fails+1)); fi; }
not(){ ! "$@"; }
h1(){ [ "$(head -1 "$1")" = "$2" ]; }

echo "brunnr-init tests (kit: $KIT)"

# --- 1. default (symlink) install into a fresh well ----------------------
V="$T/sym"; "$INIT" "$V" >/dev/null 2>&1
echo "[symlink mode]"
check "AGENTS.md created"               test -e "$V/AGENTS.md"
check "AGENTS.md is a symlink"          test -L "$V/AGENTS.md"
check "AGENTS.md is the schema"         h1 "$V/AGENTS.md" "# Wiki Schema"
check "CLAUDE.md mirrors the schema"    h1 "$V/CLAUDE.md" "# Wiki Schema"
check "procedures/ is a symlink"        test -L "$V/procedures"
check "procedures/ingest.md present"    test -f "$V/procedures/ingest.md"
check "procedures/synthesize.md present" test -f "$V/procedures/synthesize.md"
check "procedures/query.md present"     test -f "$V/procedures/query.md"
check "procedures/lint.md present"      test -f "$V/procedures/lint.md"
check "procedures/sync.md present"      test -f "$V/procedures/sync.md"
check "procedures/qmd-setup.md present"  test -f "$V/procedures/qmd-setup.md"
check "procedures/qmd-update.md present" test -f "$V/procedures/qmd-update.md"
check "claude shim installed"           test -f "$V/.claude/skills/wiki-ingest/SKILL.md"
check "wiki-synthesize shim installed"  test -f "$V/.claude/skills/wiki-synthesize/SKILL.md"
check "wiki-sync shim installed"        test -f "$V/.claude/skills/wiki-sync/SKILL.md"
check "qmd-setup shim installed"        test -f "$V/.claude/skills/qmd-setup/SKILL.md"
check "brunnr not copied into well"     not test -e "$V/brunnr"
check "brunnr symlinked onto PATH"      test -L "$HOME/.local/bin/brunnr"
check "brunnr link points at kit"       test "$(readlink "$HOME/.local/bin/brunnr")" = "$KIT/bin/brunnr"
check "brunnr command runs"             env -C "$V" brunnr --help
check "brunnr resolves well from cwd"   env -C "$V" sh -c 'brunnr search-enabled; [ $? -ne 2 ]'
check "source/ created"                    test -d "$V/source"
check "source/.orig created"               test -d "$V/source/.orig"
check "inbox/ created"                     test -d "$V/inbox"
check "WELL.md seeded"                 test -f "$V/WELL.md"
check "wiki/index.md seeded"            test -f "$V/wiki/index.md"
check "wiki/log.md seeded"              test -f "$V/wiki/log.md"
check "pending-synthesis.md seeded"     test -f "$V/pending-synthesis.md"
check "index.md has today's date"       grep -q "$TODAY" "$V/wiki/index.md"
check "no literal {{DATE}} remains"     not grep -rq "{{DATE}}" "$V/wiki"
check "log.md notes brunnr init"        grep -q "Well initialized from brunnr" "$V/wiki/log.md"
# symlink contract: kit-owned files are links, well-local files are real
check "CLAUDE.md is a symlink"          test -L "$V/CLAUDE.md"
check "shim dir is a symlink"           test -L "$V/.claude/skills/wiki-ingest"
check "WELL.md is real (seed-once)"    not test -L "$V/WELL.md"
check "index.md is real (seed-once)"    not test -L "$V/wiki/index.md"
check "log.md is real (seed-once)"      not test -L "$V/wiki/log.md"
check "pending-synthesis is real (seed-once)" not test -L "$V/pending-synthesis.md"
check ".brunnr.toml marker written"     test -f "$V/.brunnr.toml"
check "marker records symlink mode"     grep -q 'install-mode = "symlink"' "$V/.brunnr.toml"
check "marker carries no qmd keys"      not grep -q "qmd-" "$V/.brunnr.toml"

# --- 2. forced copy mode ---------------------------------------------------
V="$T/cp"; "$INIT" --copy "$V" >/dev/null 2>&1
echo "[copy mode]"
check "AGENTS.md is a regular file"     not test -L "$V/AGENTS.md"
check "AGENTS.md is the schema"         h1 "$V/AGENTS.md" "# Wiki Schema"
check "CLAUDE.md is a regular file"     not test -L "$V/CLAUDE.md"
check "procedures/ is copied, not link" not test -L "$V/procedures"
check "procedures/ingest.md present"    test -f "$V/procedures/ingest.md"
check "marker records copy mode"        grep -q 'install-mode = "copy"' "$V/.brunnr.toml"

# --- 3. idempotency: seed-once preserved, refresh-always refreshed ---------
# (copy mode so we can safely tamper without editing the kit through a symlink)
V="$T/idem"; "$INIT" --copy "$V" >/dev/null 2>&1
printf 'MY WELL NOTES\n'              > "$V/WELL.md"        # user owns this
printf '# Index\n\nmy custom index\n'  > "$V/wiki/index.md"  # user owns this
printf 'a source\n'                    > "$V/source/source.md"
printf '# A page\n'                    > "$V/wiki/apage.md"
printf '# Pending synthesis\n\n- [x](./source/x.md) — ingested 2026-01-01\n' > "$V/pending-synthesis.md"  # user owns this
printf 'TAMPERED\n'                    > "$V/AGENTS.md"       # kit must win here
"$INIT" --copy "$V" >/dev/null 2>&1                          # re-run
echo "[idempotent re-run]"
check "WELL.md preserved (seed-once)"      grep -q "MY WELL NOTES" "$V/WELL.md"
check "index.md preserved (seed-once)"      grep -q "my custom index" "$V/wiki/index.md"
check "source/ source preserved"               test -f "$V/source/source.md"
check "wiki page preserved"                 test -f "$V/wiki/apage.md"
check "pending-synthesis preserved (seed-once)" grep -q "x.md" "$V/pending-synthesis.md"
check "AGENTS.md refreshed (refresh-always)" not grep -q "TAMPERED" "$V/AGENTS.md"
check "AGENTS.md is the schema again"       h1 "$V/AGENTS.md" "# Wiki Schema"

# --- 4. refuses to install into the kit itself (isolated copy) -------------
FK="$T/fakekit"; cp -R "$KIT" "$FK"; rm -rf "$FK/.git"
echo "[self-install guard]"
check "non-zero exit when target == kit"        not "$FK/bin/brunnr-init" "$FK"
check "guard left the kit untouched"            not test -e "$FK/WELL.md"

# --- 5. ownership guard: refuse to clobber a non-brunnr directory ----------
V="$T/foreign"; mkdir -p "$V"; printf 'my own notes\n' > "$V/AGENTS.md"
echo "[ownership guard]"
check "refuses non-brunnr target"           not "$INIT" "$V"
check "foreign AGENTS.md left intact"       grep -q "my own notes" "$V/AGENTS.md"
check "no marker written on refusal"        not test -e "$V/.brunnr.toml"
check "--force overrides the guard"         "$INIT" --force "$V"
check "schema installed after --force"      h1 "$V/AGENTS.md" "# Wiki Schema"
check "marker written after --force"        test -f "$V/.brunnr.toml"

# --- 6. install mode is remembered across re-inits -------------------------
V="$T/sticky"; "$INIT" --copy "$V" >/dev/null 2>&1   # first init records copy
"$INIT" "$V" >/dev/null 2>&1                          # re-init with no flag
echo "[mode persistence]"
check "mode stays copy without a flag"      grep -q 'install-mode = "copy"' "$V/.brunnr.toml"
check "AGENTS.md still a real file"         not test -L "$V/AGENTS.md"
"$INIT" --symlink "$V" >/dev/null 2>&1               # explicit flag overrides
check "--symlink overrides recorded mode"   test -L "$V/AGENTS.md"
check "marker updated to symlink"           grep -q 'install-mode = "symlink"' "$V/.brunnr.toml"

# --- 7. PATH-symlink guard: don't clobber a foreign ~/.local/bin/brunnr -----
H2="$T/home2"; mkdir -p "$H2/.local/bin"; printf 'mine\n' > "$H2/.local/bin/brunnr"
HOME="$H2" "$INIT" "$T/w2" >/dev/null 2>&1
echo "[PATH-symlink guard]"
check "foreign ~/.local/bin/brunnr intact"  grep -q mine "$H2/.local/bin/brunnr"
check "foreign brunnr not made a symlink"   not test -L "$H2/.local/bin/brunnr"

# --- 8. install-brunnr bootstrap + brunnr init/update verbs ----------------
# Build a throwaway kit from the working tree (so it carries the code under test),
# make it a local git repo, and clone *that* — so brunnr update's `git pull
# --ff-only` resolves against a local origin and never touches the network or the
# real repo. Skipped if git is unavailable.
if command -v git >/dev/null 2>&1; then
  echo "[install-brunnr + init/update verbs]"
  SK="$T/sandkit"; cp -R "$KIT" "$SK"; rm -rf "$SK/.git"
  git -C "$SK" init -q
  git -C "$SK" add -A
  git -C "$SK" -c user.email=t@example.com -c user.name=test commit -qm init >/dev/null

  CACHE="$T/cache/brunnr"
  BRUNNR_HOME="$CACHE" "$SK/bin/install-brunnr" "$SK" >/dev/null 2>&1
  check "install-brunnr cloned the kit"       test -d "$CACHE/.git"
  check "install-brunnr linked brunnr"        test -L "$HOME/.local/bin/brunnr"
  check "link points at the checkout"         test "$(readlink "$HOME/.local/bin/brunnr")" = "$CACHE/bin/brunnr"
  check "linked brunnr runs"                  brunnr --help

  # init via the verb creates a well (copy mode so we can tamper without writing
  # through a symlink into the kit checkout).
  VI="$T/viainit"
  check "brunnr init creates a well"          brunnr init --copy "$VI"
  check "init placed the schema"              h1 "$VI/AGENTS.md" "# Wiki Schema"
  check "init wrote the marker"               test -f "$VI/.brunnr.toml"
  # update pulls the (unchanged) local origin and refreshes the well.
  printf 'TAMPERED\n' > "$VI/AGENTS.md"
  check "brunnr update refreshes the well"    env -C "$VI" brunnr update
  check "update re-placed the schema"         h1 "$VI/AGENTS.md" "# Wiki Schema"
  # update must refuse to create a well: outside any well, and on a non-well target.
  check "update outside a well refuses"       not env -C "$T" brunnr update
  check "update on a non-well dir refuses"    not brunnr update "$T/notawell"
  check "update didn't create a well there"   not test -e "$T/notawell/.brunnr.toml"
  check "install-brunnr re-run is a no-op"    env BRUNNR_HOME="$CACHE" "$SK/bin/install-brunnr" "$SK"
else
  echo "[install-brunnr + init/update verbs] (skipped: git unavailable)"
fi

# --- summary ---------------------------------------------------------------
echo
if [ "$fails" -eq 0 ]; then
  printf '\033[32mPASS\033[0m  %d checks\n' "$tests"; exit 0
else
  printf '\033[31mFAIL\033[0m  %d/%d checks failed\n' "$fails" "$tests"; exit 1
fi

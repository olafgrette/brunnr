# brunnr — working on this repo

This file is for agents working **on brunnr itself**. brunnr is an agent-agnostic toolkit for LLM-maintained knowledge wikis (Karpathy's "LLM Wiki" pattern): a schema, operation playbooks, per-agent shims, and an installer.

> [!IMPORTANT]
> This `AGENTS.md` is **not** installed into wells. The file that becomes a well's `AGENTS.md`/`CLAUDE.md` is **`well-AGENTS.md`**. To change how a *well agent* behaves, edit `well-AGENTS.md` (or `procedures/`), not this file.

See `README.md` for the user-facing overview.

## What this repo produces

`bin/brunnr-init` installs a schema + playbooks into a **well** — a directory with `source/` documents, an `inbox/` staging area, and an LLM-maintained `wiki/`. A well receives: `AGENTS.md` (from `well-AGENTS.md`), a `CLAUDE.md` mirror, `procedures/`, Claude Code shims under `.claude/skills/`, and seeded `WELL.md`, `inbox/`, `source/.orig/`, `pending-synthesis.md`, and `wiki/{index,log}.md`. It also symlinks the `brunnr` helper onto PATH — a machine convenience, not a well file.

## Repo layout & lifecycle

| Path | Role | Goes into a well? |
|---|---|---|
| `AGENTS.md` | This file — guidance for working on brunnr | no |
| `README.md` | User-facing overview | no |
| `well-AGENTS.md` | The schema that becomes each well's `AGENTS.md`/`CLAUDE.md` | yes — **refresh-always** |
| `procedures/{ingest,synthesize,query,lint,sync,qmd-setup,qmd-update}.md` | Operation playbooks agents read at action time | yes — refresh-always |
| `shims/<agent>/` | Per-agent adapters that delegate to `procedures/` (now: `claude-code/`) | yes — refresh-always |
| `templates/{WELL.md,index.md,log.md,pending-synthesis.md}` | Seeds for well-local files (`{{DATE}}` → today) | yes — **seed-once**, never overwritten |
| `bin/brunnr` | The `brunnr` helper. `init`/`update` install wells (→ `brunnr-init`); `keyword`/`semantic`/`query`/`refresh`/`enabled` wrap qmd. Resolves the well from `$PWD`. | no — symlinked onto PATH |
| `bin/brunnr-init` | The installer (symlink, with copy fallback) | no |
| `bin/install-brunnr` | Machine bootstrap: clone the kit into `~/.cache/brunnr`, link `brunnr` onto PATH | no |

**The lifecycle split is the key invariant:** *refresh-always* files are kit-owned — never hand-edit them in a well (edits are clobbered on re-init). *Seed-once* files are the well's to edit.

`brunnr init` and `brunnr update` both delegate to `brunnr-init`. `update` also pulls the kit first (`git pull --ff-only`, works from anywhere) and refreshes the well only if `$PWD` (or the given dir) already has a `.brunnr.toml` — it never creates a well.

## Where to make a change

- Well-agent behavior / conventions / division of labor → `well-AGENTS.md`
- What an operation does, step by step → `procedures/*.md`
- A new agent's ergonomics (slash commands, auto-trigger) → add `shims/<agent>/` and teach `brunnr-init` to install it. Keep shims **thin** — they only point at `procedures/`.
- What a fresh well starts with → `templates/*`

## Conventions

- Keep `well-AGENTS.md` and `procedures/` **agent-agnostic** — no Claude- or Codex-specific instructions. Vendor specifics live only in `shims/`.
- The installer must stay **idempotent** and never touch a well's `source/`, existing `wiki/` pages, or `WELL.md`.
- Run `test/run.sh` after any installer change — it installs into throwaway dirs and asserts the contract in both symlink and copy modes. Add a case when you change install behavior.
- Wells on copy-mode filesystems (e.g. rclone gdrive) need a `brunnr update`/`brunnr-init` re-run to pick up kit changes; symlinked wells are already live.

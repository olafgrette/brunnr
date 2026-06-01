# brunnr — working on this repo

This file is for agents working **on brunnr itself**. brunnr is an agent-agnostic toolkit for LLM-maintained knowledge wikis (Karpathy's "LLM Wiki" pattern): a schema, operation playbooks, per-agent shims, and an installer.

> [!IMPORTANT]
> This `AGENTS.md` is **not** installed into wells. The file that becomes a well's `AGENTS.md`/`CLAUDE.md` is **`well-AGENTS.md`**. When you mean to change how a *well agent* behaves, edit `well-AGENTS.md` (or `procedures/`), not this file.

See `README.md` for the user-facing overview.

## What this repo produces

`bin/brunnr-init` installs a schema + playbooks into a **well** (a directory with `source/` documents, an `inbox/` staging area, and an LLM-maintained `wiki/`). A well receives: `AGENTS.md` (from `well-AGENTS.md`), a `CLAUDE.md` mirror, `procedures/`, Claude Code shims under `.claude/skills/`, and seeded `WELL.md`, `inbox/`, and `wiki/{index,log}.md`. It also symlinks the `brunnr` helper command (`bin/brunnr`) into `~/.local/bin` — a machine-level convenience, not a well file.

## Repo layout & lifecycle

| Path | Role | Goes into a well? |
|---|---|---|
| `AGENTS.md` | This file — guidance for working on brunnr | no |
| `README.md` | User-facing overview | no |
| `well-AGENTS.md` | The schema that becomes each well's `AGENTS.md`/`CLAUDE.md` | yes — **refresh-always** (re-placed every init) |
| `bin/brunnr` | The `brunnr` helper command. Install verbs (`brunnr init`/`update`) delegate to `bin/brunnr-init`; search verbs (`brunnr search-…`) wrap qmd for the playbooks. Resolves the well from `$PWD`, so one command serves every well. | no — symlinked onto PATH, never copied into the well |
| `bin/install-brunnr` | Machine bootstrap: clones the kit into `~/.cache/brunnr` and symlinks `brunnr` onto PATH. Run once per machine; re-run to update. | no |
| `procedures/{ingest,query,lint}.md` | Operation playbooks agents read at action time | yes — refresh-always |
| `shims/<agent>/` | Per-agent adapters delegating to `procedures/` (now: `claude-code/`) | yes — refresh-always |
| `templates/{WELL.md,index.md,log.md}` | Seeds for well-local files (`{{DATE}}` → today) | yes — **seed-once**, never overwritten; the well owns them after |
| `bin/brunnr-init` | Installer (symlink, with copy fallback) | no |

The lifecycle split is the key invariant: **refresh-always** files are kit-owned and must not be hand-edited inside a well (edits are clobbered on re-init); **seed-once** files are the well's to edit.

## Where to make a change

- Well-agent behavior / conventions / division of labor → `well-AGENTS.md`
- What an operation does, step by step → `procedures/*.md`
- A new agent's ergonomics (slash commands, auto-trigger) → add `shims/<agent>/` and teach `brunnr-init` to install it. Keep shims **thin** — they only point at `procedures/`; the portable logic stays in the procedures.
- What a fresh well starts with → `templates/*`

## Conventions

- Keep `well-AGENTS.md` and `procedures/` **agent-agnostic** — no Claude- or Codex-specific instructions. Vendor specifics live only in `shims/`.
- The installer must stay **idempotent** and must never touch a well's `source/`, existing `wiki/` pages, or `WELL.md`.
- Run `test/run.sh` after any installer change — it installs into throwaway dirs and asserts the contract in both symlink and copy modes (schema placement, seeding, `{{DATE}}` rendering, idempotency, the symlink/seed-once split, and the self-install guard). Add a case there when you change install behavior.
- After changing anything that's installed, remember: wells on copy-mode filesystems (e.g. rclone gdrive) need a `brunnr-init` re-run to pick it up; symlinked wells are already live.

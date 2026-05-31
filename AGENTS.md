# wiki-kit — working on this repo

This file is for agents working **on wiki-kit itself**. wiki-kit is an agent-agnostic toolkit for LLM-maintained knowledge wikis (Karpathy's "LLM Wiki" pattern): a schema, operation playbooks, per-agent shims, and an installer.

> [!IMPORTANT]
> This `AGENTS.md` is **not** installed into vaults. The file that becomes a vault's `AGENTS.md`/`CLAUDE.md` is **`vault-AGENTS.md`**. When you mean to change how a *vault agent* behaves, edit `vault-AGENTS.md` (or `procedures/`), not this file.

See `README.md` for the user-facing overview.

## What this repo produces

`bin/wiki-kit-init` installs a schema + playbooks into a **vault** (a directory with `raw/` sources and an LLM-maintained `wiki/`). A vault receives: `AGENTS.md` (from `vault-AGENTS.md`), a `CLAUDE.md` mirror, `procedures/`, Claude Code shims under `.claude/skills/`, and seeded `VAULT.md` + `wiki/{index,log}.md`.

## Repo layout & lifecycle

| Path | Role | Goes into a vault? |
|---|---|---|
| `AGENTS.md` | This file — guidance for working on wiki-kit | no |
| `README.md` | User-facing overview | no |
| `vault-AGENTS.md` | The schema that becomes each vault's `AGENTS.md`/`CLAUDE.md` | yes — **refresh-always** (re-placed every init) |
| `procedures/{ingest,query,lint}.md` | Operation playbooks agents read at action time | yes — refresh-always |
| `shims/<agent>/` | Per-agent adapters delegating to `procedures/` (now: `claude-code/`) | yes — refresh-always |
| `templates/{VAULT.md,index.md,log.md}` | Seeds for vault-local files (`{{DATE}}` → today) | yes — **seed-once**, never overwritten; the vault owns them after |
| `bin/wiki-kit-init` | Installer (symlink, with copy fallback) | no |

The lifecycle split is the key invariant: **refresh-always** files are kit-owned and must not be hand-edited inside a vault (edits are clobbered on re-init); **seed-once** files are the vault's to edit.

## Where to make a change

- Vault-agent behavior / conventions / division of labor → `vault-AGENTS.md`
- What an operation does, step by step → `procedures/*.md`
- A new agent's ergonomics (slash commands, auto-trigger) → add `shims/<agent>/` and teach `wiki-kit-init` to install it. Keep shims **thin** — they only point at `procedures/`; the portable logic stays in the procedures.
- What a fresh vault starts with → `templates/*`

## Conventions

- Keep `vault-AGENTS.md` and `procedures/` **agent-agnostic** — no Claude- or Codex-specific instructions. Vendor specifics live only in `shims/`.
- The installer must stay **idempotent** and must never touch a vault's `raw/`, existing `wiki/` pages, or `VAULT.md`.
- Test installer changes against a throwaway dir in **both** modes (default symlink and `--copy`) before relying on them.
- After changing anything that's installed, remember: vaults on copy-mode filesystems (e.g. rclone gdrive) need a `wiki-kit-init` re-run to pick it up; symlinked vaults are already live.

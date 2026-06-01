# brunnr

Agent-agnostic schema and operation playbooks for LLM-maintained knowledge wikis, based on Andrej Karpathy's [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) pattern. For my own personal use, but posted publicly. I don't expect anyone else to use this and defaults/evolution/improvements will be for explicitly my workflow.

A **well** is a directory with `source/` (immutable sources) and `wiki/` (LLM-maintained pages). This repo holds the shared brain — the schema (`well-AGENTS.md`), the operation playbooks (`procedures/`), and per-agent shims (`shims/`) — so you can run the same disciplined wiki workflow across many wells and machines without copy-paste drift.

## Install into a well

```sh
git clone https://github.com/<you>/brunnr ~/workspaces/brunnr
cd /path/to/your/well
~/workspaces/brunnr/bin/brunnr-init        # or: brunnr-init /path/to/well
```

`brunnr-init` installs the schema (`well-AGENTS.md`, placed as the well's `AGENTS.md`), `procedures/`, a `CLAUDE.md` mirror, and the Claude Code shims into the well, and seeds `WELL.md` + an empty `wiki/` skeleton on first run. It also symlinks the `brunnr` helper command into `~/.local/bin` (machine-level; used for optional search).

- **By default it symlinks**, so kit updates propagate live (`git pull` in the kit and every symlinked well is current).
- On filesystems that can't symlink (e.g. an **rclone Google Drive mount**) it **falls back to copying**; re-run `brunnr-init` after updating the kit to refresh copy-mode wells. The chosen mode is recorded in `.brunnr.toml` and reused on re-init — so a synced well stays consistent across machines — and you can override with `--symlink` / `--copy`.
- It stamps each well with `.brunnr.toml` and **refuses to overwrite a non-brunnr directory** (one with foreign files where it would install) unless you pass `--force`.
- It **never touches** `source/`, existing `wiki/` pages, or your `WELL.md`.

## Search (optional)

At small scale the playbooks just read `wiki/index.md` and the relevant pages. As a well grows, that stops scaling — so the playbooks can use [qmd](https://github.com/tobi/qmd), a local hybrid search engine (BM25 + vector + reranking over SQLite, models run on-device), to retrieve the right pages directly.

Setup is **not** part of `brunnr-init` — it's a deliberate, optional step you trigger when a well is worth indexing. Install qmd, then run the `qmd-setup` procedure (`/qmd-setup` in Claude Code, or just point the agent at `procedures/qmd-setup.md`):

- **Install:** `bun install -g @tobilu/qmd` (or `npm install -g`; needs Node ≥22).
- **Set up the well** (`procedures/qmd-setup.md`): registers two collections — `<wellname>-wiki` (over `wiki/`) and `<wellname>-source` (over `source/`) — attaches this well's one-line `WELL.md` summary to each as qmd *context* (returned alongside every hit, so an agent knows what it found — qmd's most useful feature), and warms the models with `qmd embed` (a one-time ~2GB download, cached under `~/.cache/qmd/`). **Run setup in a real terminal** — the model downloader is progress-bar driven and can stall under a non-interactive shell. After that, operations are local and fast (a no-change refresh is ~150ms).
- **Opt out:** just don't run `qmd-setup`. `brunnr-init` symlinks the `brunnr` helper command onto your PATH (the wrapper agents use), but never registers collections or downloads models — setup stays agent-driven. Every playbook degrades gracefully to reading `index.md` when qmd isn't configured (detected via `brunnr search-enabled`).
- **Synced wells:** qmd's index and models live in `~/.cache/qmd/` — machine-local, not synced. So run `qmd-setup` **per machine**. Collection names derive from the well's directory, so they resolve identically everywhere; don't try to share qmd's SQLite index through the sync mount.

The playbooks call the `brunnr` helper (`brunnr …`), which picks the qmd command for the job: `search-keyword` (BM25, no models) for the common path, `search-semantic` (vector) to surface related ideas during ingest/lint, `search-query` (hybrid+reranked) when a large well needs it. The index is refreshed via `search-refresh` after ingest/sync and before lint (`procedures/qmd-update.md`), not on every query. `index.md` stays the human-curated map; qmd is the machine retrieval index, not a replacement for it.

## Layout

| Path | Role | Into a well? |
|---|---|---|
| `AGENTS.md` | Guide for agents working **on brunnr** (this repo). | no |
| `well-AGENTS.md` | The schema that becomes each well's `AGENTS.md`/`CLAUDE.md`: layers, page conventions, division of labor, the operation dispatch table. Read by every agent (Codex natively; Claude Code via the `CLAUDE.md` mirror). | yes — refreshed every init |
| `procedures/{ingest,query,lint,sync}.md` (+ optional `qmd-setup.md`, `qmd-update.md`) | Step-by-step playbooks. Agents read the relevant one *at the moment they act* — better adherence than burying the steps in always-on context. | yes — refreshed |
| `bin/brunnr` | The `brunnr` helper command — a qmd wrapper (`brunnr search-…`) the playbooks call; `brunnr-init` symlinks it into `~/.local/bin`. Resolves the well from `$PWD`, so one command serves every well. Not the installer (`bin/brunnr-init`). | no — symlinked onto PATH |
| `shims/claude-code/` | Claude Code skills that delegate to the procedures (slash-command + auto-trigger ergonomics). Thin adapters; the portable truth lives in `procedures/`. Add `shims/<agent>/` for other agents the same way. | yes — refreshed |
| `templates/{WELL.md,index.md,log.md}` | Seeds for well-local files on first init (`{{DATE}}` → today). The well owns and edits these afterward. | yes — seeded once, never overwritten |
| `bin/brunnr-init` | The installer (symlink with copy fallback). | no |

## Shared vs. per-well

| Shared (this repo) | Per-well (local, never overwritten) |
|---|---|
| `well-AGENTS.md`, `procedures/`, `shims/` | `WELL.md` (domain & scope), `source/`, `wiki/` |

Edit the schema **here**, not inside a well — in-well copies are regenerated by `brunnr-init`.

## License

[MIT](./LICENSE) © 2026 Olaf Grette

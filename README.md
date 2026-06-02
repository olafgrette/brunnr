# brunnr

Agent-agnostic schema and playbooks for LLM-maintained knowledge wikis, based on Andrej Karpathy's [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) pattern. Built for my own use, posted publicly. The defaults follow my workflow; I don't expect anyone else to use it.

A **well** is a directory with `source/` (immutable sources you add), `inbox/` (where you drop new sources to ingest), and `wiki/` (pages the LLM writes and maintains). A `pending-synthesis.md` worklist tracks sources captured but not yet woven in — the ingest→synthesize split. This repo is the shared brain — the schema (`well-AGENTS.md`), the operation playbooks (`procedures/`), and per-agent shims (`shims/`) — so the same wiki workflow runs across many wells and machines without copy-paste drift.

## Install

```sh
# once per machine: clone the kit and put `brunnr` on your PATH
curl -fsSL https://raw.githubusercontent.com/olafgrette/brunnr/main/bin/install-brunnr | bash

# then, inside each well:
cd /path/to/your/well
brunnr init
```

`install-brunnr` clones the kit into `~/.cache/brunnr` (override with `BRUNNR_HOME`) and symlinks the `brunnr` helper into `~/.local/bin`.

- **`brunnr init [DIR]`** — install the schema, playbooks, and shims into a well (current directory by default). Seeds `WELL.md` and an empty `wiki/` on first run.
- **`brunnr update [DIR]`** — pull the latest kit. Run it anywhere; if you're inside a well it refreshes that well too. It never *creates* a well — use `init` for that.

`init` symlinks kit files by default, so one `update` propagates everywhere at once. On filesystems that can't symlink (e.g. an **rclone Google Drive mount**) it copies instead; re-run `init`/`update` to refresh copies. The mode is recorded in `.brunnr.toml` and reused (override with `--symlink`/`--copy`). It refuses to overwrite a non-brunnr directory unless you pass `--force`, and never touches `source/`, your existing `wiki/` pages, or `WELL.md`.

## Search (optional)

Small wells: the playbooks just read `wiki/index.md` and the pages it points to. As a well grows, that stops scaling — so the playbooks can use [qmd](https://github.com/tobi/qmd), a local search engine (keyword + vector + reranking, models run on-device), to find the right pages directly.

Setup is opt-in, not part of `brunnr init`. Install qmd, then run the `qmd-setup` procedure (`/qmd-setup` in Claude Code):

- **Install:** `bun install -g @tobilu/qmd` (or `npm install -g @tobilu/qmd`; needs Node ≥22).
- **Set up the well:** registers two collections — `<well>-wiki` (over `wiki/`) and `<well>-source` (over `source/`) — attaches the well's one-line `WELL.md` summary to each, and downloads the embedding models (a one-time ~2GB, cached in `~/.cache/qmd/`). Run it in a real terminal — the model downloader is progress-bar driven and can stall otherwise.
- **Per machine:** qmd's index and models are machine-local, not synced — run `qmd-setup` on each machine you use a synced well from. Collection names derive from the well's directory (`basename`), so they resolve identically everywhere. The flip side: two wells with the same leaf name on one machine (`~/work/notes` and `~/personal/notes`) would share qmd collections — keep leaf names unique per machine.
- **Opt out:** just don't run it — every playbook falls back to reading `index.md` (detected via `brunnr search-enabled`). To make the opt-out explicit and silence the "run qmd-setup" hint, set `search = false` in the well's `.brunnr.toml`.

The playbooks call `brunnr`, which picks the qmd command for the job: `search-keyword` (BM25, the common path), `search-semantic` (vector, for related ideas), `search-query` (hybrid + rerank, for large wells). The index is refreshed after ingest/sync and before lint via `search-refresh`, not on every query. `index.md` stays the human-curated map; qmd finds pages at scale, not a replacement for it.

These wrappers parse qmd's `status` output and verb names (`search`/`vsearch`/`query`/`update`/`embed`), so a future qmd release that changes that surface **silently disables search** — every playbook just falls back to `index.md` with no error. If search stops finding things, run `brunnr search-enabled` — it prints whether search is live for the well. qmd is young; if you depend on search, note the qmd version you set up against and re-test after upgrading.

## Layout

| Path | Role | Into a well? |
|---|---|---|
| `AGENTS.md` | Guide for agents working **on brunnr** (this repo). | no |
| `well-AGENTS.md` | The schema each well gets as its `AGENTS.md`/`CLAUDE.md`: layers, page conventions, division of labor, the operation table. | yes — refreshed every init |
| `procedures/*.md` | Step-by-step playbooks. Agents read the relevant one when they act. | yes — refreshed |
| `bin/brunnr` | The `brunnr` helper. `init`/`update` install wells; `search-*` wrap qmd. Resolves the well from `$PWD`. | no — symlinked onto PATH |
| `bin/brunnr-init` | The installer (symlink with copy fallback); invoked by `brunnr init`/`update`. | no |
| `bin/install-brunnr` | Machine bootstrap: clone the kit, link `brunnr` onto PATH. | no |
| `shims/claude-code/` | Claude Code skills that delegate to the procedures. Add `shims/<agent>/` for other agents. | yes — refreshed |
| `templates/*` | Seeds for well-local files (`WELL.md`, `index.md`, `log.md`, `pending-synthesis.md`). | yes — seeded once, never overwritten |

## Shared vs. per-well

| Shared (this repo) | Per-well (local, never overwritten) |
|---|---|
| `well-AGENTS.md`, `procedures/`, `shims/` | `WELL.md`, `source/`, `inbox/`, `wiki/`, `pending-synthesis.md` |

Edit the schema **here**, not inside a well — in-well copies are regenerated by `brunnr init`.

## License

[MIT](./LICENSE) © 2026 Olaf Grette

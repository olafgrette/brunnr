# brunnr

Agent-agnostic schema and operation playbooks for LLM-maintained knowledge wikis, based on Andrej Karpathy's [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) pattern. For my own personal use, but posted publicly. I don't expect anyone else to use this and defaults/evolution/improvements will be for explicitly my workflow.

A **well** is a directory with `source/` (immutable sources) and `wiki/` (LLM-maintained pages). This repo holds the shared brain — the schema (`well-AGENTS.md`), the operation playbooks (`procedures/`), and per-agent shims (`shims/`) — so you can run the same disciplined wiki workflow across many wells and machines without copy-paste drift.

## Install into a well

```sh
git clone https://github.com/<you>/brunnr ~/workspaces/brunnr
cd /path/to/your/well
~/workspaces/brunnr/bin/brunnr-init        # or: brunnr-init /path/to/well
```

`brunnr-init` installs the schema (`well-AGENTS.md`, placed as the well's `AGENTS.md`), `procedures/`, a `CLAUDE.md` mirror, and the Claude Code shims into the well, and seeds `WELL.md` + an empty `wiki/` skeleton on first run.

- **By default it symlinks**, so kit updates propagate live (`git pull` in the kit and every symlinked well is current).
- On filesystems that can't symlink (e.g. an **rclone Google Drive mount**) it **falls back to copying**; re-run `brunnr-init` after updating the kit to refresh copy-mode wells. The chosen mode is recorded in `.brunnr.toml` and reused on re-init — so a synced well stays consistent across machines — and you can override with `--symlink` / `--copy`.
- It stamps each well with `.brunnr.toml` and **refuses to overwrite a non-brunnr directory** (one with foreign files where it would install) unless you pass `--force`.
- It **never touches** `source/`, existing `wiki/` pages, or your `WELL.md`.

## Search (optional)

At small scale the playbooks just read `wiki/index.md` and the relevant pages. As a well grows, that stops scaling — so the playbooks can use [qmd](https://github.com/tobi/qmd), a local hybrid search engine (BM25 + vector + reranking over SQLite, models run on-device), to retrieve the right pages directly.

- **Install:** `bun install -g @tobilu/qmd` (or `npm install -g`; needs Node ≥22).
- **Register:** if `qmd` is on `PATH`, `brunnr-init` registers two collections per well — `<wellname>-wiki` (over `wiki/`) and `<wellname>-source` (over `source/`) — and records their names in `.brunnr.toml`. Registration only builds the keyword index; it downloads nothing.
- **Warm the models once:** `cd /path/to/well && qmd embed`. This pulls the embedding model (~300MB) and, on first semantic/hybrid query, the reranker + query-expansion models (~2GB total), cached under `~/.cache/qmd/`. **Run it in a real terminal** — the downloader is progress-bar driven and can stall under a non-interactive shell. After that, all operations are local and fast (a no-change refresh is ~150ms).
- **Opt out:** set `BRUNNR_NO_QMD=1` to make `brunnr-init` skip qmd entirely. Everything degrades gracefully to reading `index.md` when qmd isn't configured.
- **Synced wells:** the collection *names* travel with the well (in `.brunnr.toml`), but qmd's index lives in `~/.cache/qmd/` — machine-local, not synced. So set qmd up **per machine**: run `brunnr-init` + `qmd embed` on each. Names are derived from the well's directory, so they resolve identically everywhere. Don't try to share qmd's SQLite index through the sync mount.

The playbooks pick the command for the job: `qmd search` (keyword, no models) for the common path, `qmd vsearch` (semantic) to surface related ideas during ingest/lint, `qmd query` (hybrid+reranked) when a large well needs it. `index.md` stays the human-curated map; qmd is the machine retrieval index, not a replacement for it.

## Layout

| Path | Role | Into a well? |
|---|---|---|
| `AGENTS.md` | Guide for agents working **on brunnr** (this repo). | no |
| `well-AGENTS.md` | The schema that becomes each well's `AGENTS.md`/`CLAUDE.md`: layers, page conventions, division of labor, the operation dispatch table. Read by every agent (Codex natively; Claude Code via the `CLAUDE.md` mirror). | yes — refreshed every init |
| `procedures/{ingest,query,lint}.md` | Step-by-step playbooks. Agents read the relevant one *at the moment they act* — better adherence than burying the steps in always-on context. | yes — refreshed |
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

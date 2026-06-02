# Wiki Schema

This document defines how an LLM-maintained knowledge wiki is structured and how to operate it. It is **generic and shared across wells** (managed by [brunnr](./README.md)). **Read this before any operation — and read `WELL.md` for this well's scope and domain conventions.**

The idea (from Andrej Karpathy's "LLM Wiki"): the LLM incrementally builds a persistent, interlinked markdown knowledge base instead of re-deriving knowledge from sources on every query. The wiki compounds — cross-references already exist, contradictions are already flagged, the synthesis already reflects everything read.

## Directory structure

```
well/
├── source/           # Immutable source documents — read only, never modify
├── inbox/            # Staging area for new sources to ingest
├── wiki/             # LLM-maintained pages — you write this layer
│   ├── index.md      # Master catalog of all wiki pages
│   └── log.md        # Append-only operation log
├── procedures/       # Operation playbooks — read the relevant one before acting (from brunnr)
├── AGENTS.md         # This file — generic schema (from brunnr)
├── WELL.md           # This well's scope & domain notes (local; never from brunnr)
├── pending-synthesis.md  # Captured sources not yet woven into wiki/ (local worklist)
├── CLAUDE.md         # Mirror of AGENTS.md
├── .brunnr.toml      # Marks this as a brunnr well (managed by brunnr-init)
└── .claude/skills/   # Optional Claude Code shims (from brunnr)
```

## Layers

A source moves through three stages: **inbox/** (dropped, raw) → **ingest** (captured into `source/`) → **synthesize** (woven into `wiki/`). Capture is mechanical; synthesis is the human-steered step. The two are separate operations so you can batch-capture now and synthesize later.

**source/** — curated source material: notes, articles, exports, transcripts, images. Immutable, the source of truth. You read these, never modify them. Subdirectories are fine.

**inbox/** — where the user drops new sources to ingest. To ingest a markdown file: `cp` it to `source/`, `mv` the inbox file to `source/.orig/` (seeded by `init`), then fix the frontmatter on the `source/` copy.

**Source file format.** Save sources to `source/` as markdown, not binary or HTML. Use `markitdown` if available — it converts HTML, PDF, DOCX, PPTX, and images:

```bash
markitdown source.html > source.md
```

If `markitdown` isn't installed, tell the user and ask how to convert — don't guess at the content. After converting, **preserve the original**: move it to `source/.orig/`, never delete it (conversion is lossy). Every source needs YAML frontmatter:

```yaml
---
title: "Full Title of the Source"
authors: ["Author Name 1", "Author Name 2"]
source_type: paper | webpage | book | transcript | etc
publication: "Journal, Conference, or Publisher Name"
year: YYYY
volume: "Vol #"          # if applicable
issue: "Issue #"         # if applicable
pages: "Start-End"       # if applicable
doi: "10.xxxx/xxxx"      # if applicable
url: https://example.com/original-url
ingested_at: YYYY-MM-DD
---

# Article title

Article body...
```

**Pointer sources.** For large or fast-changing resources you shouldn't copy wholesale (code repos, live files), make a *pointer source*: a markdown file in `source/` holding a high-level snapshot or summary instead of verbatim content. Because it's deliberately not a verbatim copy, it's exempt from the "source must mirror its external content" rule — lint and ingest treat the snapshot as the source of truth, refreshed via `procedures/sync.md`. Required frontmatter tracks the external state:

```yaml
---
title: "Project Brunnr Codebase"
source_type: repository # or live_file
url: "https://github.com/olafgrette/brunnr" # if applicable
path: "/home/olaf/workspaces/brunnr"  # local path if applicable
tracked_commit: "a1b2c3d"             # git commit id at last sync (for a live_file, the commit of its repo — track by commit, never content hash)
ingested_at: YYYY-MM-DD               # first ingestion date; never changes
synced_at: YYYY-MM-DD                 # last sync date; equals ingested_at until the first sync
---

# Snapshot Summary

[High-level architectural/functional summary written during ingestion.]
```

**wiki/** — your output layer: summaries, entity pages, concept pages, comparisons, syntheses. The human reads it; the LLM writes it.

**AGENTS.md** (this file) — the generic schema. **Don't edit it inside a well** — changes are overwritten on the next `brunnr-init`. Edit it in the brunnr repo. Well-specific conventions go in `WELL.md`.

**WELL.md** — this well's domain: what it covers, its categories, any well-specific conventions. Local, never overwritten. Read it alongside this file.

**pending-synthesis.md** — a local worklist of sources ingested into `source/` but not yet synthesized into `wiki/`. Seeded by `brunnr init`, so it's always present. `ingest` appends a line per source; `synthesize` removes lines as it drains them. When nothing's pending it's just the header — leave it in place, don't delete it.

**Search layer ([qmd](https://github.com/tobi/qmd), optional)** — a local index over the well, used by the playbooks when they act. Setup is an agent-run step (`procedures/qmd-setup.md`), not part of `brunnr-init`, and is machine-local (set up once per machine). Don't call qmd directly — use `brunnr` from inside the well (it resolves which well from your directory):

- `brunnr search-enabled` — the gate every playbook checks. It prints a status line that says whether search is live and what to use; read that line rather than guessing from the exit code (a bare success used to look like silence). To turn search off for a well permanently, set `search = false` in its `.brunnr.toml`.
- `brunnr search-keyword|search-semantic|search-query [wiki|source|all] "<query>"` — keyword (BM25) / vector / hybrid+reranked. Target defaults to both collections.
- `brunnr search-refresh` — re-index + re-embed. A no-op if qmd isn't set up.

If `search-enabled` reports off, every playbook falls back to reading `index.md`. `index.md` stays the human-curated map; qmd finds the right pages at scale without reading the whole map. Refresh at write/audit time (after ingest/sync, before lint), not on every query.

## Page conventions

Every wiki page is a markdown file in `wiki/`:

- **Filename**: lowercase, hyphenated, descriptive — `nicotine-withdrawal.md`, `faye.md`.
- **Title**: H1 at the top, matching the concept or entity.
- **Summary**: 1–3 sentences right after the title.
- **Sections**: H2 for major sections — e.g. `## Background`, `## Key facts`, `## Timeline`, `## Open questions`, `## Sources`.
- **Cross-references**: link liberally with Obsidian wikilinks `[[page-name]]` or `[[page-name|alias]]`.
- **Semantic metadata**: for structured relationships use Dataview inline fields — `Partner:: [[faye]]`, `Member of:: [[tech-skeptics]]`.
- **Frontmatter**: every page MUST have:
  ```yaml
  ---
  tags: [category/subcategory]
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  type: entity | concept | synthesis | summary
  ---
  ```
- **Callouts**: `> [!INFO]`, `> [!QUOTE]`, `> [!WARNING]`, `> [!NOTE]`.

## Division of labor

The human curates sources, **directs the analysis**, and decides what matters. The LLM does the bookkeeping — reading, summarizing, cross-referencing, filing, keeping things consistent. **Bookkeeping is not editorial control.** Framing, emphasis, what to file where, how to classify a source, which contradictions matter — those are the human's calls. When an operation turns on one of them, **propose and wait; don't decide silently and execute.**

> [!WARNING] The failure mode to avoid
> Reading a source and autonomously writing a dozen pages before the human has steered. "The LLM does everything" means it does all the *work*, not that it makes all the *decisions*. When in doubt, surface the choice and **end your turn** — don't ask rhetorically and barrel on in the same turn.

**The conversation is content, not scaffolding.** Capture (`ingest`) is mechanical, but **synthesis** is an iterative dialogue — not a one-shot proposal. Start it by drawing out what the *human* took from the sources, before proposing any page structure: a page plan offered cold, with no idea what they made of the material, is the common failure. The discussion — their takeaways, the framing they choose, connections and disagreements — is part of the wiki's value. Fold it into the pages you write, and record notable direction or disagreement in a callout, an `## Open questions` section, or the log's `Notes:`. A synthesis should reflect the conversation that produced it. When a discussion produces something durable with no home, offer to file it as its own page.

## Operations

Each operation has a **playbook** in `procedures/`. **Read its playbook in full and follow it before acting — don't work from memory.**

| When the user… | Read & follow |
|---|---|
| adds a source to `inbox/` or `source/`, or says "ingest this" | `procedures/ingest.md` |
| says "synthesize", or asks to write up captured / pending sources | `procedures/synthesize.md` |
| asks to update an existing dynamic source (e.g. a repo) | `procedures/sync.md` |
| asks a question the wiki should answer | `procedures/query.md` |
| asks to health-check / audit / lint the wiki | `procedures/lint.md` |
| wants to enable/refresh local search, or set up a synced well on a new machine | `procedures/qmd-setup.md` |

## index.md format

The master catalog. Keep it current on every ingest.

```markdown
# Index

_Last updated: YYYY-MM-DD. N sources ingested._

## People
- [Name](./name.md) — one-line description

## Concepts
- [Concept](./concept.md) — one-line description

## Sources (summaries)
- [source-title](./source-title-summary.md) — one-line description

## Meta
- [Log](./log.md) — operation history
```

One-liners under 120 characters. Add categories as the wiki grows.

## log.md format

Append-only, newest at the bottom. Each entry starts with `## [YYYY-MM-DD] <operation> | <title>` so it stays greppable:

```bash
grep "^## \[" wiki/log.md | tail -10
```

## pending-synthesis.md format

A worklist at the well root, seeded by `brunnr init`, appended to by `ingest`, and drained by `synthesize` (which removes lines, never the file). One line per captured source:

```markdown
# Pending synthesis

Sources captured into source/ but not yet woven into wiki/. Run synthesize to process.

- [Title](./source/example.md) — ingested YYYY-MM-DD
```

## Notes

- The wiki is just markdown. In a git repo you get version history for free; in a synced folder (e.g. Google Drive) sync propagates across machines.
- Obsidian's graph view shows the wiki's shape — hubs, orphans, clusters.
- When unsure where something belongs, make a new wiki page rather than modifying a source.
- Good query answers are worth filing as pages — explorations should compound, not vanish into chat.

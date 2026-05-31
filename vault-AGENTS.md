# Wiki Schema

This document defines how an LLM-maintained knowledge wiki is structured and how to operate it. It is **generic and shared across vaults** (managed by [brunnr](./README.md)). **Read this before any operation on the wiki — and also read `VAULT.md` for this vault's specific scope and domain conventions.**

The pattern is based on Andrej Karpathy's "LLM Wiki" idea: the LLM incrementally builds and maintains a persistent, interlinked markdown knowledge base instead of re-deriving knowledge from raw sources on every query. The wiki is a compounding artifact — cross-references already exist, contradictions are already flagged, the synthesis already reflects everything read.

## Directory structure

```
vault/
├── raw/              # Immutable source documents — read only, never modify
├── wiki/             # LLM-maintained knowledge pages — you write this layer
│   ├── index.md      # Master catalog of all wiki pages
│   └── log.md        # Append-only operation log
├── procedures/       # Operation playbooks — read the relevant one before acting (from brunnr)
│   ├── ingest.md
│   ├── query.md
│   └── lint.md
├── AGENTS.md         # This file — generic schema (from brunnr)
├── VAULT.md          # This vault's scope & domain notes (local; never from brunnr)
├── CLAUDE.md         # Mirror of AGENTS.md (symlink, or copy where symlinks aren't supported)
├── .brunnr.toml      # Marks this as a brunnr vault + records install mode (managed by brunnr-init)
└── .claude/skills/   # Optional Claude Code shims that delegate to procedures/ (from brunnr)
```

## Layers

**raw/** — curated source material. Notes, articles, exports, transcripts, images. Immutable. You read these; you never modify them. This is the source of truth. Subdirectories are fine and mirror the original structure of sources.

**Raw file format convention**: When saving a source to `raw/`, prefer markdown over binary or HTML formats. Use `markitdown` if it's available — it handles HTML, PDF, DOCX, PPTX, images, and most common formats in one command. If it isn't installed, tell the user and ask how they'd like to convert (or to install it) rather than guessing at the content:

```bash
markitdown source.html > source.md   # or any other supported format
```

After conversion, **preserve the original** — move it into `raw/.orig/` rather than deleting it. Markdown conversion is lossy (it can strip images, mangle tables, or fail silently); the original is the immutable source of truth and the markdown is a readable rendering beside it. Always include a YAML frontmatter block with the following fields to support ACM-style citations and ingestion tracking:

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

This makes raw files readable by future agents doing wiki linting or ingestion without needing format-specific parsers.

**wiki/** — your output layer. Summaries, entity pages, concept pages, comparisons, syntheses. You write and maintain everything here. The human reads this layer; the LLM writes it.

**AGENTS.md** (this file) — the generic schema, shared across vaults via brunnr. **Don't edit it inside a vault** — your changes are overwritten on the next `brunnr-init`. Edit it in the brunnr repo instead. Vault-specific conventions belong in `VAULT.md`.

**VAULT.md** — this vault's domain: what it's about, its categories, any vault-specific conventions or scope notes. Local to the vault, never overwritten by brunnr. Read it alongside this file before any operation.

## Page conventions

Every wiki page is a markdown file in `wiki/`. Conventions:

- **Filename**: lowercase, hyphenated, descriptive. `nicotine-withdrawal.md`, `faye.md`, `house-electrical.md`.
- **Title**: H1 at the top, matching the concept or entity name.
- **Summary**: 1–3 sentences immediately after the title, before any sections.
- **Sections**: H2 for major sections. Common choices: `## Background`, `## Key facts`, `## Timeline`, `## Open questions`, `## Sources`.
- **Cross-references**: Use Obsidian wikilinks `[[page-name]]` or `[[page-name|alias]]` to link between wiki pages. Link liberally.
- **Semantic Metadata**: For structured relationships, use the Dataview `Key:: [[Link]]` format within the body. Example: `Partner:: [[faye]]`, `Member of:: [[tech-skeptics]]`.
- **Frontmatter**: Every wiki page MUST include a YAML frontmatter block (Obsidian Properties). Required fields:
  ```yaml
  ---
  tags: [category/subcategory]
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  type: entity | concept | synthesis | summary
  ---
  ```
- **Callouts**: Use Obsidian callout syntax for emphasis: `> [!INFO]`, `> [!QUOTE]`, `> [!WARNING]`, `> [!NOTE]`.

## Division of labor

The human curates sources, **directs the analysis**, and decides what matters. The LLM does the bookkeeping — reading, summarizing, cross-referencing, filing, maintaining consistency. **Doing the bookkeeping is not the same as making the editorial calls.** Framing, emphasis, what to file where, how to classify a source, which contradictions matter — these are the human's to direct. When an operation turns on one of those calls, **propose and wait; don't decide silently and execute.**

> [!WARNING] The default failure mode to avoid
> Reading a source and autonomously writing a dozen pages before the human has steered the analysis. "The LLM does everything" means the LLM does all the *work* — it does not mean the LLM makes all the *decisions*. When in doubt, surface the choice and **end your turn** to wait for a reply — don't pose the question rhetorically and barrel on in the same turn.

**The conversation is content, not scaffolding.** The discussion between the LLM and the human — the takeaways surfaced, the framing the human chooses, the connections and disagreements that come up — is itself a meaningful part of the wiki's value, not throwaway chat. Capture it: fold the human's framing and insights into the pages you write, and record notable direction, reasoning, or disagreement in the relevant page (a callout or an `## Open questions` section) or in the log's `Notes:`. A synthesis should reflect the conversation that produced it, not just the source text. When a discussion produces something durable that doesn't belong on an existing page, offer to file it as its own page.

## Operations

Each operation has a **playbook** in `procedures/`. **Before performing an operation, read its playbook in full and follow it — don't work from memory.** The playbooks reference the `index.md` and `log.md` formats below.

| When the user… | Read & follow |
|---|---|
| adds a source to `raw/`, or says "ingest this" | `procedures/ingest.md` |
| asks a question the wiki should answer | `procedures/query.md` |
| asks to health-check / audit / lint the wiki | `procedures/lint.md` |

## index.md format

The master catalog. Keep it current on every ingest. Structure:

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

One-liners should be under 120 characters. Add categories as the wiki grows.

## log.md format

Append-only. Newest entries at the bottom. Each entry starts with `## [YYYY-MM-DD] <operation> | <title>`. This makes it greppable:

```bash
grep "^## \[" wiki/log.md | tail -10
```

## Notes

- The wiki is just markdown files. Where the vault is a git repo, you get version history and branching for free; where it's a synced folder (e.g. Google Drive), sync handles propagation across machines.
- Obsidian's graph view is the best way to see the shape of the wiki — hubs, orphans, clusters.
- When in doubt about where something belongs, create a new wiki page rather than modifying a raw source.
- Good answers to queries are worth filing as wiki pages — explorations should compound, not disappear into chat history.

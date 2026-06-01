---
name: wiki-ingest
description: Capture a new source into this knowledge well. Use when the user adds a document to inbox/ or source/, points at a source, or says "ingest this". Converts the source to markdown, files it in source/ with frontmatter, and queues it in pending-synthesis.md. Mechanical capture only — writing wiki pages happens later via wiki-synthesize.
---

Read `procedures/ingest.md` at the well root and follow it exactly.

Ingest is **mechanical**: file the source(s) into `source/` and queue them in `pending-synthesis.md`. Write no `wiki/` pages and don't start synthesizing — that's the separate, human-steered `wiki-synthesize` skill. You can capture several sources in one pass.

If you haven't already this session, read `AGENTS.md` and `WELL.md` at the well root first for the schema and this well's domain scope.

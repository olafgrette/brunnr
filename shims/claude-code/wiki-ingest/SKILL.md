---
name: wiki-ingest
description: Ingest a new source into this knowledge well's wiki. Use when the user adds a document to source/, points at an existing source, or says "ingest this". Reads the source, proposes a page plan, and—only after the user steers—writes summary/entity/concept pages, updates the index, and logs the operation.
---

Read `procedures/ingest.md` at the well root and follow it exactly.

Critical: it has a **hard-stop checkpoint** — after reading the source you present takeaways and a proposed page plan, then **wait for the user's direction before writing any file in `wiki/`**. Do not skip this.

If you haven't already this session, read `AGENTS.md` and `WELL.md` at the well root first for the schema and this well's domain scope.

---
name: wiki-ingest
description: Ingest a new source into this knowledge vault's wiki. Use when the user adds a document to raw/, points at an existing source, or says "ingest this". Reads the source, proposes a page plan, and—only after the user steers—writes summary/entity/concept pages, updates the index, and logs the operation.
---

Read `procedures/ingest.md` at the vault root and follow it exactly.

Critical: it has a **hard-stop checkpoint** — after reading the source you present takeaways and a proposed page plan, then **wait for the user's direction before writing any file in `wiki/`**. Do not skip this.

If you haven't already this session, read `AGENTS.md` and `VAULT.md` at the vault root first for the schema and this vault's domain scope.

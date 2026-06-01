---
name: wiki-synthesize
description: Weave captured sources into this knowledge well's wiki. Use when the user says "synthesize", "write up the pending sources", or names ingested sources to process. Reads the pending sources, discusses takeaways and connections with the user, and—only after the user steers—writes summary/entity/concept pages, updates the index, drains pending-synthesis.md, and logs the operation.
---

Read `procedures/synthesize.md` at the well root and follow it exactly.

Critical: this is the **human-steered, conversational** step. It has a **hard-stop checkpoint** — present takeaways, connections, and a proposed page plan, then **wait for the user's direction before writing any file in `wiki/`**. Expect a back-and-forth: the human steers framing and surfaces connections, and that discussion is itself content to fold into the pages. Do not skip the checkpoint.

If you haven't already this session, read `AGENTS.md` and `WELL.md` at the well root first for the schema and this well's domain scope.

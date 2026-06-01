# Procedure: Ingest

Read before capturing a source. Ingest is **mechanical**: it lands the source in `source/` and queues it for synthesis — it writes no wiki pages and needs no steering. The analysis happens later in `procedures/synthesize.md`.

Triggered when the user adds a source to `inbox/` or `source/`, or says "ingest this". You can capture several sources in one pass.

## Steps

1. **Get each source into `source/` as markdown:**
   - **From `inbox/` (already markdown):** `cp` it to `source/`, `mv` the inbox file to `source/.orig/`, then fix the frontmatter on the `source/` copy.
   - **Other static sources:** convert to markdown (prefer `markitdown`; if it's missing, ask the user — don't improvise), add the source frontmatter from `AGENTS.md`, and **move the original to `source/.orig/`** — never delete it.
   - **Repos / live files:** make a **pointer source** in `source/` — explore the resource (tree, READMEs, structure) and write an architectural/functional snapshot into the body, with the pointer frontmatter from `AGENTS.md` (including `tracked_commit`). The snapshot *is* the source's content, so writing it is part of capture.

2. **Queue each source for synthesis.** Append a line to `pending-synthesis.md` at the well root (seeded by `init`; format in `AGENTS.md`):
   ```
   - [Title](./source/<file>.md) — ingested YYYY-MM-DD
   ```

3. **Refresh the search index** (if qmd is set up): follow `procedures/qmd-update.md` so the new sources are searchable during synthesis. Skip if qmd isn't configured.

4. Append to `wiki/log.md`, one entry per source:
   ```
   ## [YYYY-MM-DD] ingest | <source title or filename>
   Captured: source/<file>.md
   ```

5. **Report** what you captured and that it's queued — e.g. "Ingested 3 sources into `source/` and queued them in `pending-synthesis.md`. Run synthesize when you're ready to weave them in."

No page plan, no wiki writes, no checkpoint here — that's `synthesize`. Don't start synthesizing in the same turn unless the user asks.

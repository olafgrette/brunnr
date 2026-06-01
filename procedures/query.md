# Procedure: Query

Read this before answering a question against the wiki. References the `log.md` format in `AGENTS.md`.

Triggered when the user asks a question the wiki should be able to answer.

## Steps

1. **Find the relevant pages.**
   - **If qmd is set up for this well** (`qmd collection list` shows `<wellname>-wiki`; see `procedures/qmd-setup.md`), search it instead of scanning `index.md` by hand. The index is refreshed at write time (ingest/sync) and before lint, so **query doesn't re-index** — just search:
     - Retrieve candidates: `qmd search "<question>" -c <wellname>-wiki -n 8` — BM25, no models, instant. This is the default and enough for most wells.
     - For paraphrase/semantic recall, escalate to `qmd vsearch` (embedding model) or the hybrid `qmd query` (adds the reranker + query-expansion models). Setup warms all of these, so they're available without a download mid-answer.
     - If results look stale — you know a recent ingest landed pages that aren't showing — refresh once via `procedures/qmd-update.md`, then re-search.
   - **Otherwise** read `wiki/index.md` and pick the most relevant pages from the map.
2. Read the selected pages in full. (qmd returns excerpts; the wiki page is the source of truth — read it, don't answer from the snippet.)
3. Synthesize an answer with **inline citations** to wiki pages (`[[page]]`) and sources.
4. If the answer is a **durable artifact** (analysis, comparison, synthesis, a connection you discovered), offer to save it as a new wiki page — explorations should compound, not disappear into chat. The discussion itself is part of the wiki's value (see Division of labor in `AGENTS.md`).
5. If you save a page, append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] query | <question summary>
   Pages read: ...
   Page created: <path> (if applicable)
   ```

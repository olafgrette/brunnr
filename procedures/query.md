# Procedure: Query

Read this before answering a question against the wiki. References the `log.md` format in `AGENTS.md`.

Triggered when the user asks a question the wiki should be able to answer.

## Steps

1. **Find the relevant pages.**
   - **If qmd is configured for this well** (collection names recorded in `.brunnr.toml`; confirm with `qmd collection list`), refresh the index and search instead of scanning `index.md` by hand:
     - Refresh: `qmd update` re-indexes changed files (~150ms when nothing changed). Add `qmd embed -c <wiki-collection>` only if you'll use vector or hybrid search.
     - Retrieve candidates: `qmd search "<question>" -c <wiki-collection> -n 8` — BM25, no models, instant. This is the default and is enough for most wells.
     - For paraphrase/semantic recall, escalate to `qmd vsearch` (needs the local embedding model) or the hybrid `qmd query` (also pulls the reranker + query-expansion models — a one-time ~2GB download). If those models aren't warmed yet, **fall back to `qmd search`** rather than triggering a multi-minute download mid-answer.
     - The wiki collection defaults to `<wellname>-wiki` and is recorded in `.brunnr.toml`.
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

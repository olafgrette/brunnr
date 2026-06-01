# Procedure: Query

Read before answering a question against the wiki. Uses the `log.md` format in `AGENTS.md`.

Triggered when the user asks a question the wiki should answer.

## Steps

1. **Find the relevant pages.**
   - **If `brunnr search-enabled`**, search instead of scanning `index.md` by hand. The index is already current (refreshed at write time), so don't re-index — just search:
     - `brunnr search-keyword wiki "<question>"` — BM25, instant. The default, enough for most wells.
     - For paraphrase/semantic recall: `brunnr search-semantic "<question>"`, or hybrid `brunnr search-query "<question>"` (slower, reranked).
   - **Otherwise** read `wiki/index.md` and pick the most relevant pages.
2. Read the selected pages in full. qmd returns excerpts; the page is the source of truth — don't answer from the snippet.
3. Synthesize an answer with **inline citations** to wiki pages (`[[page]]`) and sources.
4. If the answer is a **durable artifact** (analysis, comparison, synthesis, a connection you found), offer to save it — explorations should compound, not disappear into chat. A self-contained answer can be saved as a single new page here. But when the insight spans or revises several pages — or the session became a real back-and-forth — hand off to `procedures/synthesize.md` instead: it weaves session-derived material into the wiki with the steering dialogue that change warrants.
5. If you save a page, append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] query | <question summary>
   Pages read: ...
   Page created: <path> (if applicable)
   ```

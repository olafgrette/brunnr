# Procedure: Query

Read this before answering a question against the wiki. References the `log.md` format in `AGENTS.md`.

Triggered when the user asks a question the wiki should be able to answer.

## Steps

1. Read `wiki/index.md` to find the most relevant pages. (At larger scale, use the wiki search tool if one is configured.)
2. Read those pages in full.
3. Synthesize an answer with **inline citations** to wiki pages (`[[page]]`) and sources.
4. If the answer is a **durable artifact** (analysis, comparison, synthesis, a connection you discovered), offer to save it as a new wiki page — explorations should compound, not disappear into chat. The discussion itself is part of the wiki's value (see Division of labor in `AGENTS.md`).
5. If you save a page, append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] query | <question summary>
   Pages read: ...
   Page created: <path> (if applicable)
   ```

# Procedure: qmd update (refresh the search index)

A shared sub-step for the other playbooks — not a standalone operation. Run this wherever a playbook says "refresh qmd."

**Skip entirely if qmd isn't set up for this well** (`qmd collection list` doesn't show `<wellname>-wiki`; see `procedures/qmd-setup.md`). Everything still works reading `wiki/index.md`.

The playbooks refresh **at write and audit time** — after ingest/sync write pages, and before a lint reads them — not on every query. A no-change `qmd update` is ~150ms, but re-indexing a batch of new or edited pages (and re-embedding them) can take noticeably longer, so the cost belongs where content changes, not on the read path.

## Steps

1. **Re-index changed files (keyword/FTS).** From the well root: `qmd update`. It re-indexes only what changed and is what `qmd search` (BM25) reads.

2. **Refresh vectors.** `qmd embed` (re-embeds only changed docs). `qmd update` does not regenerate the embeddings that `qmd vsearch` and `qmd query` read, and setup always warms the models (`qmd-setup.md` step 4), so this runs every time — otherwise semantic/hybrid search would silently miss the pages you just changed.

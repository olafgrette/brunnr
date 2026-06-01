# Procedure: qmd update (refresh the search index)

A shared sub-step for the other playbooks — not a standalone operation. Run this wherever a playbook says "refresh qmd."

**Run `brunnr search-refresh` from the well root.** It re-indexes changed files (keyword/FTS) and re-embeds changed docs (vectors), and is a silent no-op if qmd isn't set up for this well — so you can call it unconditionally. Everything still works reading `wiki/index.md` when qmd isn't configured.

The playbooks refresh **at write and audit time** — after ingest/sync write pages, and before a lint reads them — not on every query. A no-change refresh is fast; re-indexing and re-embedding a batch of new or edited pages costs more, so the cost belongs where content changes, not on the read path.

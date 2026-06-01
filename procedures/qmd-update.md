# Procedure: qmd update (refresh the search index)

A shared sub-step for the other playbooks, not a standalone operation. Run wherever a playbook says "refresh qmd."

**Run `brunnr search-refresh` from the well root.** It re-indexes changed files and re-embeds changed docs, and is a silent no-op if qmd isn't set up — so call it unconditionally.

Refresh **at write and audit time** — after ingest/sync write pages, and before lint reads them — not on every query. The cost belongs where content changes, not on the read path.

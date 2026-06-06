# Procedure: Lint

Read before health-checking the wiki. Uses the `log.md` format in `AGENTS.md`.

Triggered when the user asks to health-check, audit, or lint the wiki.

## Steps

1. Read `wiki/index.md` and all wiki pages. Skip `wiki/log.md` — it's an append-only log, not content.
2. **Flag**: contradictions between pages, stale claims newer sources have superseded, orphan pages (no inbound links), missing cross-references, important concepts lacking their own page, gaps a web search could fill.
   - **If `brunnr enabled`**, **refresh first** via `procedures/qmd-update.md`, then use it to catch what manual reading misses: `brunnr semantic wiki "<page themes>"` for pages semantically close but not cross-linked, and `brunnr semantic source "<page themes>"` for source material no wiki page reflects yet.
3. **Suggest** new questions to investigate or sources to find.
4. Discuss findings before sweeping fixes (Division of labor, `AGENTS.md`). Apply the uncontroversial corrections; propose the rest and wait. For a flagged contradiction the human hasn't steered, **record both views** in a `> [!WARNING]` callout — don't silently pick a winner.
5. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] lint
   Issues found: ...
   Issues resolved: ...
   ```

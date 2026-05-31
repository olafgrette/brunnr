# Procedure: Lint

Read this before health-checking the wiki. References the `log.md` format in `AGENTS.md`.

Triggered when the user asks to health-check, audit, or lint the wiki.

## Steps

1. Read `wiki/index.md` and all wiki pages.
2. **Flag**: contradictions between pages, stale claims that newer sources have superseded, orphan pages (no inbound links), missing cross-references, important concepts mentioned but lacking their own page, data gaps a web search could fill.
3. **Suggest** new questions to investigate or new sources to look for.
4. Discuss findings with the user before making sweeping fixes (see Division of labor in `AGENTS.md`). Apply the uncontroversial corrections; propose the rest and wait.
5. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] lint
   Issues found: ...
   Issues resolved: ...
   ```

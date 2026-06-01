# Procedure: qmd setup (optional local search)

Read this when the user wants to **enable or refresh** the local [qmd](https://github.com/tobi/qmd) search layer for this well. qmd is optional — every other playbook falls back to reading `wiki/index.md` when qmd isn't set up. See the **Search layer** note in `AGENTS.md` for what qmd is and why.

qmd's index and these settings live under `~/.cache/qmd/` — **machine-local, not synced**. So run this procedure **once per machine** for a given well (a synced well needs it on each machine you work from). Collection names derive from the well's directory name, so they resolve identically everywhere.

Triggered when the user says "set up qmd", "enable search", or after cloning a synced well onto a new machine.

## Steps

1. **Check qmd is installed.** `command -v qmd`. If it's missing, tell the user how and stop — don't improvise an install:
   `bun install -g @tobilu/qmd` (or `npm install -g @tobilu/qmd`; needs Node ≥22). Then re-run this procedure.

2. **Register the two collections** (idempotent — skip either that `qmd collection list` already shows). Run from the well root, with `<WELL>` = the well's directory name (`basename "$PWD"`):
   - `qmd collection add ./wiki   --name <WELL>-wiki`
   - `qmd collection add ./source --name <WELL>-source`

   Registration builds only the keyword (BM25) index; it downloads no models, so it's fast and can't hang.

3. **Attach a short description to each collection.** This is qmd's most useful feature: the description is returned alongside every search hit, so an agent — here or searching across another well — knows what it's looking at. Use this well's one-line summary: the sentence(s) under the `# This well` heading in `WELL.md`, **condensed to a single line** (collapse any line breaks — a newline in the context value mangles storage and display). Set it as context on both collections (re-running overwrites, so this stays current if `WELL.md` changed):
   - `qmd context add qmd://<WELL>-wiki   "<summary> — LLM-maintained wiki pages"`
   - `qmd context add qmd://<WELL>-source "<summary> — immutable source documents"`

   **If `WELL.md` is still the unedited template** (the summary line is the italic placeholder, `_One or two sentences…_`), stop and ask the user to fill it in first — don't index placeholder text.

4. **Warm the models.** This is required, not optional — a well is set up only once its embeddings exist, so semantic (`qmd vsearch`) and hybrid (`qmd query`) search work, not just keyword. Run `qmd embed` — a one-time download (~300MB embedding model; the reranker + query-expansion models pull on first hybrid query, ~2GB total) cached under `~/.cache/qmd/`. **Run it in a real terminal**: the downloader is progress-bar driven and can stall under a non-interactive shell. If you're not in one, hand this command to the user to run and wait for them before continuing.

5. **Verify and report.** `qmd collection list` and `qmd context list` should show both collections and their descriptions; a quick `qmd vsearch "<a topic the well covers>"` confirms embeddings are live. Tell the user search is set up — keyword, semantic, and hybrid all available.

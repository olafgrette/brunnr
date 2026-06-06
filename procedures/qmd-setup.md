# Procedure: qmd setup (optional local search)

Read this to **enable or refresh** the local [qmd](https://github.com/tobi/qmd) search layer for this well. qmd is optional — every other playbook falls back to reading `wiki/index.md` without it. See the **Search layer** note in `AGENTS.md`.

qmd's index and models live under `~/.cache/qmd/` — **machine-local, not synced**. Run this **once per machine** for a well. Collection names derive from the well's directory name, so they resolve identically everywhere.

Triggered when the user says "set up qmd" / "enable search", or after cloning a synced well onto a new machine.

## Steps

1. **Check qmd is installed:** `command -v qmd`. If missing, tell the user how and stop — don't improvise:
   `bun install -g @tobilu/qmd` (or `npm install -g @tobilu/qmd`; needs Node ≥22). Then re-run.

2. **Register the two collections** (idempotent — skip either that `qmd collection list` already shows). From the well root, with `<WELL>` = `basename "$PWD"`:
   - `qmd collection add ./wiki   --name <WELL>-wiki`
   - `qmd collection add ./source --name <WELL>-source`

   This builds only the keyword index — no model download, so it's fast.

3. **Attach a one-line description to each collection.** qmd returns it alongside every hit, so an agent knows what it found. Use the well's summary — the sentence(s) under `# This well` in `WELL.md`, **collapsed to a single line** (a newline here corrupts storage). Re-running overwrites, keeping it current:
   - `qmd context add qmd://<WELL>-wiki   "<summary> — LLM-maintained wiki pages"`
   - `qmd context add qmd://<WELL>-source "<summary> — immutable source documents"`

   **If `WELL.md` is still the unedited template** (the summary is the italic `_One or two sentences…_` placeholder), stop and ask the user to fill it in first — don't index placeholder text.

4. **Warm the models.** Required — semantic and hybrid search need embeddings, not just keyword. Run `qmd embed` (a one-time model download). **Run it in a real terminal**: the downloader is progress-bar driven and can stall otherwise. If you're not in one, hand the command to the user and wait.

5. **Verify and report.** `brunnr enabled` should exit 0, and `qmd context list` should show both descriptions. A quick `brunnr semantic "<a topic the well covers>"` confirms hits come back. Tell the user search is set up.

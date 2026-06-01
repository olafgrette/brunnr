---
name: qmd-setup
description: Set up or refresh this well's optional local qmd search layer. Use when the user says "set up qmd", "enable search", or after cloning a synced well onto a new machine. Registers the wiki/source collections, attaches the well's description to each, and warms the search models. qmd is machine-local, so this runs once per machine.
---

Read `procedures/qmd-setup.md` at the well root and follow it exactly.

qmd is optional — if the user doesn't want a local search index, every other operation falls back to reading `wiki/index.md`. The qmd index is machine-local and not synced, so this procedure is run once per machine per well.

If you haven't already this session, read `AGENTS.md` and `WELL.md` at the well root first — step 3 needs the well's one-line summary from `WELL.md`.

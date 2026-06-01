# Procedure: Ingest

Read this before ingesting a source. It enforces the **Division of labor** principle in `AGENTS.md`, and references the `index.md` / `log.md` formats defined there.

Triggered when the user adds a new source to `inbox/` or `source/`, or points you at an existing one.

## Steps

1. **Read** the source document fully. 
   - **From `inbox/`**: if it's already a markdown file, it's most efficient to use bash to `mv` the file to `source/.orig/` and `cp` it to `source/`, then edit the `source/` copy to ensure the frontmatter is correct and well-formatted.
   - **Static Sources**: If it isn't already in `source/` as markdown, convert it first (prefer `markitdown` if it's installed — otherwise ask the user rather than improvising), add the source frontmatter described in `AGENTS.md`, and **move the original into `source/.orig/`** — never delete it (conversion is lossy; the original is the source of truth).
   - **Dynamic/Large Sources (e.g., Repositories, live files):** Do not copy the entire resource. Instead, create a **Pointer Source** in `source/` (e.g., `source/my-repo.md`). Perform a high-level analysis of the external resource (using tree, reading readmes, or exploring structure) to generate an architectural/functional or structural snapshot. Populate the file with the required Pointer frontmatter (including `tracked_commit` — a git commit id; for a live file, the commit id of the repo it lives in) and write the snapshot into the body.

   - **Check for overlap and related ideas first (if qmd is set up):** before proposing, search both collections so your plan connects to what's already here instead of duplicating it. Use `qmd search "<key terms>"` for exact-topic hits and **`qmd vsearch "<themes/claims>"` for semantically related ideas that share no keywords** — the latter is what surfaces connections worth drawing in the new pages. Run both against `-c <wellname>-wiki` and `-c <wellname>-source`. (Detect qmd with `qmd collection list`; see `procedures/qmd-setup.md`.)

2. **Stop, propose, and yield the turn — write nothing yet.** Present to the user:
   - the **key takeaways** from the source;
   - a **proposed page plan**: which wiki pages you'd create, which existing pages you'd update, and the angle/emphasis you intend to take on each;
   - any **contradictions** with existing pages, and any **judgment calls** (classification, framing, where something belongs) you would otherwise make silently.

   Then **end your turn and wait.** Do not proceed to step 3, and do not call any file-writing tool (Write/Edit/etc.) in the same turn — yield back to the user and wait for their reply. Treat silence or an off-topic reply as a hard stop, never as approval. This is the user's one chance to steer the analysis before a large set of edits lands — see Division of labor in `AGENTS.md`.

3. Once the user has given direction, **write**:
   - a **summary page** for the source;
   - the **entity and concept pages** the source touches — create new pages for entities that don't have one yet, update existing ones;
   - `wiki/index.md` — add new pages, update one-liners for modified ones.

   Fold the user's framing and any insights from the discussion into the pages — the conversation is content, not scaffolding (see `AGENTS.md`). Record notable direction or disagreement in a callout, an `## Open questions` section, or the log `Notes:`.

4. **Refresh the search index** (if qmd is set up): follow `procedures/qmd-update.md` so the pages you just wrote are searchable for the next query. Skip if qmd isn't configured.

5. Append an entry to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] ingest | <source title or filename>
   Pages created: ...
   Pages updated: ...
   Notes: ...
   ```

6. **Summarize** what changed and surface any judgment calls you ended up making.

A single source might touch 5–15 wiki pages. That's expected — which is exactly why the step-2 checkpoint matters.

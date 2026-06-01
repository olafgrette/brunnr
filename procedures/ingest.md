# Procedure: Ingest

Read before ingesting a source. Enforces **Division of labor** in `AGENTS.md`; uses the `index.md` / `log.md` formats defined there.

Triggered when the user adds a source to `inbox/` or `source/`, or points you at one.

## Steps

1. **Read the source fully**, and get it into `source/` as markdown:
   - **From `inbox/` (already markdown):** `cp` it to `source/`, `mv` the inbox file to `source/.orig/`, then fix the frontmatter on the `source/` copy.
   - **Other static sources:** convert to markdown (prefer `markitdown`; if it's missing, ask the user — don't improvise), add the source frontmatter from `AGENTS.md`, and **move the original to `source/.orig/`** — never delete it.
   - **Repos / live files:** don't copy the whole thing. Make a **pointer source** in `source/` — explore the resource (tree, READMEs, structure) and write an architectural/functional snapshot into the body, with the pointer frontmatter from `AGENTS.md` (including `tracked_commit`).
   - **Check for overlap first** (if `brunnr search-enabled`): `brunnr search-keyword "<key terms>"` for exact hits, `brunnr search-semantic "<themes/claims>"` for related ideas that share no keywords. Connect your plan to what's already here instead of duplicating it.

2. **Stop, propose, and yield the turn — write nothing yet.** Present:
   - the **key takeaways** from the source;
   - a **page plan**: which pages you'd create, which you'd update, and the angle on each;
   - any **contradictions** with existing pages and any **judgment calls** (classification, framing, placement).

   Then **end your turn and wait.** Don't proceed to step 3, and don't call any file-writing tool in the same turn. Treat silence or an off-topic reply as a hard stop, never approval. This is the user's one chance to steer before a large set of edits lands.

3. Once the user has given direction, **write**:
   - a **summary page** for the source;
   - the **entity and concept pages** it touches — new ones where missing, updates where they exist;
   - `wiki/index.md` — add new pages, refresh one-liners for changed ones.

   Fold the user's framing and any insights from the discussion into the pages. Record notable direction or disagreement in a callout, an `## Open questions` section, or the log `Notes:`.

4. **Refresh the search index** (if qmd is set up): follow `procedures/qmd-update.md` so the new pages are searchable. Skip if qmd isn't configured.

5. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] ingest | <source title or filename>
   Pages created: ...
   Pages updated: ...
   Notes: ...
   ```

6. **Summarize** what changed and surface any judgment calls you made.

A single source might touch 5–15 pages. That's expected — which is why the step-2 checkpoint matters.

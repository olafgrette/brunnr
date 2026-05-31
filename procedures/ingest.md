# Procedure: Ingest

Read this before ingesting a source. It enforces the **Division of labor** principle in `AGENTS.md`, and references the `index.md` / `log.md` formats defined there.

Triggered when the user adds a new source to `raw/` or points you at an existing one.

## Steps

1. **Read** the source document fully. If it isn't already in `raw/` as markdown, convert it first (prefer `markitdown`), add the source frontmatter described in `AGENTS.md`, and delete the original non-markdown file.

2. **Stop and propose — write nothing yet.** Present to the user:
   - the **key takeaways** from the source;
   - a **proposed page plan**: which wiki pages you'd create, which existing pages you'd update, and the angle/emphasis you intend to take on each;
   - any **contradictions** with existing pages, and any **judgment calls** (classification, framing, where something belongs) you would otherwise make silently.

   Then **wait** for the user's direction. **Do not create or modify any file in `wiki/` until they respond.** This is the user's one chance to steer the analysis before a large set of edits lands — see Division of labor in `AGENTS.md`.

3. Once the user has given direction, **write**:
   - a **summary page** for the source;
   - the **entity and concept pages** the source touches — create new pages for entities that don't have one yet, update existing ones;
   - `wiki/index.md` — add new pages, update one-liners for modified ones.

   Fold the user's framing and any insights from the discussion into the pages — the conversation is content, not scaffolding (see `AGENTS.md`). Record notable direction or disagreement in a callout, an `## Open questions` section, or the log `Notes:`.

4. Append an entry to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] ingest | <source title or filename>
   Pages created: ...
   Pages updated: ...
   Notes: ...
   ```

5. **Summarize** what changed and surface any judgment calls you ended up making.

A single source might touch 5–15 wiki pages. That's expected — which is exactly why the step-2 checkpoint matters.

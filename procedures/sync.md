# Procedure: Sync

Read this before updating a dynamic/pointer source that is already ingested into the wiki. It enforces the **Division of labor** principle in `AGENTS.md`, and references the `index.md` / `log.md` formats defined there.

Triggered when the user asks to update or sync an existing dynamic source (e.g., a codebase repository or live file) that has a Pointer Source in `source/`.

## Steps

1. **Diff the Source:** 
   - Read the frontmatter of the target Pointer Source in `source/` to find its current path/URL and the `tracked_commit`.
   - Inspect the live, external resource to determine its current state — the current `HEAD` commit id of the repo (for a `live_file`, the commit id of the repo it lives in). Always track by commit id, never by content hash.
   - Generate a diff or summarize the changelog between the `tracked_commit` and the current commit.
   - Formulate an updated architectural/functional snapshot or summary based on these changes.

2. **Stop, propose, and yield the turn — write nothing yet.** Present to the user:
   - the **key changes** detected in the dynamic source since the last sync;
   - a **proposed page plan**: which downstream wiki pages you'd update, which new pages might be needed, and how the sync affects existing concepts;
   - any **contradictions** or architectural/functional shifts introduced by the sync.

   Then **end your turn and wait.** Do not proceed to step 3, and do not call any file-writing tool in the same turn. Treat silence or an off-topic reply as a hard stop.

3. Once the user has given direction, **write**:
   - **Update the Pointer Source:** Modify the body of the Pointer Source in `source/` to reflect the new snapshot/summary, update the `tracked_commit` in the frontmatter to the new commit id, and set `synced_at` to today.
   - **Update Wiki Pages:** Modify the entity and concept pages in `wiki/` affected by the changes.
   - `wiki/index.md` — add new pages, update one-liners for modified ones if applicable.

4. Append an entry to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] sync | <source title or filename>
   Pages updated: ...
   Notes: Synced from commit <old> to <new>. <brief notes>
   ```

5. **Summarize** what changed and surface any judgment calls you ended up making.

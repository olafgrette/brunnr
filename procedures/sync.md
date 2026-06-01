# Procedure: Sync

Read before updating a pointer source already ingested into the wiki. Enforces **Division of labor** in `AGENTS.md`; uses the `index.md` / `log.md` formats defined there.

Triggered when the user asks to update or sync a dynamic source (a repo or live file) that has a pointer source in `source/`.

## Steps

1. **Diff the source:**
   - Read the pointer source's frontmatter for its path/URL and `tracked_commit`.
   - Inspect the live resource for its current `HEAD` commit (for a `live_file`, the commit of its repo). Track by commit id, never content hash.
   - Diff or summarize the changelog from `tracked_commit` to the current commit, and draft an updated snapshot from those changes.

2. **Stop, propose, and yield the turn — write nothing yet.** Present:
   - the **key changes** since the last sync;
   - a **page plan**: which wiki pages you'd update, which new ones might be needed, how the sync affects existing concepts;
   - any **contradictions** or shifts the sync introduces.

   Then **end your turn and wait.** Don't proceed to step 3, and don't call any file-writing tool in the same turn. Treat silence or an off-topic reply as a hard stop.

3. Once the user has given direction, **write**:
   - **Pointer source:** update the body with the new snapshot, set `tracked_commit` to the new commit and `synced_at` to today.
   - **Wiki pages:** update the entity and concept pages the changes affect.
   - `wiki/index.md` — add new pages, refresh one-liners as needed.

4. **Refresh the search index** (if qmd is set up): follow `procedures/qmd-update.md`. Skip if qmd isn't configured.

5. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] sync | <source title or filename>
   Pages updated: ...
   Notes: Synced from commit <old> to <new>. <brief notes>
   ```

6. **Summarize** what changed and surface any judgment calls you made.

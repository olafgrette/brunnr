---
name: wiki-sync
description: Sync/update a dynamic 'Pointer Source' (like a code repository) that is already in the wiki. Use when the user asks to update a live source. Diffs the live state against the tracked commit, proposes updates to wiki pages, and—after user approval—applies the changes and logs the sync.
---

Read `procedures/sync.md` at the well root and follow it exactly.

Critical: it has a **hard-stop checkpoint** — after analyzing the diff and the updated live state, you present takeaways and a proposed page plan, then **wait for the user's direction before writing any file in `wiki/` or updating the pointer source**. Do not skip this.

If you haven't already this session, read `AGENTS.md` and `WELL.md` at the well root first for the schema and this well's domain scope.

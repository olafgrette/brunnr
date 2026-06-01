# Procedure: Synthesize

Read before weaving new material — captured sources or a query/discussion — into the wiki. This is the **human-steered, conversational** step (the counterpart to mechanical `ingest`): takeaways are surfaced, framing is chosen together, and connections get drawn. Enforces **Division of labor** in `AGENTS.md`; uses the `index.md` / `log.md` formats defined there.

Triggered when the user says "synthesize", "write up the pending sources", or names captured sources to process — **or after a query/discussion session**, to fold the durable insight it produced into the wiki. The material comes from `pending-synthesis.md` (sources captured by `ingest`), the current conversation, or both.

## Steps

1. **Pick the target set** — one or both of:
   - **Pending sources:** default to everything in `pending-synthesis.md`; if the user named specific sources, process just those. Read those source files in full.
   - **The current session:** when synthesizing after a query or discussion, the takeaways, connections, and framing from this conversation *are* the material. `pending-synthesis.md` may be empty or absent then — that's expected, not a no-op. Don't re-derive what the conversation already produced; weave it in.

2. **Find what's already here.** If `brunnr search-enabled`: `brunnr search-keyword "<key terms>"` for exact hits, `brunnr search-semantic "<themes/claims>"` for related ideas that share no keywords. Otherwise read `wiki/index.md`. The goal is to connect the new material to existing pages, not duplicate them.

3. **Discuss — this is the heart of the operation, and it's a back-and-forth, not a one-shot proposal.** Present:
   - the **key takeaways** across the sources;
   - the **connections** you see — between the sources and to existing wiki pages — and any contradictions;
   - a **proposed page plan**: which pages you'd create, which you'd update, and the angle on each;
   - the **judgment calls** (classification, framing, placement) you'd otherwise make silently.

   Then **end your turn and wait.** Expect several exchanges: the human steers framing and emphasis, surfaces their own connections, and pushes back — that dialogue is itself content. Write **nothing** in `wiki/` until the human has steered. Treat silence or an off-topic reply as a hard stop, never approval.

4. Once the user has given direction, **write**:
   - a **summary page** for each source;
   - the **entity and concept pages** the sources touch — new ones where missing, updates where they exist;
   - `wiki/index.md` — add new pages, refresh one-liners for changed ones.

   **Fold the conversation in** — the human's framing, the connections drawn, the disagreements. A synthesis should reflect the discussion that produced it, not just the source text. Record notable direction in a callout, an `## Open questions` section, or the log `Notes:`. For a contradiction the human hasn't steered, **record both views** in a `> [!WARNING]` callout — don't silently pick a winner.

5. **Drain the worklist.** Remove the synthesized sources from `pending-synthesis.md` (delete the file if nothing remains). Nothing to drain when you synthesized session content with no pending sources.

6. **Refresh the search index** (if qmd is set up): follow `procedures/qmd-update.md`. Skip if qmd isn't configured.

7. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] synthesize | <sources or batch summary>
   Pages created: ...
   Pages updated: ...
   Notes: ...
   ```

8. **Summarize** what changed and surface any judgment calls you made.

Synthesizing several related sources together is the point — the cross-links and contradictions surface across the whole batch, not one source at a time.

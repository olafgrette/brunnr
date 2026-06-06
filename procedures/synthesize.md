# Procedure: Synthesize

Read before weaving new material — captured sources or a query/discussion — into the wiki. This is the **human-steered, conversational** step (the counterpart to mechanical `ingest`): takeaways are surfaced, framing is chosen together, and connections get drawn. Enforces **Division of labor** in `AGENTS.md`; uses the `index.md` / `log.md` formats defined there.

Triggered when the user says "synthesize", "write up the pending sources", or names captured sources to process — **or after a query/discussion session**, to fold the durable insight it produced into the wiki. The material comes from `pending-synthesis.md` (sources captured by `ingest`), the current conversation, or both.

## Steps

1. **Pick the target set** — one or both of:
   - **Pending sources:** default to everything in `pending-synthesis.md`; if the user named specific sources, process just those. Read those source files in full.
   - **The current session:** when synthesizing after a query or discussion, the takeaways, connections, and framing from this conversation *are* the material. `pending-synthesis.md` may be empty or absent then — that's expected, not a no-op. Don't re-derive what the conversation already produced; weave it in.

2. **Find what's already here.** If `brunnr enabled`: `brunnr keyword "<key terms>"` for exact hits, `brunnr semantic "<themes/claims>"` for related ideas that share no keywords. Otherwise read `wiki/index.md`. The goal is to connect the new material to existing pages, not duplicate them.

3. **Open a conversation about the sources — do not lead with a page plan.** The first move is to learn what the *human* took from this material, not to propose wiki structure. Jumping straight to a page proposal is the failure mode this step exists to prevent. Instead:
   - give a **short read of each source** — what it is, the gist;
   - **ask the human what they took away** — what stuck, why they saved it, what they want it to connect to;
   - offer a couple of your own **observations, connections, and contradictions** as openers to react to, not as conclusions.

   Then **end your turn and wait.** Their takeaways and emphasis come first and are themselves content. Treat silence or an off-topic reply as a hard stop, never a cue to proceed.

4. **Propose a page plan — only once the conversation has shaped the material.** When you and the human share a reading, bring:
   - which pages you'd **create**, which you'd **update**, and the **angle** on each;
   - the **judgment calls** (classification, framing, placement) you'd otherwise make silently.

   This stays a back-and-forth: the human steers framing and pushes back, and that dialogue is content too. Refine the plan with them. Write **nothing** in `wiki/` until the human has steered it.

5. Once the user has steered the plan, **write**:
   - a **summary page** for each source;
   - the **entity and concept pages** the sources touch — new ones where missing, updates where they exist;
   - `wiki/index.md` — add new pages, refresh one-liners for changed ones.

   **Fold the conversation in** — the human's framing, the connections drawn, the disagreements. A synthesis should reflect the discussion that produced it, not just the source text. Record notable direction in a callout, an `## Open questions` section, or the log `Notes:`. For a contradiction the human hasn't steered, **record both views** in a `> [!WARNING]` callout — don't silently pick a winner.

6. **Drain the worklist.** Remove the synthesized sources' lines from `pending-synthesis.md`, leaving the file in place even when it's emptied to just the header. Nothing to drain when you synthesized session content with no pending sources.

7. **Refresh the search index** (if qmd is set up): follow `procedures/qmd-update.md`. Skip if qmd isn't configured.

8. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] synthesize | <sources or batch summary>
   Pages created: ...
   Pages updated: ...
   Notes: ...
   ```

9. **Summarize** what changed and surface any judgment calls you made.

Synthesizing several related sources together is the point — the cross-links and contradictions surface across the whole batch, not one source at a time.

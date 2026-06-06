# Procedure: Synthesize

Read before weaving new material — a captured source or a query/discussion — into the wiki. This is the **human-steered, conversational** step (the counterpart to mechanical `ingest`): each source is read deeply, its takeaways surfaced with the human, and only then connected to the rest of the vault. Enforces **Division of labor** in `AGENTS.md`; uses the `index.md` / `log.md` formats defined there.

Triggered when the user says "synthesize", "write up the pending sources", or names captured sources to process — **or after a query/discussion session**, to fold the durable insight it produced into the wiki. The material comes from `pending-synthesis.md` (sources captured by `ingest`), the current conversation, or both.

## One source at a time

Synthesis fails when several sources are processed in one sweep: each gets a shallow read, and the wiki inherits that shallowness. **Process exactly one source per pass, start to finish, before touching the next.** The depth per source is the whole point; batching trades it away. When sources are pending, work them sequentially — don't let cross-source links tempt you into reading them all at once; those links surface fine in each source's vault pass (step 3). (Session/discussion synthesis is itself a single unit — treat the conversation as the one source.)

Each pass has two human feedback loops — **the source first, the vault second** — and writes to the rest of the wiki only after both.

## Steps

1. **Pick one source.** From `pending-synthesis.md`, take a single source — the one the user named, else the first. Read it in full, carefully, not skimming. If synthesizing a session instead, the conversation is the source; its takeaways are already in hand, so go to step 2 with those.

2. **Loop A — get the source right (write the summary, then confirm it).** Write the **summary page** for this source now (`type: summary`, filename `…-summary.md`): a detailed, faithful account of what it actually says — claims, evidence, framing, caveats — not a blurb. Writing it is the forcing function for the close read that prevents shallow synthesis. Then bring it to the human:
   - give your read of the source and walk them through the summary;
   - **ask what they took away** — what stuck, why they saved it, what they expected from it;
   - refine the summary with their corrections and emphasis. Their takeaways are content, not a sanity check.

   **End your turn and wait.** Do not move on to connections until the summary reflects a shared, accurate reading of *this* source. Treat silence or an off-topic reply as a hard stop, never a cue to proceed.

3. **Loop B — connect it to the vault.** Only now look outward. Find what's already here: if `brunnr enabled`, `brunnr keyword "<key terms>"` for exact hits and `brunnr semantic "<themes/claims>"` for related ideas that share no keywords; otherwise read `wiki/index.md`. The goal is to connect the source to existing pages, not duplicate them. Then propose:
   - which existing pages to **update** and which entity/concept pages to **create**, with the **angle** on each;
   - the connections, contradictions, and **judgment calls** (classification, framing, placement) you'd otherwise make silently.

   This stays a back-and-forth: the human steers framing and pushes back, and that dialogue is content too. **Write nothing outside the summary page until the human has steered this.**

4. **Write the rest.** Once the plan is steered:
   - create/update the **entity and concept pages** the source touches — new ones where missing, updates where they exist;
   - `wiki/index.md` — add new pages, refresh one-liners for changed ones.

   **Fold the conversation in** — the human's framing, the connections drawn, the disagreements. A synthesis should reflect the discussion that produced it, not just the source text. Record notable direction in a callout, an `## Open questions` section, or the log `Notes:`. For a contradiction the human hasn't steered, **record both views** in a `> [!WARNING]` callout — don't silently pick a winner.

5. **Drain this source.** Remove its line from `pending-synthesis.md`, leaving the file in place even when emptied to just the header. Nothing to drain when you synthesized session content with no pending source.

6. **Refresh the search index** (if qmd is set up): follow `procedures/qmd-update.md`. Skip if qmd isn't configured.

7. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] synthesize | <source>
   Pages created: ...
   Pages updated: ...
   Notes: ...
   ```

8. **Summarize** what changed and surface any judgment calls you made.

**More sources pending?** Start a fresh pass at step 1 for the next one — a new close read and its own two loops. Don't batch the remainder now that the first is done.

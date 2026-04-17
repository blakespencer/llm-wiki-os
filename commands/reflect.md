---
description: "Stress-test a synthesis page's conjectures — what would refute them, where is the data thin, what are we not seeing"
argument-hint: "<synthesis page name or path>"
---

# /wiki-reflect

The wiki's self-audit. After a synthesis page is created or significantly updated, this skill challenges its own conclusions — applying Popperian falsification to the wiki's own claims.

The human decides WHEN to reflect. The LLM does the stress-testing.

## Input

`$ARGUMENTS` — one of:
- A synthesis page name (e.g., `why-uk-building-costs-high`)
- A full path (e.g., `synthesis/why-uk-building-costs-high.md`)
- Empty — lists all synthesis pages and asks which to stress-test

## Process

### Step 1: Read the wiki state

1. Read `wiki/CLAUDE.md` — refresh on the philosophical framework, source epistemology, "single-answer analysis is always wrong"
2. Read `wiki/frameworks/` — all framework pages (needed for lens-based stress-testing)
3. Read `wiki/backlog.md` — what's already in the pipeline
4. Read the target synthesis page in full
5. Read every page the synthesis page links to (datasets, events, eras, concepts)

### Step 2: Extract the central conjectures

Read the synthesis page and identify:
- **The boldest claim** — the strongest causal statement (e.g., "productivity is the single biggest factor")
- **Supporting claims** — the evidence chain that holds the bold claim up
- **The current confidence level** — how hedged or assertive is the language?
- **Which lenses are applied** — and which are missing?

Present these to the user:

```
## Reflecting on: <synthesis page title>

### Central conjectures (what the wiki currently claims)
1. <boldest claim> — current confidence: <high/medium/low>
2. <supporting claim> — current confidence: <high/medium/low>
3. ...
```

### Step 3: Stress-test each conjecture

For each conjecture, systematically ask:

**Reverse causation**: Could the arrow go the other way? Does A cause B, or does B cause A, or does C cause both?

**Measurement fragility**: How robust is the underlying data? Check the source assessment — is the methodology contested? Are definitions stable over time? Is the deflator reliable?

**Symptom vs cause**: Is this a root cause or a downstream symptom of something deeper? A flat variable can't explain a phased phenomenon. A constant can't cause a change.

**Time-series alignment**: Does the timing actually fit? If the claim is "X caused Y," did X precede Y? Did X change when Y changed?

**International discriminator**: If the claim is about UK exceptionalism, do peer countries show the same pattern? If they do, the discriminator must be something else.

**Narrative fallacy** (Taleb): Are we fitting a story to the data post-hoc? Would we have predicted this finding before seeing the data?

**What would refute it**: Name the specific data, study, or natural experiment that would disprove this conjecture. If you can't name one, the conjecture may be unfalsifiable (Popper would reject it).

**Missing data**: What datasets would strengthen or weaken this claim? Check if any are already in the backlog.

### Step 4: Present the stress-test report

```
## Stress-Test Report: <synthesis page>

### Conjecture 1: "<the claim>"
- Current confidence: <high/medium/low>
- Reverse causation risk: <low/medium/high — explain>
- Measurement fragility: <low/medium/high — explain>
- Symptom vs cause: <assessment>
- Time-series alignment: <fits / doesn't fit — explain>
- International discriminator: <tested / untested>
- Narrative fallacy risk: <low/medium/high>
- What would refute it: <specific data or finding>
- Missing data: <what we'd need> → backlog status: <in pipeline / not yet>

**Recommended revision**: <UPGRADE / hold / downgrade>

### Conjecture 2: ...

### Overall assessment
- Strongest claim (UPGRADE): <which conjecture survived stress-testing and deserves MORE confidence — name the converging evidence>
- Weakest claim (downgrade): <which is most vulnerable to refutation>
- Held claims: <which are reasonably supported but need more data>
- Biggest data gap: <single highest-leverage missing dataset>
- Recommended next action: <what to discover/ingest/query to strengthen the synthesis>

### The balance

**Intellectual humility does NOT mean downgrading everything.** Popper says: claims that survive attempted refutation are our BEST knowledge. If a conjecture survives reverse-causation checks, has good time-series alignment, multiple independent sources agree, and no peer-country comparator undermines it — SAY SO. Upgrade it. State that it's well-supported.

A wiki where every claim is hedged into "might possibly be somewhat consistent with" is not humble — it's useless. The goal is calibrated confidence: high where the evidence is strong, low where it's weak, honest about the boundary.
```

### Step 5: Apply revisions to the wiki

After presenting the report, ask: **"Should I apply these revisions?"**

If approved:
- **Downgrade/upgrade claims** in the synthesis page — change the language to match the evidential warrant
- **Add a `### Stress-tested` section** to the synthesis page noting when it was reflected on and what changed
- **Update the hypothesis catalogue** if the synthesis has one
- **Disperse findings** — update any pages that cited the original claim (era pages, concept pages)
- **Create a question page** if the stress-test produced a substantial analysis worth preserving
- **Add new backlog entries** for any data gaps identified that aren't already in the pipeline
- **Update the Popperian caveat** to be specific about what's been tested and what hasn't

### Step 6: Update index, log, backlog

1. Update `wiki/index.md` if new pages were created
2. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] reflect | <synthesis page>
   Stress-tested N conjectures. Downgraded: M. Upgraded: K. 
   New backlog entries: J. Pages touched: [list].
   ```
3. Update `wiki/backlog.md` with any new data gap entries (status: discovered)

### Step 7: Suggest next

```
### Suggested next
- **Highest-leverage data gap**: <the single dataset that would most change the synthesis>
- **Follow-up reflects**: <other synthesis pages that should be stress-tested>
- **Queries to run**: <questions the wiki can now answer that it couldn't before>
- **Backlog**: N discovered, M approved, K built, J ingested
```

### Step 8: Commit

```bash
cd wiki && git add -A && git commit -m "reflect: stress-test <synthesis page> — N conjectures tested"
```

## When to use this

- After `/wiki:ingest` creates or significantly updates a synthesis page
- After `/wiki:discover` produces a synthesis with strong claims
- Periodically — as new data is ingested, old syntheses may need re-testing
- When you're about to build a frontend feature based on a synthesis — make sure the claims are solid first
- When something feels too clean — "single-answer analysis is always wrong" means the wiki should distrust its own neatness

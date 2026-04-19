---
description: "Process a dataset or source into the wiki, dispersing knowledge across multiple pages"
argument-hint: "[ETL dataset name, file path, or URL]"
---

# /wiki-ingest

Ingest a data source into the wiki. This is the primary way the wiki grows — each ingest reads a source, extracts knowledge, and **disperses it across many pages** (creating new ones and enriching existing ones).

A single source typically touches 10–15 wiki pages.

## Input

`$ARGUMENTS` — one of:
- **ETL dataset name** (e.g., `gilts`, `inflation`, `bank-rate`) → reads `apps/web/public/data/<name>.json`
- **File path** to a raw source document (article, report, PDF)
- **URL** to an article or data source → fetch with WebFetch

If no argument:
1. Read `wiki/backlog.md` — check for entries in "Built" (ETL done, awaiting ingest) or "Approved" (ready to build)
2. Read `wiki/index.md` — check "Datasets not yet wiki'd"
3. Recommend the highest-value next ingest based on: what has stubs waiting, what connects to the most existing pages, what's in the backlog pipeline

## Process

### Step 1: Check the backlog

Read `wiki/backlog.md`. Is this source in the pipeline?
- If it's in "Approved" or "Built" → great, this ingest was expected. Note the stub pages that were pre-created and the gap it was motivated to fill.
- If it's not in the backlog → that's fine (manual ingest). Add it to "Ingested" at the end.

If stubs exist for this source (pages with `status: stub`), plan to **fill them** rather than creating new pages from scratch.

### Step 2: Read the source

**If ETL dataset:**
1. Read `apps/web/public/data/<name>.json` — understand data shape, coverage, key observations
2. Read the corresponding ETL Go file (`apps/etl/<name>.go`) for source metadata and context
3. Note: source URL, licence, attribution, observation count, date range, annotations

**If file or URL:**
1. Read/fetch the content
2. Extract: key facts, claims, named entities, events, data points, dates
3. Assess: source credibility, potential biases, date of publication

### Step 2: Read the existing wiki state

1. Read `wiki/index.md` — what pages already exist?
2. Read `wiki/CLAUDE.md` — refresh on page type conventions, data quality conventions, and cross-reference rules
3. Read every existing page that this source intersects with (entities, events, concepts already mentioned)
4. Identify: which existing pages need updating, what new pages need creating, and **where the new source contradicts existing wiki content**

### Step 3: Pre-compile cross-temporal facts

This is critical. The wiki should be **pre-compiled, not re-derived on every query.**

For this new source, look at every existing event, era, and synthesis page and ask:
- **What was this new dataset doing during that event/era?**
- Extract the specific data points (dates, values) and prepare to write them into those pages.

Example: if ingesting inflation data, check every event page:
- "What was CPI during the Brown gold sale (1999-2002)?" → write "CPI was 1.5%" into `events/brown-bottom.md`
- "What was CPI during Black Wednesday (1992-09)?" → write "CPI was X%" into `events/black-wednesday.md`
- "What was CPI during the Truss mini-budget?" → write it into `eras/truss-2022.md`

This way, the next time someone asks "what was inflation during event X?", the answer is already in the wiki — no need to re-derive from raw JSON.

### Step 4: Discuss with the user

Before writing anything, present:

```
## Ingest Plan: <source name>

### Source summary
<2-3 sentences: what this is, coverage, why it matters>

### Key facts/observations
- <fact 1>
- <fact 2>

### Cross-temporal facts to pre-compile
- <event/era page> ← <what this dataset shows during that period>
- ...

### Pages to create (N)
- <page type>/<slug> — <one-line description>

### Pages to update (N)
- <page path> — <what's being added/changed>

### Contradictions detected (N)
- <existing claim> vs <new data> — in <page path>

### Data quality issues to document
- Splice points: <any>
- Coverage gaps: <dataset ends at X, misses Y>
- Overlap with existing datasets: <which, how they compare>

### Total pages touched: N
```

Ask: **"Does this look right? Anything to emphasise or skip?"**

### Step 5: Create and update pages

After user approval:

**New pages must follow `wiki/CLAUDE.md` conventions:**
- Valid YAML frontmatter with `type`, `created`, `updated`, and type-specific fields
- Minimum 3+ outbound `[[wikilinks]]`
- Dataset pages: key observations, limitations, data quality issues, connections
- Entity pages: reference every dataset where the entity appears
- Event pages: cite specific data points from relevant datasets, include government context
- Concept pages: how the concept manifests across datasets

**Updating existing pages:**
- Add new sections, paragraphs, or cross-references — **don't rewrite existing content unless it's factually wrong**
- Write cross-temporal facts as natural prose, not just link lists
- Update frontmatter `updated` date and `datasets` array

**Frontmatter boundary — do NOT set `stress_tested:`.**
That marker is set by `/wiki:reflect` when it applies revisions, per the wiki↔story-map seam contract (`thoughts/architecture/operating-manual.md`). It is the precondition `/story-map:integrate` checks to decide whether a synthesis page is consumable — mechanically distinguishing "reflected" from merely "re-ingested." An ingest that touches a previously-stress-tested page MUST refresh `updated:` but MUST NOT add, refresh, or otherwise touch `stress_tested:`. If the ingest's additions materially affect a stress-tested conjecture, file a Reflect candidate in `wiki/backlog.md` (see Step 11) rather than self-refreshing the seam marker. Observed violation: 2026-04-19 `/wiki:ingest energy-prices` (wiki commit `797253b`) set `stress_tested: 2026-04-19` on three pages — reverted in follow-up because ingest is not authorised to set that field.

**Cross-reference rules (no bare links):**
Every `[[wikilink]]` must have a why-clause — a phrase explaining why the connection matters. Never write bare `- [[page]]`. Always write `- [[page]] — <why this connection is relevant>`.

Example:
- WRONG: `- [[datasets/gilts]]`
- RIGHT: `- [[datasets/gilts]] — gilt yields spiked to 4.5% during the mini-budget, the sharpest modern move`

**Contradiction handling:**
When new data contradicts existing wiki content, do NOT silently overwrite. Add a `### Disputed` subsection showing both claims with citations.

**Figure verification — specific case.** If this ingest was motivated by a prior `/wiki:discover` round, its synthesis or stub pages may cite specific numbers (percentages, peak values, dates) that were directional evidence at discovery time, not canonical values. Verify each figure against the source you just read. If a dossier figure does not reconcile with the canonical data, apply the protocol: `### Disputed` section citing both the dossier value and all canonical variants with their actual values, investigation trail preserved, never silent pick. Template: `datasets/construction-price-index.md`. Provenance: `thoughts/product/story-map/learnings.md` commits `f44c6cc` + `12c32cf` (2026-04-18).

**Data quality conventions:**
Apply the three mandatory checks from `wiki/CLAUDE.md`:
1. Splice discontinuities → document in `### Disputed`
2. Coverage gaps → note what's missing
3. Overlap divergence → compare in the overlap period

**Source epistemology (MANDATORY on every dataset page):**
Every dataset page MUST include a `### Source assessment` section. This is not optional. Apply the seven questions from `wiki/CLAUDE.md`:
1. Methodology — how was this data produced?
2. Definitions — what exactly is being measured? What could it mean differently?
3. What's NOT measured — what did they leave out and why?
4. Who commissioned it and why — what were they looking for?
5. Who benefits from this conclusion — follow the incentive
6. Revisions and controversies — track record, past challenges
7. Comparison sources — is there another source measuring the same thing?

Do NOT wait for the user to ask for this. It is part of the ingest, every time.

### Step 6: Create synthesis pages

**Be aggressive.** If the ingested source connects to 2+ existing datasets in a non-obvious way, create a `synthesis/` page. Synthesis pages are the wiki's highest-value output.

**Every synthesis page MUST include:**

1. **`### Through different lenses`** — read `wiki/frameworks/` and apply whichever lenses genuinely illuminate the question. Cite specific evidence from the ingested data. Don't force-fit all lenses — use what fits.

2. **Popperian caveat at the end** — "These are conjectures supported by the evidence. They are not proven. Alternative explanations exist." This is not optional hedging. It's precision about what the data can and cannot tell us.

3. **Multiple interpretations** — per the schema's core principle: single-answer analysis is always wrong. Present at least 2-3 different readings of the same data.

### Step 7: Update overview

If `wiki/overview.md` exists, update it with any significant new knowledge from this ingest. The overview is the living narrative of what the wiki knows.

### Step 8: Update index and log

1. Update `wiki/index.md` — add new pages (alphabetical within sections), update descriptions
2. Append to `wiki/log.md` using the full format (list every page path touched, what was added to each)

### Step 9: Propose schema improvements

After the ingest, consider: does `wiki/CLAUDE.md` need to evolve? New page type, new convention, new frontmatter field? If so, propose it.

### Step 10: Update the backlog

Read `wiki/backlog.md` and update:
- If this source was in "Approved" or "Built" → move it to "Ingested" with today's date
- If this source was NOT in the backlog (manual ingest) → add it to "Ingested"
- Remove `status: stub` from any stub pages that were filled during this ingest, AND refresh `updated: <YYYY-MM-DD>` in the same frontmatter — filling a stub is a substantive update and the date must reflect it
- **Close the GH issue** if the backlog entry has one. Run `gh issue close <num> --comment "Ingested in commit <hash>"`. This keeps GH kanban state in sync with wiki state. Without this, an open GH issue after ingestion becomes a lagging tracking artifact that makes downstream tools (e.g., `/operator next`) mis-classify completed work as unfinished. If `gh issue close` fails, log but don't abort — the wiki state is what matters; GH is a secondary view.
- Note: the backlog is the compounding loop's memory — keep it accurate

### Step 11: Suggest what to do next

Read the backlog and the wiki state to recommend the highest-value next action:

```
### Suggested next
- **Questions to ask**: <2-3 questions that this new data makes answerable>
- **Sources to investigate**: <any gaps this ingest revealed>
- **Datasets to ingest next**: <highest-value item from backlog, or un-ingested dataset>
- **Backlog status**: N discovered, M approved, K built (awaiting ingest), J ingested
```

The wiki should be **generative** — every operation suggests the next one.

### Step 12: Commit

```bash
cd wiki && git add -A && git commit -m "ingest: <source> — N created, M updated"
```

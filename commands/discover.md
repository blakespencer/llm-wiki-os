---
description: "Ask a question, get an answer from what exists, then actively research what's missing online"
argument-hint: "<question or topic — can include hypotheses to investigate>"
---

# /wiki-discover

The wiki's self-improvement engine. The compounding loop:

```
Question → Answer from wiki → Gaps identified → Permission to research
→ Web research → Verify causal chains → Propose data sources
→ User approves → Stub pages created → GitHub issues filed
→ ETL built → /wiki-ingest → Wiki enriched → Better answers next time
```

## Core Principle: Verify, Don't Trust

The user may suggest causes, factors, or leads. **These are hypotheses, not facts.** The agent must:

1. **Investigate** — search for evidence, not just confirmation
2. **Verify** the causal chain — is there actual data showing the connection?
3. **Report honestly** — if the suggestion doesn't hold up, say so clearly
4. **Discover adjacent factors** — the agent's value is finding what the human missed

User suggestions are leads to investigate, not conclusions to justify.

## Input

`$ARGUMENTS` — a question or topic. May include hypotheses.

## Process

### Step 1: Read wiki state + backlog + schema

1. Read `wiki/CLAUDE.md` — refresh on the philosophical framework (three interlocking systems, ground/ceiling/lenses, bottom-up vs top-down rules)
2. Read `wiki/index.md` to find relevant pages
3. Read `wiki/backlog.md` — is anything already in the pipeline for this topic?
4. Read relevant wiki pages and framework pages — **try to answer from wiki alone first**
5. If needed, fall back to raw dataset JSONs

### Step 2: Present what the wiki knows + gaps + ask permission

Be **concise** but **use the schema's framework** to organise the hypotheses. Don't just list factors — frame them through the three interlocking systems.

```
## What the wiki knows
<2-3 sentences max. If "almost nothing", say so in one line.>

## Where it's weak — through the three systems

**Human nature** (what about people drives this?):
- <factors related to cognitive biases, moral foundations, needs>

**Society** (what about how people coordinate drives this?):
- <factors related to culture, norms, NIMBYism, industry structure>

**Rules** (what about government/law drives this?):
- Bottom-up (common law, organic): <e.g. property rights, precedent>
- Top-down (statute, designed): <e.g. planning law, building regs, tax>

**What emerged** (what does the data show?):
- <observable outcomes — prices, costs, output, productivity>

These are hypotheses from general knowledge — I'll verify each with
data in the research phase (Popper: all conjecture until tested).

## Lenses that might illuminate this
<Read wiki/frameworks/ — list whichever existing frameworks are
relevant to THIS question. Don't force-fit all of them. Some
questions only need 2 lenses. Some need 4. Use what fits.>

Existing wiki pages this would connect to:
- [[datasets/X]] — <how>
- [[eras/Y]] — <how>

Backlog status: N discovered, M approved, K built, J ingested.
```

Then ask: **"Should I research online to find what data exists for these factors?"**

**Wait for user confirmation.** Keep it concise — the three-systems framing should sharpen the list, not bloat it. Each factor should be 1 line, not a paragraph. The explanations come after research, with evidence.

### Step 4: Active web research

Use WebSearch and WebFetch:

**For each gap:**
1. UK government sources (ONS, BoE, BEIS/DESNZ, HMRC, HM Treasury)
2. International sources (World Bank, IMF, OECD, Eurostat, FRED)
3. Open data portals (DataHub, data.gov.uk, Nasdaq Data Link)

**For each user hypothesis:**
- Search for evidence FOR and AGAINST
- Verify the causal chain with credible sources
- If it doesn't hold up, say so and explain why

**For each potential data source:**
- Exact URL
- Format (CSV/JSON/xlsx)
- Coverage (date range)
- Licence
- Machine-readable? Free? Updated regularly?
- **Source type and incentive** (per wiki/CLAUDE.md source epistemology): who produced this, why, what do they gain from the conclusion? National statistics vs academic vs campaign group vs consultancy — different skepticism levels.

### Step 5: Present the discovery report

Apply the schema's philosophical framework to organise findings. The report should show the research through the three systems and lenses, not just list sources.

```
## Discovery Report: "<question>"

### What the wiki knows
<current answer — honest about completeness>

### Through the three systems (with evidence)

**Human nature**: <what the research found about cognitive/behavioural drivers>
**Society**: <what the research found about cultural/structural drivers>
**Rules (bottom-up)**: <common law, organic institutions>
**Rules (top-down)**: <statute, regulation, government intervention>
**What emerged**: <observable data — costs, output, productivity>

### Through different lenses

<Read wiki/frameworks/. Apply only the frameworks that genuinely
illuminate this question — don't force-fit all of them. For each
lens applied, cite the specific evidence found in research.>

**Popperian caveat**: These are conjectures supported by the evidence found.
They are not proven. Alternative explanations may exist.

### User hypotheses investigated
- "<hypothesis>": **Supported / Partially supported / Not supported**
  <evidence for and against>

### Data sources found

#### High confidence (free, machine-readable, good coverage)
1. **<source>** — <what it provides>
   - URL: <url>
   - Format/Coverage/Licence/ETL feasibility

#### Medium confidence
1. ...

#### Low confidence
1. ...

### Proposed ETL additions
- `etl <name>` — <description> (source: <url>)

### Proposed wiki pages
- `concepts/<name>.md` — <why>
- `entities/<name>.md` — <why>
- `synthesis/<name>.md` — <why>

### How this enriches the existing wiki
<List which existing pages would gain new content from each proposed source.
This is the dispersal preview — the user should see the compounding value.>
- [[datasets/wages]] would gain: construction-specific wage data
- [[datasets/inflation]] would gain: construction component breakdown
- [[eras/cameron-2010]] would gain: infrastructure spending context
```

### Step 6: User decides

Present each proposed source and ask: **"Which of these should we pursue?"**

The user approves, rejects, or deprioritises each. The LLM does NOT automatically build ETLs.

### Step 7: Update the backlog

This is the compounding loop's state machine. Read `wiki/backlog.md` and:

1. Add each **approved** source to `### Approved` with full metadata (URL, format, licence, coverage, motivated-by question, stub pages)
2. Add each **not-yet-approved** source to `### Discovered` so it's not lost
3. File a GitHub issue for each approved source:
   ```bash
   gh issue create --repo restblake/uk-legalize \
     --title "Ingest <dataset name>" --label "backlog,etl" \
     --body "$(cat <<'EOF'
   Motivated by: /wiki:discover "<question>"
   Source: <url>
   Format: <format> | Coverage: <range> | Licence: <licence>
   Fills gap: <what wiki question this enables>
   Stub pages: <list>
   EOF
   )"
   ```
4. Note the GitHub issue number in the backlog entry

### Step 8: Create stub pages and update wiki

For each approved source:
1. Create stub pages with `status: stub` frontmatter and "Data not yet ingested — see [[backlog]]" note
2. Add annotated cross-references from existing pages (with why-clauses)
3. Create a synthesis page connecting the discovered topic to existing wiki content if warranted

### Step 9: Update navigation surfaces (index, overview, log)

All three nav-surface files must reflect the new stubs before committing. A miss on any one leaves the wiki navigable but inconsistent.

1. Update `wiki/index.md` — add stub pages (mark with *(stub)*)
2. Update `wiki/overview.md` — add the new gap/stub so the landing narrative surfaces it
3. Update `wiki/log.md` — full log entry: pages touched, what was added, backlog entries created

Before continuing to Step 11, confirm all three files appear in `git status`.

### Step 10: Suggest what to do next

Read the backlog and recommend the highest-value next action:

```
### Suggested next
- **Build first**: <which approved ETL to build first and why — highest value for wiki enrichment>
- **Questions unlocked**: <what becomes answerable once that data is ingested>
- **Follow-up discovers**: <deeper questions to ask once new data exists>
- **Backlog status**: N discovered, M approved, K built (awaiting ingest), J ingested
```

### Step 11: Commit

```bash
cd wiki && git add -A && git commit -m "discover: <question summary>"
```

## The compounding loop

The backlog is the loop's memory. Without it, each session starts from scratch. With it:

```
/wiki:discover → adds to backlog (discovered → approved)
                → files GitHub issues
                → creates stub pages

(human or LLM builds ETL)
                → moves backlog entry to "built"

/wiki:ingest   → reads backlog, finds "built" entries
                → ingests data, fills stub pages
                → moves backlog entry to "ingested"
                → wiki is richer

/wiki:query    → answers better because wiki is pre-compiled
                → reveals NEW gaps
                → suggests: "run /wiki:discover on <topic>"

/wiki:lint     → reads backlog
                → reminds: "3 approved sources awaiting ETL build"
                → reminds: "2 built sources awaiting ingest"
                → suggests: "highest-value next action is X"
```

Each skill reads the backlog. Each skill writes to it. The loop turns.

## Product feedback loop

Every discovery is a **product gap analysis**: dataset → ETL → frontend feature → new section on site. `/wiki:discover` is the product roadmap generator. The wiki is the brain; the product is the body.

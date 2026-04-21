---
description: "Health-check the wiki: structural integrity, content gaps, quality, and suggest next questions"
---

# /wiki-lint

Health-check the wiki, fix issues, and **suggest what to investigate next**. Lint is not just maintenance — it's also the wiki's self-awareness about what it knows and doesn't know.

## Process

### Step 1: Read the full wiki state

1. Read `wiki/CLAUDE.md` — refresh on conventions and data quality requirements
2. Read `wiki/index.md`
3. List all markdown files in `wiki/` (all subdirectories)
4. Read every page's frontmatter and body

### Step 2: Run checks

**Structural issues:**
- [ ] **Broken wikilinks**: `[[links]]` pointing to pages that don't exist
- [ ] **Orphan pages**: Pages not listed in `index.md`
- [ ] **One-way links**: A links to B but B doesn't link back
- [ ] **Bare links**: Cross-references without a why-clause (just `- [[page]]` with no annotation)
- [ ] **Frontmatter issues**: Missing `type`, `created`, or `updated`

**Content issues:**
- [ ] **Uncovered datasets**: ETL datasets in `apps/web/public/data/` with no wiki page
- [ ] **Missing era pages**: Government eras from `governments.json` without wiki pages
- [ ] **Missing entity/event pages**: Referenced in wikilinks or body text but lacking own page
- [ ] **Empty sections**: Placeholder text like "To be created"
- [ ] **Stale claims**: Pages with old `updated` dates that newer data may supersede

**Data quality (mandatory per schema):**
- [ ] **Splice discontinuities**: Spliced dataset pages that don't document the splice point
- [ ] **Coverage gaps**: Datasets ending before present that don't note what they're missing
- [ ] **Overlap divergence**: Overlapping datasets from different sources without comparison

**Quality issues:**
- [ ] **Thin pages**: Content pages with fewer than 100 words body
- [ ] **Isolated pages**: Pages with fewer than 3 outbound `[[wikilinks]]`
- [ ] **Zero synthesis pages**: Red flag if 5+ datasets exist
- [ ] **Zero contradictions surfaced**: Suspicious if multiple sources exist
- [ ] **Missing data citations**: Dataset pages without specific observations (dates, values)
- [ ] **Missing temporal context**: Event pages without government attribution
- [ ] **Pre-compilation gaps**: Event/era pages that mention a dataset but don't include specific data points from it (e.g., an event page links to [[datasets/inflation]] but doesn't say what inflation was during that event)

**Philosophical framework compliance (per wiki/CLAUDE.md):**
- [ ] **Missing source assessment**: Every dataset page MUST have `### Source assessment` with the 7 questions (methodology, definitions, what's not measured, who commissioned, who benefits, revisions, comparison sources). Flag any dataset page without it.
- [ ] **Missing lenses on synthesis**: Every synthesis page MUST have `### Through different lenses` applying relevant frameworks from `wiki/frameworks/`. Flag any synthesis page without it.
- [ ] **Missing Popperian caveat**: Every synthesis page MUST end with intellectual humility — "these are conjectures, not proven." Flag any synthesis page without it.
- [ ] **Single-answer violation**: Any page that presents one clean explanation without alternatives violates the core principle. Read each synthesis, era, and event page — does it present multiple interpretations or just one narrative?
- [ ] **Bare wikilinks**: Any `- [[page]]` without a why-clause in a Cross-references or Connections section.

**Fidelity-layer compliance (per wiki/CLAUDE.md Ground-truth / Correctness-grade / External-claims sections):**
- [ ] **Missing `## Ground truth` section** on dataset pages — schema-mandatory. Flag every dataset page lacking one as a retrofit candidate.
- [ ] **Missing `## Ground truth` section** on era pages — schema-mandatory (era pages consolidate claims from multiple datasets). Flag every era page lacking one.
- [ ] **Missing `correctness_grade:` frontmatter** — required on dataset and era pages at minimum. Default for synthesis is `interpretive` but should be explicit.
- [ ] **Stale `figures_verified:` frontmatter** — flag pages whose cited dataset has been re-ingested (wiki commit on the dataset page is newer than the page's `figures_verified:` date). These need re-audit via `/wiki:audit`.
- [ ] **Malformed ground-truth row IDs** — every row ID must start with `<page-slug>.` matching the page's filename. Duplicate IDs within a page = schema violation. Report counts and target-page list.

When fixing these: **read the page, read the relevant data, and write the missing section.** Don't just flag — fix. For source assessments, apply the 7 questions. For lenses, read `wiki/frameworks/` and apply what fits. For Popperian caveats, add one that's specific to the page's content, not generic.

**Divergence-surfacing discipline (per 2026-04-20 /wiki:lint retrofit emergent observations, now contract):**
- Where prose and data diverge during fixing (e.g., a stat-card's prose claims 5.4× growth but JSON shows 4.2×), **flag the divergence as a Ground-truth row marked for `/wiki:audit`** — do NOT silently patch the prose in this lint pass. Silent patching loses the investigation trail; `/wiki:audit` is the right venue for figure-level resolution.
- Where the cited JSON does not contain a value the prose references (external claim), **mark the claim with `(external claim; <backlog-entry>)` syntax** per wiki/CLAUDE.md's External-claims convention — do NOT fabricate a ground-truth row from the prose value. Fabrication hides coverage gaps the author needs to see.

**Schema health:**
- [ ] **Page type coverage**: All types in CLAUDE.md actually used?
- [ ] **Convention drift**: Patterns in pages not documented in schema?
- [ ] **Overview staleness**: Does `overview.md` reflect current wiki state?

**Zero-state discipline.** **Every bullet in every checklist above renders a line in the report — a concrete count (with examples where possible) OR an explicit `N detected` / `none detected` line. Silent omission of any listed bullet is a failure mode.** A reader cannot distinguish "skipped" from "zero found"; the fidelity layer exists because that distinction is load-bearing for downstream consumers. Sharpened from the looser phrasing in `c321f38` after 2026-04-20 runs still produced silent omissions for one-way-links and frontmatter-missing-fields despite the earlier rule existing.

### Step 3: Present the report

```
## Wiki Lint Report

### Critical (must fix)
- ...

### Important (content gaps)
- ...

### Quality
- ...

### Data quality
- ...

### Philosophical framework compliance
- N dataset pages missing source assessment
- N synthesis pages missing ### Through different lenses
- N synthesis pages missing Popperian caveat
- N pages with single-answer violations
- N bare wikilinks without why-clauses

### Schema health
- ...

### Stats
- Content pages: N
- Total wikilinks: N (bare: M)
- Avg links/page: N.N
- Datasets covered: N/M
- Eras covered: N/M
- Synthesis pages: N
- Question pages: N
- Contradiction sections: N
- Pre-compiled cross-temporal facts: estimated N/M
```

### Step 4: Check the backlog pipeline

Read `wiki/backlog.md` and report pipeline status:

```
### Backlog pipeline
- Discovered (awaiting approval): N entries
- Approved (awaiting ETL build): M entries
  - <name>: <one-line desc> — approved on <date>
- Built (awaiting /wiki:ingest): K entries
  - <name>: <one-line desc> — ETL exists, run /wiki:ingest <name>
- Ingested (complete): J entries
- Stale stubs: <any stub pages whose backlog entry was never approved/built>
```

Flag:
- **Approved entries sitting >7 days** without being built → remind user
- **Built entries not yet ingested** → these are one `/wiki:ingest` command away from enriching the wiki
- **Stale stubs** → pages with `status: stub` that aren't connected to a backlog entry

### Step 5: Fix issues

**HARD FAIL if this step auto-applies without user approval.**

Pause with a numbered list of the severity levels this run found non-empty. For each option, include a one-line scope preview naming the pages-touched count and the risk type. Accept any combination of options — users scope the fix pass by which verdict classes they want resolved.

Template:

```
Which severity levels do you want me to fix?

(a) Critical only — <one-line scope>. N pages touched. Risk: <type>.
(b) Important only — <one-line scope>. M pages touched. Risk: <type>.
(c) Quality only — <one-line scope>. K pages touched. Risk: <type>.
(d) Data quality only — <one-line scope>. J pages touched. Risk: <type>.
(e) Fidelity-layer only — <one-line scope>. L pages touched. Risk: <type>.
(f) All of the above.
(g) Nothing — zero-fix exit.
```

Only render options whose severity class had non-zero findings in Step 3. Empty classes get collapsed (no "(z) Nothing to fix in Quality"). If all classes are zero, the run exits cleanly without prompting — skip to Step 6 log with zero fixes.

After user picks: apply only the authorized classes. Do not fold unauthorized fixes into an authorized class silently.

Codified 2026-04-21 from the 2026-04-20 /wiki:lint run pattern (N=2 across runs) per `thoughts/notes/day-plan-2026-04-21.md` Step 2 guidance.

### Step 6: Suggest next questions

**This is a Karpathy requirement.** Lint doesn't just report problems — it suggests what the wiki should investigate next.

Read the backlog, the wiki state, and the gaps to generate:

```
### Suggested next

#### Highest-value action right now
<single recommendation: the one thing that would most enrich the wiki>

#### Questions to investigate (/wiki:query)
1. <question the wiki's existing data could answer but hasn't been asked>
2. <question connecting datasets not yet linked by a synthesis page>
3. <question motivated by a gap or contradiction discovered in this lint>

#### Sources to ingest (/wiki:ingest)
1. <highest-value item from backlog "Built" section>
2. <un-ingested ETL dataset that would enrich the most existing pages>

If the "Built" section is empty, do not list "Approved" entries here — the two queues are distinct (build must precede ingest). Instead: (a) name a specific "Approved" entry with the caveat "build precedes ingest — run the ETL, then return here," OR (b) name an un-ingested ETL output that the wiki would most benefit from. Name the actual source; do not leave the bullet blank.

#### Topics to discover (/wiki:discover)
1. <topic where the wiki's answer would be weakest — worth researching online>

#### Backlog pipeline summary (mandatory closing line)
- `N discovered / M approved / K built / J ingested / R reflect-candidates`

This line is not optional. Every Suggest-next block closes with this summary so the pipeline state is machine-parseable across lint runs. Include `reflect-candidates` count even when zero (`R=0`).
```

### Step 6: Update log

Full format with every page touched.

### Step 7: Propose schema improvements

If lint revealed conventions not in the schema, or schema rules nobody follows, propose updates.

### Step 8: Commit

```bash
cd wiki && git add -A && git commit -m "lint: fix N issues — [key fixes]"
```

---
description: "Verify numeric claims in wiki prose against primary data. Complements /wiki-lint (structure) and /wiki-reflect (conjectures)."
---

# /wiki-audit

**The write-time fidelity enforcer.** The Karpathy wiki pattern trades RAG's re-derivation-per-query for compile-once-keep-current. That trade only works if the compiled artifact is actually correct. `/wiki-audit` is the mechanism that verifies it.

Diagnosis: `thoughts/architecture/wiki-claim-fidelity.md`. Schema contracts this skill enforces: `wiki/CLAUDE.md` sections *"Ground truth sections"*, *"Correctness grade"*, and *"External claims"*.

## What this skill does (and does not)

**Does:**
- Extracts numeric claims from wiki prose
- Diffs each claim against ground-truth rows on cited dataset/era pages, or directly against JSON when rows are missing
- Classifies each claim: VERIFIED / CONTRADICTED / UNVERIFIABLE / EXOGENOUS
- Updates `figures_verified:` frontmatter on pages that pass
- Files contradictions as corrections or `### Disputed` sections per the human's decision

**Does not:**
- Stress-test causal conjectures — that's `/wiki-reflect`'s job
- Check structural integrity (broken links, orphan pages, frontmatter) — that's `/wiki-lint`
- Adjudicate interpretive claims (lens choice, dispersal, tone) — those violate different conventions and are out of scope
- Fabricate ground-truth rows — if a claim cites a row that doesn't exist, the skill flags UNVERIFIABLE and the author decides whether to add the row, correct the claim, or mark external

## Process

### Step 1: Read the full wiki state + the contracts

1. Read `wiki/CLAUDE.md` — refresh on ground-truth schema, correctness_grade semantics, external-claim syntax
2. Read `thoughts/architecture/wiki-claim-fidelity.md` (if present) — the diagnosis that motivates this skill
3. Read `wiki/index.md`
4. List all markdown files in `wiki/` (all subdirectories)
5. Read every page's frontmatter and body
6. List all JSON files in the raw-data location declared in `wiki/CLAUDE.md` (default: `apps/web/public/data/*.json`)

### Step 2: Build the ground-truth index

For every dataset page and every era page, parse the `## Ground truth` section into a row-ID → value map.

Expected row format (dataset page):
```markdown
| `<page-slug>.<stable-kebab-identifier>` | <fact> | <value> | <coordinates> |
```

Expected row format (era page): same grammar; rows may reference other ground-truth rows via `[[page#row-id]]` in the *source row* column.

**If a dataset or era page has no `## Ground truth` section:**
- Dataset pages: this is a schema violation. Flag for Step 8's schema-health report. Audit downstream pages against the JSON directly for now; do not use the un-sourced page as an authority.
- Era pages: same — schema violation. Flag and fall back to the cited dataset pages' rows during the audit.

**Row-ID integrity checks during parsing** (grammar per `wiki/CLAUDE.md` Ground-truth-sections convention):
- Every row ID must start with `<page-slug>.` where `<page-slug>` matches the page's filename without extension.
- The identifier portion (after the first dot) is kebab-case and MAY contain additional dots for semantic grouping (e.g., `thatcher-1979.gilts.peak` is a valid era-page row where `gilts.peak` is a dotted identifier).
- IDs must be unique within the page.
- Duplicate IDs, IDs that don't begin with the page slug, or IDs with malformed characters → schema violation. Flag and halt downstream audit on that page until resolved.

### Step 3: Enumerate pages by audit priority

Priority order (derived from the compounding-risk table in the diagnosis doc):

1. `overview.md` — broadcast amplifier
2. Dataset pages (`datasets/*.md`)
3. Era pages (`eras/*.md`)
4. Synthesis pages (`synthesis/*.md`)
5. Concept pages (`concepts/*.md`)
6. Event pages (`events/*.md`)
7. Entity pages (`entities/*.md`)
8. Question pages (`questions/*.md`)
9. Framework pages (`frameworks/*.md`)

Skip: `index.md`, `log.md`, `backlog.md`, `CLAUDE.md` — these are maintenance surfaces, not claim surfaces.

### Step 4: Extract claims from each page

For each page in priority order:

1. Parse body prose (skip frontmatter, skip `### External context` sections, skip code blocks).
2. Identify numeric claims. A numeric claim has four components:
   - **Subject** — the entity/concept the claim is about (e.g., "Bank Rate", "Thatcher-era gilts")
   - **Value** — a number with unit (e.g., "17%", "$2.06", "14.14%")
   - **Coordinates** — optional date, era, or event anchor (e.g., "in Nov 1979", "during Thatcher")
   - **Citation** — optional `[[page#row-id]]` link or `[[page]]` reference

   Extraction method: LLM pass with **structured output mandatory** — produce one row per claim matching the shape `{page, line, subject, value, coord, citation, verdict, verdict_sub_class, marker_form}` or equivalent. Do NOT produce free-form prose in the extraction step; structured rows are required so a post-processing check can enforce `total_claims == sum(verdicts_by_class) + syntax_flagged_count`. Arithmetic drift (running-tally mismatches in Step 6 reports) is a failure mode the structured-output requirement exists to prevent. Codified 2026-04-21 after 2026-04-20 /wiki:audit runs had persistent tally drift (24-vs-31 partial, 30-vs-33 complete) across both runs.

   Prefer precision over recall — a missed claim is an un-audited claim; a false-positive claim extraction is extra work but not an error. Err toward missed-extraction only when the prose is truly ambiguous.

3. For each extracted claim, check for explicit external marking per `wiki/CLAUDE.md`'s External-claims convention (three accepted syntaxes):
   - Inline parenthetical: `(external claim; <optional source>)` in the same sentence. The `external claim` keyword is required for disambiguation.
   - Inline short-form: `*(external)*` trailing italic qualifier in the same sentence.
   - Sectioned: `### External context` — already handled by skipping such sections at Step 4.1.
   - If any accepted marker is present: classify EXOGENOUS, record the claim and marker form, move on.
   - **Not accepted** (these do NOT mark the claim external; the audit treats them as unmarked): bare parenthetical without the `external claim` keyword, freestanding italic text, footnote references (`[^1]`).

4. For claims with *apparent external intent but non-canonical marker syntax* (e.g., em-dash "— external claim; …", "widely reported", "by various sources", "*not in our dataset*"), classify as **SYNTAX-FLAGGED** — a fourth bucket distinct from EXOGENOUS and UNVERIFIABLE. These claims are *probably* external but the author didn't use an accepted syntax; the audit surfaces them to Step 9's schema-health report with a `marker_migration_candidates:` flag. Do NOT auto-convert to UNVERIFIABLE (would trigger a false CONTRADICTED cascade); do NOT auto-convert to EXOGENOUS (would silently accept intent-over-syntax, undermining the convention). The 4th bucket is the audit's honest "this looks external but wasn't marked right — human, migrate the syntax." Codified 2026-04-21 after 2026-04-20 /wiki:audit N=1 run improvised this category (present in 4 target-page claims); promoted from executor-discretionary to skill-mandated.

### Step 5: Verify each non-external claim

For each remaining claim:

**Case A — claim cites a `[[page#row-id]]`**:
1. Resolve the row ID in the ground-truth index from Step 2.
2. If the row doesn't exist: **UNVERIFIABLE — broken citation**.
3. If the row exists but the value in prose disagrees with the row value: **CONTRADICTED — prose vs row**.
4. If they agree: **VERIFIED**.

**Case B — claim cites `[[page]]` without a row ID**:
1. Look up the cited page's ground-truth rows.
2. If no ground-truth section exists on the cited page: **UNVERIFIABLE — cited page has no canonical facts**. Flag for schema remediation.
3. If a ground-truth section exists, attempt to match the claim's subject + coordinates against row descriptions:
   - If a row matches uniquely and value agrees: **VERIFIED** (but flag as weakly-cited; row-ID citation would be tighter)
   - If no row matches: **UNVERIFIABLE — no matching canonical fact**
   - If a row matches but value disagrees: **CONTRADICTED**

**Case C — claim has no citation at all**:
1. Attempt inference from context: does the paragraph reference a specific dataset? A specific era?
2. If inference is confident, apply Case B logic against the inferred dataset/era page.
3. If inference is weak or ambiguous: **UNVERIFIABLE — uncited**. This is the largest class of problem in a freshly-audited wiki.

**Case D — claim about an ETL dataset that has no wiki page yet**:
1. Verify directly against JSON at the path declared in `wiki/CLAUDE.md` (default `apps/web/public/data/<etl>.json`).
2. If the claim matches JSON: **VERIFIED (unrooted)** — flag for schema remediation (dataset page + ground-truth section should be created).
3. If it disagrees: **CONTRADICTED**.

### Step 6: Report verdicts

```
## Wiki Audit Report

**Claims audited:** N
**Pages audited:** M (of K total wiki pages)

### Verdict counts
- VERIFIED: N (N.N%)
- CONTRADICTED: N
- UNVERIFIABLE: N
  - broken citation: N
  - no canonical fact: N
  - uncited: N
- EXOGENOUS: N

### Contradictions (highest priority)
For each:
- **Page**: `<path>` (grade: `<correctness_grade>`)
- **Claim**: <quoted prose, with line number>
- **Cited row (if any)**: `<page#row-id>` — value <row-value>
- **Primary-data value**: <JSON-derived value with coordinates>
- **Proposed resolution**: correct the prose / file ### Disputed / add missing row

### Unverifiable — broken citations
- <page>: claim cites <page#row-id> which does not exist

### Unverifiable — no canonical fact
- <page>: claim references <dataset-page> but that page lacks a ground-truth row for this value

### Unverifiable — uncited
- <page>: <quoted claim> — no citation in prose and no confident inference

### Schema violations encountered
- N dataset pages missing ## Ground truth section: <list>
- N era pages missing ## Ground truth section: <list>
- N malformed or duplicate row IDs: <list>

### Coverage
- Pages with figures_verified: <date> (clean): N
- Pages with stale figures_verified (cited dataset re-ingested since): N
- Pages never audited: N
```

**Zero-state discipline:** every count above must produce an explicit number including zero. `N=0` renders as `0`, not as omission.

### Step 7: Apply resolutions

Ask the user which categories to fix in this pass. Then apply:

**For CONTRADICTED claims:**
1. Read the cited page. Determine whether this is (a) a factual error in prose to correct, or (b) a defensible alternative reading that should become a `### Disputed` entry.
2. For (a): edit the prose to match the canonical value; append a one-line note at the end of the section referencing the audit commit.
3. For (b): file a `### Disputed` entry with both values, sources, and a short adjudication (or an explicit "not yet adjudicated" note).
4. Cross-reference every synthesis/era page that inherits the corrected claim — the correction must propagate, not just patch the first occurrence. Use `grep` on the specific numeric value across the wiki to find inheritors.

**For UNVERIFIABLE — broken citation:**
1. If the intended row exists under a different ID: update the prose citation.
2. If the intended row doesn't exist but the claim is correct: add the missing row to the cited page's `## Ground truth` section.
3. If the claim is wrong: handle as CONTRADICTED.

**For UNVERIFIABLE — no canonical fact:**
1. If the cited page should gain a ground-truth row: compute it from JSON and add.
2. If the claim is tangential or doesn't belong: delete, mark external, or move to a more appropriate page.

**For UNVERIFIABLE — uncited:**
1. If the claim traces to a wiki dataset: add the citation (row-ID preferred, page fallback).
2. If the claim traces to nothing in the wiki: mark external per the CLAUDE.md convention, or delete if the claim is not load-bearing.

### Step 8: Update `figures_verified:` frontmatter

**Strict semantics (default).** For every page that has **zero CONTRADICTED and zero UNVERIFIABLE claims** remaining after Step 7:
- Set `figures_verified: <today's ISO date>` in frontmatter.
- If the field was missing, add it.
- If the field was present and older: update it.

For pages with remaining unresolved claims, leave `figures_verified:` unchanged. The field's contract is "this page is claim-level clean as of this date"; bumping it while UNVERIFIABLE claims remain silently over-promises downstream consumers.

**Scoped-approval exception** (codified 2026-04-21). When the user explicitly scopes Step 7 approval to frontmatter-canonicalisation only (e.g., migrating non-canonical `audited:` → canonical `figures_verified:`) without resolving prose-level UNVERIFIABLE claims, bump `figures_verified:` ONLY if you simultaneously add a `figures_verified_scope:` frontmatter field documenting the narrow scope:

```yaml
figures_verified: 2026-04-20
figures_verified_scope: "schema-field canonicalisation only; N UNVERIFIABLE prose claims deferred"
```

Downstream consumers (including future `/wiki:audit` runs) MUST check `figures_verified_scope:` when present and treat the page as not-claim-level-certified. Without the scope field, never bump `figures_verified:` when UNVERIFIABLE claims remain — strict wins by default.

### Step 9: Schema health report — surface INLINE with the Step 6 verdicts

Surface the structural issues for follow-up (these are `/wiki-lint` adjacent but first-surfaced during audit). **Placement: inline with the Step 6 verdict report, NOT as a separate post-resolution block.** Codified 2026-04-21 after 2026-04-20 /wiki:audit N=1 run demonstrated that users need schema-health signals to choose Step 7 resolutions intelligently — a post-resolution block arrives too late.

Schema-health section shape (renders directly below the verdict counts in Step 6):

```
### Schema health — fidelity layer
- Dataset pages missing ## Ground truth: <count> (list)
- Era pages missing ## Ground truth: <count> (list)
- Pages without correctness_grade: <count> (default assumed by page type)
- Pages with stale figures_verified (cited dataset re-ingested after verification): <count>
- Pages with `figures_verified_scope:` (narrow-scope re-certifications pending full audit): <count>
- External-claim syntax-migration candidates (SYNTAX-FLAGGED bucket from Step 5): <count>
- External-claim markers missing where expected: <count> (approximate — flagged at Step 5 Case C rejections)
```

If any of these are non-zero, propose a follow-up pass to remediate. Do NOT fix schema violations silently in this skill — that's surface drift between audit and lint. File them for `/wiki-lint` or a targeted retrofit pass.

### Step 10: Suggest next

```
### Suggested next

#### Highest-priority follow-up
<single recommendation: usually either (a) a retrofit pass on pages missing ## Ground truth, or (b) a propagation check on a CONTRADICTED claim that may have inheritors not yet corrected>

#### Pages that need ## Ground truth retrofit
1. <dataset page name> — would unlock auditing of N downstream pages citing it
2. ...

#### Re-audit candidates
1. <page> — figures_verified stale; cited dataset <dataset> was re-ingested on <date>

#### Propagation checks
1. <corrected claim value> — grep the wiki for this value; inheritors may need matching corrections

#### Coverage
- `N audited / M journalism-grade total / K never-audited`
```

### Step 11: Update log

Append to `wiki/log.md`. **Word ceiling: ~200 words.** Dense narrative is fine below that ceiling; above it, move detail to the audit file or a companion note. Required components (cannot be omitted, even on short runs):

- Date header `## [YYYY-MM-DD] audit | <scope>`
- Claims audited count (total + per-verdict-class, reconciled — running tally must match total)
- Verdicts: V verified / C contradicted / U unverifiable (B broken-citation + F no-canonical-fact + X uncited) / E exogenous / S syntax-flagged
- Resolutions applied this pass (short description)
- Remaining unresolved (short description)
- Schema violations surfaced (dataset + era pages missing ground-truth, syntax-migration candidates, stale figures_verified)
- Pages with `figures_verified:` updated (list)
- Pages with `figures_verified_scope:` added (list, if any)
- Created: 0 (audit doesn't create new pages). Updated: P.
- Pages: <comma-separated>

Template:

```
## [YYYY-MM-DD] audit | <scope>

Audited N claims across M pages. Verdicts: V verified / C contradicted / U unverifiable (B broken-citation + F no-canonical-fact + X uncited) / E exogenous / S syntax-flagged. Reconciled: V+C+U+E+S = N ✓ (no tally drift).
Resolved this pass: <short description>. Remaining: <short description>.
Schema violations: G dataset pages missing ground-truth, H era pages missing ground-truth, I syntax-migration candidates, J stale figures_verified.
Pages with figures_verified updated: <list>. figures_verified_scope added: <list or "none">.
Created: 0. Updated: P.
Pages: <comma-separated>
```

Codified 2026-04-21 after 2026-04-20 N=1 run produced a ~500-word paragraph-form entry that drifted from the template's terse ideal.

### Step 12: Commit

```bash
cd wiki && git add -A && git commit -m "audit: <scope> — <key resolutions>"
```

---

## Invocation patterns

**Full audit** (one-shot sweep):
```
/wiki-audit
```
Audits every page in priority order. Intended for the initial sweep to establish a clean baseline, and for periodic re-audits.

**Scoped audit** (after targeted work):
```
/wiki-audit <page-path-or-glob>
```
Examples: `/wiki-audit synthesis/thatcher-economic-legacy`, `/wiki-audit eras/`, `/wiki-audit datasets/gilts`. Useful after a `/wiki-query` or `/wiki-ingest` touches specific pages — audit the touched pages before their claims compound.

**Dataset-triggered audit** (after re-ingest):
```
/wiki-audit --dataset <name>
```
Re-audits every page that cites the named dataset. Use after `/wiki-ingest` re-processes a dataset — all downstream pages' `figures_verified:` is now stale.

## Interaction with other skills

- **After `/wiki-ingest`**: run `/wiki-audit --dataset <name>` to re-certify downstream pages.
- **After `/wiki-query`**: run `/wiki-audit <touched-pages>` to catch propagation errors before they compound.
- **Before `/wiki-reflect`**: audit the synthesis page first. Reflect stress-tests conjectures under the assumption that figures are correct; auditing first means reflect's work isn't invalidated by a subsequent figure correction.
- **Before `/story-map:integrate`**: the `figures_verified:` field should gate integrate consumption (same pattern as `stress_tested:`). If the field is missing or stale, integrate refuses — analogous to how integrate currently refuses un-stress-tested synthesis.

## Source epistemology — what this auditor can and cannot catch

Per the wiki's own principle that every source has biases worth surfacing, the auditor itself has epistemic limits:

| Can catch | Cannot catch |
|-----------|--------------|
| Numeric claim disagrees with cited ground-truth row | Numeric claim is correct in the ground-truth row but the ground-truth row was computed incorrectly from JSON |
| Claim cites a non-existent row | Claim is precise and correct but the JSON itself is wrong (source data error) |
| Claim lacks citation and inference fails | Claim is citation-free but still correct (high false-UNVERIFIABLE rate on freshly-audited wikis) |
| Claim is marked external when it shouldn't be | Claim is marked external when it should be a real ground-truth row (marking-as-external hides a coverage gap) |
| Ground-truth row value disagrees with JSON (if auditor re-computes from JSON) | Ground-truth row's *coordinates* are wrong (right value, wrong date) — requires schema enforcement beyond what this skill does |

**Recommended mitigations** (not enforced by this skill, but worth naming):
- Periodic `/wiki-audit --recompute-ground-truth` pass that re-derives rows from JSON rather than trusting them. Cheap and high-signal; should probably run on each JSON re-ingest.
- Ground-truth rows should include the JSON coordinates (sheet/row/column or path) so re-computation is deterministic.
- `/wiki-reflect`-adjacent stress-tests on the coordinates themselves — does the "all-time high" row's coordinate survive a check that the dataset's entire span was scanned, not just a subset?

## Why this skill is separate from `/wiki-lint`

Lint checks structure; audit checks claims. They share discipline (zero-state rendering, pipeline summary, suggested-next) but target distinct invariants:

- Lint catches: broken links, orphan pages, missing frontmatter, stale scaffolds, missing schema-mandated sections.
- Audit catches: factual claims in prose that disagree with primary data.

A page can pass lint (structure perfect) and fail audit (claims wrong). A page can fail lint (missing ground-truth section) and consequently be unaudited (the audit can't diff against a missing canonical table). The two skills are complementary; neither subsumes the other.

## Why this skill exists at all

The Karpathy wiki pattern promises that **"the cross-references are already there. The contradictions have already been flagged. The synthesis already reflects everything you've read."** That promise is a write-time guarantee. Without a mechanism that enforces it, the guarantee is aspirational, and a data-heavy wiki like uk-legalize — whose entire value proposition rests on journalism-grade factual accuracy — silently accumulates claim-level errors that compound through every subsequent query and synthesis.

`/wiki-audit` is the enforcement mechanism. Without it, the pattern collapses back into confident-sounding RAG.

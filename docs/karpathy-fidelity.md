# Karpathy Wiki — Claim Fidelity

Diagnosis of the write-time correctness invariant the Karpathy LLM Wiki pattern depends on. Names the precondition, maps the defensive surfaces a wiki system already has, and prescribes the architectural invariants required for the pattern to work at data-heavy scale.

**This is a blueprint.** Projects using `llm-wiki-os` specialize via a companion overlay at `thoughts/architecture/wiki-claim-fidelity.md` (or equivalent project-local path). See the *"How projects specialize"* section at the end.

Related blueprints:
- `cleaning-gates.md` — the four-gate model (`/wiki:lint` → `/wiki:audit` → `/wiki:reflect` → `/wiki:coherence`) that enforces this invariant at run-time
- `prompt-engineering.md` — the skill-iteration methodology and N=2 codification rule that governs how blueprints evolve

Related skills: `llm-wiki-os/commands/audit.md` — the specific skill file that enforces the contract this blueprint diagnoses.

---

## The Karpathy-invariant framing

Karpathy's wiki pattern trades RAG's re-derivation-per-query for **compile-once-keep-current**. The key phrase from the pattern document:

> *"The knowledge is compiled once and then kept current, not re-derived on every query... The cross-references are already there. The contradictions have already been flagged. The synthesis already reflects everything you've read."*

The phrase **"already there"** is load-bearing. It is the entire value proposition. If a reader has to re-verify wiki claims against primary sources on every read, the wiki has collapsed back into RAG with extra steps.

**Write-time fidelity is therefore not a defensive surface. It is the invariant the whole architecture depends on.** A wiki that claims to know but has unverified numeric claims is strictly worse than RAG — at least RAG stays honest about deriving on demand. The wiki silently propagates confident error.

Any concrete claim-propagation incident that reaches a reader is not a corner case. It is the pattern silently failing to deliver on its central promise. The same force that makes the wiki valuable when correct — compounding cross-references, synthesis reflecting everything upstream — makes errors catastrophic when present, because they compound through the same cross-references.

## Why data-heavy wikis need more enforcement than interpretation-heavy ones

Karpathy's worked examples are interpretation-heavy: book companions, research wikis, personal journals. A Tolkien wiki that mis-states a character's eye colour is annoying, not catastrophic. The wiki's job is to structure ideas.

**Data-heavy wikis** — accountability trackers, financial dossiers, scientific datasets, anything where numeric claims are attributed to real-world entities — have the opposite failure mode. Every claim like *"Entity X hit value Y at time Z, attributed to actor W"* is either factually true or false. A wrong claim is not just a knowledge-base bug. It can be libel-adjacent: the wiki says a named actor did a specific thing that didn't happen.

This argues for **over-investing in the fidelity layer** relative to a generic Karpathy implementation. The correctness grade has to match the output grade. A wiki that makes journalism-grade or research-grade claims needs a fidelity discipline that matches.

## The three-layer compilation model

The Karpathy pattern is really a three-layer compilation. Wikis that implement layers 1 and 3 but leave layer 2 implicit are exactly where errors slip in.

```
Layer 1: Primary sources (immutable)
    Dataset files (JSON, CSV), raw archives (xlsx cache, scraped HTML)
    ↓ compile
Layer 2: Canonical facts (machine-parseable, deterministic)
    ## Ground truth sections on dataset pages + era/entity pages
    ↓ derive
Layer 3: Synthesis prose (narrative, interpretation, cross-references)
    Dataset page narrative, era/entity page narrative, synthesis pages,
    concept pages, event pages, overview
```

**What goes wrong when layer 2 is implicit:**
- Layer 3 prose is authored by reading layer 1 directly (via LLM) or by recalling from training (worse)
- Any numeric claim in layer 3 has no structural home to trace back to
- An auditor trying to verify layer 3 has to reconstruct layer 2 from scratch on every run
- Errors in layer 3 are indistinguishable from correct prose unless the reader re-derives from layer 1

**What layer 2 looks like when made explicit:** a `## Ground truth` section near the top of every dataset page and every era/entity page. Schema-bounded rows with stable IDs. Example for a dataset page:

```markdown
## Ground truth

Computed from `<primary-source-path>` at <ISO-date>.

| ID | Fact | Value | Coordinates |
|----|------|-------|-------------|
| `<dataset>.all-time-high`    | All-time peak value               | <value> | <time> |
| `<dataset>.all-time-low`     | All-time trough value             | <value> | <time> |
| `<dataset>.<era>-peak`       | Era-specific peak                 | <value> | <time> |
| `<dataset>.<era>-start`      | Value at era inauguration         | <value> | <time> |
| `<dataset>.<era>-end`        | Value at era exit                 | <value> | <time> |
```

And on a page authoring a claim:

```markdown
<Era>-era <metric> peaked at <value> in <time>
(citing [[datasets/<dataset>#<dataset>.<era>-peak]]) —
not an all-time high, which was <other-value> in <other-time>
(citing [[datasets/<dataset>#<dataset>.all-time-high]]) under <other-era>.
```

Any claim that doesn't trace back to a row ID is either:
- **External / exogenous** — must be explicitly marked as not-in-wiki context
- **Unverified** — pending audit
- **Wrong** — the row ID says something different

This converts the auditor's job from an LLM-judgment task (*"is this figure plausible?"*) to a deterministic diff (*"does claim X cite row Y? does row Y match the primary source?"*).

## Two failure subclasses

Inside the fidelity gap, two distinct classes, requiring different defences:

**(A) Intrinsic errors — "tight" gap.** A wiki page states a figure that disagrees with the dataset it is citing. Example shape: an era page claims *"metric peaked at X% — the highest in the N-year series"*, but the underlying primary data shows the all-time high was a different value under a different era, with the current era's peak actually lower. Catchable by programmatic diff between wiki prose and the ground-truth table.

**(B) Exogenous claims masquerading as findings — "wide" gap.** A wiki page states a figure that is not in any wiki dataset at all — training-recall presented as wiki knowledge. Example shape: *"unemployment peaked ~11% in 1984"* on an era page when no unemployment dataset is ingested. Catchable by a structural rule: **any numeric claim must cite a ground-truth row OR be explicitly marked external.**

**(C) Third subclass, watched but not primary target yet:** interpretive claims that violate lens-plurality, dispersal, or source-epistemology conventions. Partially defended already by `/wiki:reflect` and `/wiki:lint`. Out of scope for the first auditor pass.

## Surface map

Every existing defensive surface in the standard wiki kit, what it defends, what it is blind to:

| Surface | Defends against | Blind to |
|---------|----------------|----------|
| `wiki/CLAUDE.md` conventions (static) | Silent single-answer analysis; unannotated links; missing `### Disputed` sections; undocumented splice/coverage/overlap discontinuities | Enforcement relies on authorship discipline. A page claiming "X" with confidence can satisfy every convention and still be false. |
| `/wiki:discover` | Approving bad sources; approving data that can't answer the question | Pre-existing errors on wiki pages. Discover surveys sources, not claim accuracy on already-ingested pages. |
| `/wiki:ingest` source-epistemology | Ingesting a biased or methodologically-flawed source without noting the bias | Whether the prose the author writes on top of ingested data accurately reads the data. Ingest authors numbers into prose; no automatic primary-source-consistency check. |
| `/wiki:query` wiki-first preference | Re-deriving answers from raw primary sources when the wiki should already know (the Karpathy compounding rationale) | Treats confident wiki-page claims as correct. Propagates errors at query time with the same confidence the wiki page had. |
| `/wiki:lint` | Broken links; orphan pages; missing frontmatter fields; stale scaffolds; silent zero-state in count checks | Does not open primary sources to diff against wiki prose. A structurally perfect "peak was X" that disagrees with the dataset passes lint. |
| `/wiki:reflect` seven-lens falsification | Unfalsified CONJECTURES — causal narrative claims that haven't been stress-tested | Targets causal claims, not figures. "Metric peaked at X in year Y" is a fact to verify, not a conjecture to stress-test. Protocol is orthogonal. |
| `stress_tested:` frontmatter contract | Downstream skills consuming un-stress-tested synthesis | Only gates stress-test status. No analogous contract for figure fidelity. |
| `### Disputed` section convention | Known source contradictions being hidden | Requires the author to already know a contradiction exists. An author who doesn't notice the disagreement never files the section. |

**The gap, named precisely:** the standard wiki system has no continuous or on-demand mechanism that diffs specific numeric claims in wiki prose against primary data. Errors are caught incidentally (reader pushback, author noticing a contradiction) or not at all.

`/wiki:audit` fills this gap. See `cleaning-gates.md` for its role in the four-gate cleaning model.

## Compounding risk by page type

Not all pages carry the same stakes when they contain an error:

| Page type | Compounding risk | Why |
|-----------|------------------|-----|
| `overview.md` | VERY HIGH | Entry point for the entire wiki; errors become canonical narrative. |
| Dataset pages | HIGH | Most-linked surface; authoritative "what this dataset says." Errors propagate to every synthesis, era, concept that cites them. |
| Era / entity pages | HIGH | Consolidate claims across multiple datasets; errors compound across all of them. Cited by synthesis and concept pages. |
| Synthesis pages | MEDIUM-HIGH | Downstream of other pages but read by `/wiki:query` and referenced by downstream consumer skills. Errors propagate to product / strategy layers built on top. |
| Concept pages | MEDIUM | Cross-cut eras but usually less numeric. |
| Event pages | LOW-MEDIUM | Narrower scope; often date-anchored. |
| Entity pages (biographical) | LOW | Few numeric claims. |

The auditor's prioritisation reflects this: dataset pages and era/entity pages are the load-bearing surfaces because they are both highly-linked AND the natural home for layer-2 ground-truth tables; `overview.md` is the broadcast amplifier.

## Entry points for errors

Four entry points, each with distinct prevention levers:

1. **Ingest authorship** — dataset page written with wrong numbers (*"key observations"* pulled loosely from source rather than computed from primary data).
2. **Era / entity page seeding** — era pages summarising what multiple datasets show during a period; numbers can come from training-recall rather than primary-source reads.
3. **Synthesis creation** — cross-dataset analysis inherits claims from upstream pages without re-verifying.
4. **Query time** — `/wiki:query` produces new prose that cites wiki pages or falls back to primary sources; errors can enter at either step.

Subclass (A) errors enter at any of the four. Subclass (B) errors typically enter at 2 and 3 — where the author-model is most tempted to fill gaps with training knowledge rather than citing the wiki's actual data.

## The frontmatter contracts

Two frontmatter fields codify the fidelity discipline:

```yaml
figures_verified: <ISO-date>    # date of last /wiki:audit pass
                                # analogous to stress_tested:
correctness_grade: journalism   # journalism | interpretive | exploratory
```

**`figures_verified:`** — set by `/wiki:audit` when the page passes a clean audit against its ground-truth table. Missing or stale (older than cited dataset last-ingest) means the page's numeric claims are unverified.

**`correctness_grade:`** — declares the rigor the page claims:

| Grade | Meaning | Default page types |
|-------|---------|---------------------|
| `journalism` | Every numeric claim cites a ground-truth row OR is explicitly marked external. Factual disagreement with primary data is a defect. | Dataset pages, era/entity pages, overview, event pages with named attributions |
| `interpretive` | Numeric claims cite ground-truth rows transitively (through cited dataset/era pages). Lens-dependent analysis. Factual errors still defects; interpretive disagreement is expected. | Synthesis pages, concept pages, question pages |
| `exploratory` | Work-in-progress; claims may be un-sourced. Not consumed by downstream skills. | Stub pages, backlog entries, draft pages |

Downstream consumer skills may refuse pages below a minimum grade — analogous to how the existing `stress_tested:` contract works.

## Candidate mechanisms (design space, for reference)

Five shapes a solution could take. Each addresses different parts of the surface map.

| # | Mechanism | Addresses | Cost | Prevents new / fixes existing |
|---|-----------|-----------|------|-------------------------------|
| 1 | `/wiki:audit` skill — batch claim-checker | (A) primarily; (B) via "claim cites no ground-truth row" detection | Low | Fixes existing (on demand) |
| 2 | Query-time / ingest-time guard | (A) at entry points 1, 3, 4 | Medium | Prevents new |
| 3 | Machine-parseable claim-linking schema | (A) and (B) cheaply after adoption | High upfront (page rewrites) | Prevents new; enables cheap re-audits |
| 4 | Extend `/wiki:reflect` with figure-verification pass | (A) on synthesis pages | Low-medium | Fixes existing on reflect cadence |
| 5 | Ground-truth tables on dataset + era/entity pages | (A) and (B) at entry points 1 and 2 | Medium (convention + backfill) | Prevents new at source |

**After the Karpathy upgrade, mechanism 5 is no longer one option among five. It is the architectural foundation the other mechanisms rely on.** Mechanism 1 is the enforcement layer built on top of it. Mechanism 3 is the long-run evolution of mechanism 5 toward more machine-parseable formats. Mechanism 2 becomes cheap once mechanisms 1 and 5 are in place. Mechanism 4 is probably absorbed by mechanism 1 rather than built separately.

## Build order

1. **Codify the schema contracts** — add `## Ground truth` section, `figures_verified:`, and `correctness_grade:` conventions to `wiki/CLAUDE.md`. Before any skill can depend on these, the schema has to document them.
2. **Build `/wiki:audit` as the enforcement skill** — shipped in the generic wiki kit at `llm-wiki-os/commands/audit.md` (reads `wiki/CLAUDE.md` for project-specific specialization per existing convention). Steps: enumerate pages → extract claims → diff against ground-truth rows → report verdicts → update frontmatter on pass.
3. **Retrofit `## Ground truth` on existing data-heavy pages** — dataset pages and era/entity pages. Computed from primary sources. Iterative pass, not one-shot; run `/wiki:audit` after each page to confirm.
4. **Retroactively audit every existing data-heavy page** — one-shot sweep that catches accumulated errors. After this, the wiki's figure-fidelity is a known-clean baseline.
5. **Integrate the contract into consumer skills** — downstream consumer skills gain a `figures_verified:` precondition alongside `stress_tested:`. `/wiki:query` uses the contract to distinguish known-verified pages from unverified ones in its answer confidence.
6. **Deferred**: mechanism 3 (machine-parseable claim-linking) stays deferred until mechanism 1 + 5 is exercised and we can see whether the markdown-row-ID format is sufficient or whether a richer schema is needed.
7. **Deferred**: mechanism 2 (query-time guard) stays deferred until the auditor exists and its failure modes are known.

## Open questions

- **Claim extraction method**: LLM extraction with structured output (robust, higher token cost) vs regex-on-numeric-patterns (cheap, brittle) vs enforced citation schema (requires rewriting). The skill draft picks one; this blueprint notes the trade.
- **Ground-truth row coverage**: which facts should be canonical? Peaks, troughs, start/end values, inheritance/exit values for each era are obvious. Beyond that is judgment — err on the side of including a row rather than leaving an implicit claim un-sourceable.
- **Stale-verification policy**: should `figures_verified:` expire when the cited dataset is re-ingested? Probably yes — the ground-truth table changes, so prose that was verified against the old table is now unverified. Formalise in the audit skill.
- **External-claim marking syntax**: how should exogenous claims be visually marked in prose so the auditor recognises them? Options include an inline marker like `{{external: <claim>}}` or a section-level `### External context` that the auditor skips. Skill decides.

## Three-artifact principle

Three files, three jobs:

- **N=1 pattern observation** — project-local log (e.g., `thoughts/architecture/emergent-capabilities.md` in the reference implementation). Stays terse, cites this blueprint for the diagnosis.
- **This blueprint** — the diagnosis. Generic. Evolves as mechanisms ship across projects; new failure subclasses append here via elevation (see *"How projects specialize"*).
- **The prescription** — specific skill file (`llm-wiki-os/commands/audit.md`) with steps, input/output formats, invocation contract.

Keep each pure. Don't move prescription into the diagnosis; don't move diagnosis into the emergent log.

## Why this matters more than it looks

A wiki's value proposition rests on being trustworthy enough that the primary user reaches for it instead of external search plus manual cross-checking. A single propagated factual error in a public-facing era page would:

- Break the primary user's own trust in the wiki
- Cascade through synthesis pages, queries, and potentially published outputs built on the wiki
- Compound invisibly because the pattern makes confident writing indistinguishable from correct writing

The cost of the fidelity layer is bounded (one skill, two frontmatter fields, a schema update, a one-shot retrofit). The cost of not having it is unbounded: every future claim is a potential incident waiting for reader pushback. The investment calculus is clean.

---

## How projects specialize

Projects using `llm-wiki-os` create a companion overlay at a project-local path (by convention: `thoughts/architecture/wiki-claim-fidelity.md`). The overlay cites this blueprint and adds **only** project-specific content:

- **Motivating incidents** — specific cases where fidelity gaps surfaced in this project, with dates and commit references
- **Domain-specific stakes argument** — why this particular wiki needs enforcement (e.g., libel risk for accountability wikis, reproducibility for research wikis, audit-trail for financial wikis)
- **Concrete row-ID examples** — using the project's actual dataset and era/entity names (replacing the abstract `<dataset>.<era>-peak` placeholders in this blueprint)
- **Integration points with project-specific consumer skills** — e.g., `/story-map:integrate` in a product-strategy project, `/release-gate:check` in a research-publication project
- **Build-order progress** — which of the 7 build-order steps this specific wiki has completed
- **Schema additions on top of the generic contracts** — any project-local frontmatter fields that sit alongside `figures_verified:` and `correctness_grade:`

The overlay stays thin. If you find the overlay growing into a second full diagnosis, that's a signal the content belongs in the blueprint (see elevation below).

### Candidates for upstream elevation

When the project's overlay accumulates content that turns out to be generic — observed across multiple projects, OR recognized as a pattern not specific to this project — propose upstream elevation:

1. The overlay names the candidate in its own *"## Candidates for upstream elevation"* section, with a brief rationale for why it might be generic.
2. `/meta propose-edit llm-wiki-os/docs/karpathy-fidelity.md` (or equivalent authorised tool) drafts the blueprint absorption — what moves up, where it goes in the blueprint's section structure, what stays behind in the overlay.
3. User approval → commit to `llm-wiki-os`. Same commit or follow-up: overlay thins, removing the elevated pattern and citing the new blueprint section.

This is the doc-level equivalent of the N=2 codification rule for skill files (see `prompt-engineering.md` for the full methodology).

---

## Notes on this blueprint's own evolution

- Subsequent re-occurrence of the underlying pattern (N=2) in any project using this blueprint should reference back to this diagnosis rather than re-deriving it. N=2 observations propose elevations, not new blueprints.
- If the first mechanism shipped in any project reveals additional failure subclasses not captured above, append to this document rather than opening a sibling doc.
- This document is expected to outlive any specific skill implementation. The mechanisms will evolve; the diagnosis is the canonical reference.

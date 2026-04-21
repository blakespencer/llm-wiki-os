# Source Epistemology

Popper applied to the *input* layer, not just the output layer. Not all sources are equal, and a Karpathy-pattern wiki should be skeptical of its own inputs — not only of its own conclusions. Names the 7 questions to ask of every source, the source-type skepticism-spectrum table *structure* (each project instantiates with its domain's specific institutions), the `### Source assessment` section convention, and the "right grip" principle.

**This is a blueprint.** Projects using `llm-wiki-os` specialize via their `wiki/CLAUDE.md` schema (the source-type skepticism-spectrum table with project-specific institutions, example citations) and optionally an overlay at `thoughts/architecture/source-epistemology.md`. See the *"How projects specialize"* section at the end.

Related blueprints:
- `karpathy-fidelity.md` — write-time correctness for claims the wiki authors. Source epistemology is its complement at the *input* side (before a claim is authored).
- `philosophical-framework.md` — the Popperian ceiling applies to every interpretation AND every source.
- `data-quality-discontinuities.md` — the three data-issue categories (splice / coverage / overlap) are where source epistemology manifests in specific dataset pages.
- `cleaning-gates.md` — source epistemology fires at `/wiki:discover` (accepting a source) and `/wiki:ingest` (absorbing it); the cleaning gates fire post-ingest to catch what source-epistemology couldn't prevent.

Related skills: `llm-wiki-os/commands/{discover,ingest}.md` — discover proposes new sources; ingest applies source epistemology when absorbing data.

---

## Why source epistemology matters

Every source has:

- **A methodology** — how was the data produced? Survey, administrative records, model output, expert judgment?
- **An incentive structure** — who benefits from this data showing a particular result?
- **A track record** — has this source been revised, challenged, or discredited before?

Wiki pages that cite sources without examining these three carry imported biases the wiki is unaware of. An ingested source shapes every downstream synthesis that cites it. Skepticism at the input layer is cheaper than debugging at the synthesis layer.

## Source-type skepticism-spectrum (generic structure)

The *table structure* below is generic; the *rows* are domain-specific and each project instantiates with its own institutions. For a macro-economic wiki the rows are ONS / BoE / academic researchers / regulators / government departments / campaign groups / consultancies / journalism / social media. For a health wiki they might be peer-reviewed journals / regulatory agencies / industry-funded studies / patient advocacy groups / medical news sites / social media. The structure is the same:

| Source type (domain-specific) | Methodology | Incentive | Skepticism level |
|-------------|-------------|-----------|-----------------|
| **Institutional statistics** (the official measurement bodies in the domain) | Rigorous, transparent, quality-standards-bound | Politically/institutionally independent, but WHAT they choose to measure (or stop measuring) reflects priorities | Low — trust the numbers, question the coverage |
| **Academic research** (peer-reviewed, replicable-in-principle) | Peer-reviewed, replicable | Reputational incentive toward novel/provocative findings. Publication bias toward significant results. | Low-medium — trust the method, read the limitations |
| **Regulators / investigators** (whose job is to find problems) | Investigatory, evidence-based | Their job is to find problems — so they'll find them. A regulator that found nothing would question its own existence. | Medium — trust the evidence, question the framing |
| **Government / administrative bodies** (politically accountable) | Administrative data, politically accountable | What they publish (and don't publish) reflects stakeholder priorities. Headline stats can be chosen to flatter. | Medium — trust the raw data, question the presentation |
| **Campaign groups / advocacy organisations** (curated, position-driven) | Curated, selective | Data is chosen to support a pre-determined conclusion. Not lying — *selecting*. | Medium-high — useful leads, but always check the underlying source |
| **Commercial consultancies** (proprietary methodology) | Proprietary methodology, limited transparency | Selling to industry clients. Their incentive is to make the market look complex (justifies fees). | Medium-high — useful for benchmarks, not for causal claims |
| **News / journalism** (secondary reporting, variable rigour) | Secondary reporting, variable rigour | Editorial line, audience expectations, attention incentives. Even quality journalism selects and frames. | High — use as leads to find primary sources, not as sources themselves |
| **Social media / blogs** (unverified, no quality control) | Unverified, no quality control | Attention, ideology, influence | Very high — almost never cite directly. Find the primary source they reference. |

**The table is orientation, not classification.** Source types blur and every specific source needs its own deep assessment (see 7 questions below). The table tells you where to start; the questions tell you how to go deep.

**Project adaptation**: your domain's institutions may not fit these generic categories cleanly. A clinical-research wiki's "regulators" role is played by FDA/EMA; its "academic research" splits into RCTs vs observational studies vs mechanistic biology with different skepticism levels each. Instantiate the table in your `wiki/CLAUDE.md` with rows matching your domain's actual source landscape.

## The 7 questions to ask of every source

Don't just classify a source as *"official body = trustworthy"* and move on. For each specific dataset or claim:

1. **Methodology**: How was this number produced? Survey, administrative records, model, expert judgment? What assumptions does it make? Did the methodology change over time — and if so, does that create a splice discontinuity?
2. **Definitions**: What exactly is being measured? The same concept-name can mask different operational definitions (e.g., "productivity" per worker vs per hour; "output" by volume vs value). Definition determines conclusion.
3. **What's NOT measured**: What did they choose to leave out? Absence of data is itself informative — *why* isn't this measured? Under-measurement is often politically/institutionally meaningful.
4. **Who commissioned it and why**: Official studies exist because someone asked for them. Who? What were they hoping to find? Campaign-group reports exist because an advocacy position wants evidence. The data may be accurate but the *selection* is not neutral.
5. **Who benefits from this conclusion**: If this data shows X, who gains? Follow the incentive. Two parties can agree the data is accurate while reading different conclusions from it.
6. **Revisions and controversies**: Has this data been revised? Challenged by other researchers? Has the methodology been criticised? Official statistics have been revised years after publication. Academic findings fail to replicate. What's the track record?
7. **Comparison sources**: Is there another source measuring the same thing differently? If so, compare them (see `data-quality-discontinuities.md` — overlap-divergence category). Disagreement between sources is informative.

**The goal is not to reject sources but to hold them with the right grip** — tight enough to use, loose enough to doubt. A source can be useful AND biased simultaneously. The wiki should use it AND note the bias.

## The `### Source assessment` section convention

Dataset pages and ingested-source pages should include a `### Source assessment` section applying the 7 questions to the specific source. Template:

```markdown
### Source assessment

**Source**: <specific publisher + series name>

**Methodology**: <brief description of how the data is produced>

**Definitions**: <what exactly is measured; any definitional choices that shape the result>

**What's not measured**: <coverage gaps relative to the wiki's questions>

**Commissioner / motivation**: <who published this and why>

**Beneficiaries of the conclusion**: <who is advantaged if this data reads a certain way>

**Revisions / controversies**: <known revisions, methodological criticisms>

**Comparison sources**: <alternate sources measuring the same thing; overlap behaviour if known>

**Grip**: <one-paragraph stance — how tightly the wiki should treat this source's
claims; what to trust, what to question>
```

The section is **not bureaucracy** — it's intellectual honesty at the input layer, not just the output layer. A dataset page without this section cites sources at face value; a page with it holds them calibrated.

## When source epistemology fires in the pipeline

- **`/wiki:discover`** — when proposing a new data source, apply the 7 questions to decide whether the source is worth ingesting at all. Some sources are too low-signal-to-noise; some are biased in ways that make their data actively misleading. Surface both in the discovery report.
- **`/wiki:ingest`** — when absorbing a new dataset, author the `### Source assessment` section as part of the dataset page. Do it during ingest; retrofitting later is where this discipline rots.
- **`/wiki:reflect`** — when stress-testing conjectures, check whether the conjecture depends on a single source whose bias is unmarked. "Only this one dataset supports this claim, and that dataset's methodology has a known direction" is a stress-test failure.

## Non-goals (explicit scope boundaries)

- **Don't reject sources wholesale.** The 7 questions calibrate, not filter. A biased source can still be useful if the bias is noted.
- **Don't collapse to a skepticism-number.** *"Source X = 6/10"* is not source epistemology. The goal is holding the source *with the right grip*, not producing a trust score.
- **Don't apply source epistemology only to sources you disagree with.** Apply it to sources you agree with — they're the ones whose biases you're likely to miss.

---

## How projects specialize

Projects using `llm-wiki-os` specialize this blueprint in their `wiki/CLAUDE.md` schema (and optionally an overlay at `thoughts/architecture/source-epistemology.md`). Specialization includes:

- **Domain-specific source-type table** — rows matching the project's actual source landscape (e.g., FDA/EMA for clinical-research; SEC filings / analyst reports / trade press for startup due-diligence; peer-reviewed / preprint / policy-brief / op-ed for social science).
- **Project-specific 7-question answers for canonical sources** — the recurring sources this wiki cites repeatedly should have a pre-worked `### Source assessment` section on their dataset pages, so later pages can cite without re-deriving.
- **Domain-specific grip adjustments** — some domains need extra skepticism on a specific source-type (e.g., clinical wiki: extra skepticism on industry-funded RCTs; macro wiki: extra skepticism on think-tank policy briefs).
- **Project-specific discovery integration** — how `/wiki:discover` surfaces source-epistemology flags in its discovery reports.

### Candidates for upstream elevation

When specialization accumulates content that's generic rather than domain-specific, propose upstream elevation. Doc-level equivalent of N=2 rule (see `prompt-engineering.md`).

---

## Notes on this blueprint's own evolution

- The 7 questions are foundational. They're not optimized for any specific domain; they're asking what it always takes to hold a source calibrated. Adding an 8th question should require observation across multiple projects.
- The table is structure-not-content. If a project finds a *category* of source the table doesn't have (e.g., "AI-generated data" as a distinct category), the category belongs in the blueprint once it's observed in a second project.
- "Right grip" is the animating metaphor. Changes should preserve it — if a change implies "tight grip = good, loose grip = bad" or vice versa, it's misreading the principle.

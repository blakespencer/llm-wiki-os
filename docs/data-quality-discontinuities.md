# Data Quality Discontinuities

Three categories of data-quality issues that should ALWAYS be documented on dataset pages of a Karpathy-pattern wiki: **splice discontinuities**, **coverage gaps**, and **overlap divergence**. Without these documentations, the wiki may silently make claims that are only true within a dataset's range / splice / source, not in reality. Short blueprint; the discipline is generic across any data-heavy wiki (financial, scientific, historical, clinical).

**This is a blueprint.** Projects using `llm-wiki-os` specialize via their dataset pages (each dataset's specific splice/coverage/overlap situation) and optionally an overlay at `thoughts/architecture/data-quality-discontinuities.md` if the domain has additional discontinuity categories worth noting. See the *"How projects specialize"* section at the end.

Related blueprints:
- `karpathy-fidelity.md` — claim-level fidelity; this blueprint is its complement at the data-quality-documentation layer
- `source-epistemology.md` — source-level skepticism; data-quality discontinuities are where source decisions (splicing, coverage choices) become visible in the dataset
- `cleaning-gates.md` — `/wiki:lint` should flag dataset pages missing required discontinuity sections

Related skills: `llm-wiki-os/commands/{ingest,lint,audit}.md` — ingest authors the sections; lint flags missing sections; audit uses them to interpret claims correctly.

---

## Why this matters

A wiki that makes claims like *"all-time high: X"* or *"peak during era Y: Z"* is making statements that are only true within the dataset's range, splice, and source choice. Without explicit discontinuity documentation:

- *"All-time high"* is actually *"highest value in this dataset"* — not "highest value that ever occurred"
- *"The series peaks at Y"* becomes misleading if the series splices two source methodologies at year X
- *"The two sources agree"* becomes false if overlap divergence is undocumented

These are not edge cases. They're the default failure mode for data-heavy wikis. The three categories below are the documentation discipline that catches them.

## Category 1: Splice discontinuities

**What**: when a dataset splices multiple source series into one time series (e.g., a financial series that splices early-century bond data with modern bond data at a breakpoint year, or a health series that splices diagnostic definitions across a classification change).

**Why dangerous**: the splice point introduces a measurement jump that has nothing to do with the underlying reality. Claims like *"biggest move in the series"* can accidentally land on the splice jump rather than on a real event.

**Documentation discipline**: each splice point MUST be documented as a `### Disputed` section (or equivalent) on the dataset page. The section should note:

- **What changes at the splice** (source, methodology, definition)
- **How large the measurement jump is** (quantified, not narrative)
- **What it means for comparability** (can you compare pre-splice values with post-splice? In what range? With what caveat?)

Example shape (abstracted from uk-legalize's gilts dataset):

```markdown
### Disputed — splice point <year>

Pre-<year>: <source A, methodology A, definition A>
Post-<year>: <source B, methodology B, definition B>
Splice-year jump: <quantified measurement difference>

Comparability: <when it's OK to compare across, when it's not>.
```

## Category 2: Coverage gaps

**What**: when a dataset ends before the present day, or starts after a significant historical event, or has holes in its time range.

**Why dangerous**: the wiki may confidently state *"all-time low"* when the actual all-time low falls outside the dataset's range. Example: a bank-rate series ending at year X misses any post-X lows (and highs). A CPI series starting at year Y misses the pre-Y high inflation period.

**Documentation discipline**: the dataset page must note:

- **Start date / coverage range** — the dataset's actual span
- **Known-significant events outside the range** — events the wiki might reference that fall outside the dataset's coverage
- **Re-phrasing rules for claims**: *"all-time high in this dataset = X"* rather than *"all-time high = X"* when coverage is partial

Example shape:

```markdown
### Coverage

This dataset spans <start> to <end>. Known-significant events outside this range:
- <event A>, <date> — predates dataset start
- <event B>, <date> — postdates dataset end (e.g., <later low> in <year> is NOT in this series)

Claims on this page should be qualified: *"<X> in this dataset's range"* rather
than *"all-time <X>"*, unless the claim is explicitly about pre- or post-coverage
reality (in which case cite the external source).
```

## Category 3: Overlap divergence

**What**: when two datasets from different sources cover the same period. They will almost always disagree in the overlap — question is direction and magnitude.

**Why dangerous**: silent overlap divergence is the "which source is right?" question lurking under every claim. If one dataset says peak = X and another says peak = Y, the wiki needs to have an explicit position, not silent ambiguity.

**Documentation discipline**: compare the two datasets in the overlap period. Document:

- **Overlap range** — the years both cover
- **Direction of difference** — systematically higher/lower, or random?
- **Magnitude** — quantified (%, absolute units)
- **Likely cause** — methodology difference, coverage definition, survey vs administrative, etc.
- **Which source the wiki cites in prose** — and why

Example shape:

```markdown
### Overlap with <other dataset>

Overlap period: <start> to <end>.
Direction: <dataset A> is systematically <higher/lower> by <X%> in this period.
Cause: <methodology / definition / source difference — specific, not "they measure
differently">.
Citation rule: this wiki cites <A> for <use-case> and <B> for <other use-case>,
because <reason>.
```

## Lint enforcement

`/wiki:lint` should flag dataset pages missing the relevant section:

- Any dataset with multi-source splicing → missing splice-discontinuity section is a lint failure
- Any dataset whose range ends before present day → missing coverage-gap section is a lint failure
- Any dataset with known overlap with another wiki dataset → missing overlap-divergence section is a lint failure

The sections are not optional. They are part of the wiki's commitment to intellectual honesty — surfacing exactly what the data can and cannot tell us.

## Non-goals (explicit scope boundaries)

- **Don't over-document**. Datasets without splices, without coverage gaps, and without overlaps need none of these sections. The discipline is "document what exists," not "add sections prophylactically."
- **Don't collapse to a quality score**. *"Dataset X = B+"* isn't a discontinuity doc — it hides the specific issues the reader needs to see. Specific sections > aggregate grades.
- **Don't defer to footnotes**. Footnotes are skippable; these sections are load-bearing. Keep them in the main flow of the dataset page.

---

## How projects specialize

Projects using `llm-wiki-os` specialize this blueprint via:

- **Dataset pages** — each dataset's specific splices, coverage, and overlaps documented in the relevant sections
- **Domain-specific discontinuity categories** — some domains have additional categories worth naming (e.g., a clinical wiki might need a "diagnostic-criteria change" category; a financial wiki might need an "index-rebalancing" category). Add as `### <Category>` on dataset pages; if the category recurs across multiple datasets, document the pattern in an overlay at `thoughts/architecture/data-quality-discontinuities.md`.
- **Project-specific lint rules** — whether `/wiki:lint` treats missing sections as lint failures vs warnings, and per-dataset overrides for datasets where a section genuinely doesn't apply.

### Candidates for upstream elevation

When a project discovers a fourth discontinuity category that proves generic (observed across projects OR recognized as not domain-specific), propose upstream elevation. Doc-level equivalent of N=2 rule.

---

## Notes on this blueprint's own evolution

- Three categories is the minimum required for a data-heavy wiki. Fewer = silent drift; more = over-documentation unless a genuinely distinct category is observed.
- "Document what exists, not prophylactically" is a non-negotiable non-goal. Projects that add placeholder discontinuity sections on every dataset dilute the sections' signal.
- The lint-enforcement paragraph implies mechanical checkability. Project-specific lint rules (regex patterns, frontmatter fields) live in the project's `wiki/CLAUDE.md`; the blueprint keeps the rule to "flag missing sections where the discontinuity type applies."

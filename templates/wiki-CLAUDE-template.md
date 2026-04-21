# <PROJECT_NAME>-wiki — LLM Wiki Schema

> **BOOTSTRAP TEMPLATE** — this file is a starter for a new project using `llm-wiki-os`. Replace all `<PLACEHOLDERS>` with your project's specifics, then delete this callout. The generic methodology that this file instantiates lives at `llm-wiki-os/docs/*.md` (blueprints). Run `/wiki:pilot help me bootstrap this new project` after setting up to walk through the domain-specific choices.

This is the schema file for the `<PROJECT_NAME>` wiki — an LLM-maintained knowledge base about `<ONE_SENTENCE_PROJECT_DESCRIPTION>`. The wiki sits between the raw data sources (`<WHAT_SOURCES>`) and the human reader, building and maintaining a structured, interlinked collection of markdown pages that compound over time.

**The LLM writes and maintains the wiki. The human curates sources, asks questions, and directs analysis.**

Based on the [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) by Andrej Karpathy.

---

## This file's role: project-specific configuration for a generic wiki kit

`llm-wiki-os` is the generic operating system (skills + blueprints). This file is the **`<PROJECT_NAME>`-specific configuration** on top of it. Generic patterns (philosophical framework, source epistemology, claim fidelity, data-quality categories, cleaning-gate model, pipeline composition) live in `llm-wiki-os/docs/*.md` as blueprints; this file instantiates each blueprint with `<PROJECT_NAME>`'s specific choices.

**Blueprint ↔ section map** (skills read both):

| Blueprint | This file's corresponding instantiation |
|---|---|
| `llm-wiki-os/docs/philosophical-framework.md` | *"Core Principle: Complex Systems and Intellectual Humility"* section below — `<PROJECT_NAME>`'s specific ground-layer decomposition + lens choices |
| `llm-wiki-os/docs/karpathy-fidelity.md` | *"Ground truth sections"* + *"Correctness grade"* + *"External claims"* sections below — `<PROJECT_NAME>`'s specific paths, dataset row-ID examples, enforcement schema |
| `llm-wiki-os/docs/source-epistemology.md` | *"Source epistemology"* section below — `<PROJECT_NAME>`'s domain-institutional skepticism-spectrum table |
| `llm-wiki-os/docs/data-quality-discontinuities.md` | *"Data quality conventions"* section below — `<PROJECT_NAME>`'s specific splice / coverage / overlap instances on real datasets |
| `llm-wiki-os/docs/cleaning-gates.md` | The cleaning-gate subset of the *"Operations"* section below + project overlay if present |
| `llm-wiki-os/docs/pipeline-composition.md` | Project overlay if you use a product-strategy pipeline (see `thoughts/architecture/<overlay-name>.md`) |

When the blueprint covers the generic methodology in depth, this file keeps only the `<PROJECT_NAME>`-specific instantiation that skills need to execute.

---

## Core Principle: Information Dispersal

**The wiki works like Wikipedia, not like a Q&A log.** Every operation — ingest, query, or lint — disperses information across multiple pages. A single question or new data source should ripple through the wiki, updating existing pages and creating new ones.

Example: if someone asks "<EXAMPLE_QUESTION_IN_YOUR_DOMAIN>", the LLM should:

1. **Read** existing pages: `<ENTITY_PAGE>`, `<DATASET_PAGE>`, `<CONCEPT_PAGE>`, ...
2. **Update** those pages with new cross-references
3. **Create** a synthesis page if the connection is substantial enough
4. **Update** any relevant era/context pages with this finding

Information is never siloed into a single answer page. It disperses to every page where it's relevant — just like how a Wikipedia editor adds a fact to the main article, the person's biography, the event page, and the "See also" sections of related topics.

**The measure of a good wiki operation is not whether a single page was created, but how many existing pages were enriched.**

---

## Core Principle: Complex Systems and Intellectual Humility

Two foundations — the ground and the ceiling — govern every page in this wiki. They are not lenses. They are the terrain and the limits of the map. Between them sit `<N>` interlocking complex systems and the lenses we use to interpret them.

*See also `llm-wiki-os/docs/philosophical-framework.md` — the generic blueprint of this scaffold. **The canonical `<PROJECT_NAME>` reading lives here**; the blueprint mirrors the generic form so other projects can adopt the scaffold with their own instantiation.*

### The ground: Complex Systems (Meadows)

Everything this wiki studies is a **complex adaptive system** — you cannot understand it by decomposition. You have to stress it under different conditions and observe what emerges.

But there isn't one complex system. There are several, interlocking and circular. `<N>` layers:

```
<LAYER_1_OUTCOME> (what emerges — observed, not designed)
    │ emerges from
<LAYER_2_RULES_OR_CONSTRAINTS> (designed, changeable)
    │ created by
<LAYER_3_SOCIAL_OR_ORGANIZATIONAL> (how agents coordinate)
    │ composed of
<LAYER_4_AGENT_NATURE> (near-universal properties of agents)
```

**These are circular, not just layered.** `<DESCRIBE_FEEDBACK_LOOPS_SPECIFIC_TO_YOUR_DOMAIN>`.

#### The <N> interlocking systems

**1. `<SYSTEM_1>`** — `<DESCRIPTION>`. Elements: `<ELEMENTS>`. Emergent properties: `<EMERGENT_PROPERTIES>`.

**2. `<SYSTEM_2>`** — `<DESCRIPTION>`. Elements: `<ELEMENTS>`. Emergent properties: `<EMERGENT_PROPERTIES>`.

**3. `<SYSTEM_3>`** — `<DESCRIPTION>`. Elements: `<ELEMENTS>`. Emergent properties: `<EMERGENT_PROPERTIES>`.

#### What the wiki should be explicit about

Every page in the wiki is describing something at one of these levels. Tag each page with its primary level.

### The ceiling: Intellectual Humility (Popper)

Given that we're studying complex systems, **every claim is a conjecture** — testable against data, never provable. We can't run controlled experiments. And even if we could, the system's complexity means emergence would still surprise us. Certainty is impossible. Dogma is the enemy.

The wiki's job is to:

1. **Present what the data shows** — factual, cited, specific
2. **Offer multiple lenses** — not pick a winner
3. **Surface disagreement** — between data sources AND between interpretations
4. **Never claim certainty** — "the data is consistent with X" not "X caused Y"
5. **Never land on a single answer** — see below

### Single-answer analysis is always wrong

This is a core principle, not a guideline. When the wiki analyses any topic it must **never present one interpretation as THE answer.** Multiple lenses will produce multiple readings, and the honest position is that we cannot know which weighting is correct.

Why:
- The system is complex — multiple causes operate simultaneously at different levels
- We can't run the counterfactual — every causal claim is conjecture
- Different interpretive frames lead honest observers to weight the same evidence differently

The `### Through different lenses` convention exists for this reason. Every synthesis page, every query answer, every discovery report should present multiple interpretations. The human decides the weighting. The wiki never does.

**A wiki page that presents one clean explanation is a wiki page that's lying about the complexity of reality.**

### The lenses: Viewpoints on the same system

Between the ground (complex systems) and the ceiling (intellectual humility) sit the **lenses** — different viewpoints on the same complex system. Each emphasises a different aspect. None is wrong. None is complete. The human weights them based on their understanding and biases.

`<PROJECT_NAME>`'s lens set:

```
GROUND: Complex systems (Meadows) — the terrain we're studying
                    │
    ┌───────────────┼───────────────┐
    │               │               │
  <LENS_A>        <LENS_B>        <LENS_C>      ...
  <ANGLE_A>       <ANGLE_B>       <ANGLE_C>
    │               │               │
    └───────────────┼───────────────┘
                    │
CEILING: Intellectual humility (Popper) — the limits of what we can know
```

Additional lenses live as dedicated framework pages at `wiki/frameworks/*.md`.

This is not a hierarchy. The lenses interact: `<DESCRIBE_LENS_INTERACTIONS>`.

The human decides which lenses to weight for a given question. The wiki holds all of them.

### Systems-thinking mapping

Meadows: every system has elements, relationships, function, stocks-and-flows, emergent phenomena. Wiki page types map to these:

| System component | Wiki page type | Example |
|-----------------|---------------|---------|
| **Elements** | Entity pages, dataset pages | `<EXAMPLE>` |
| **Relationships** | Annotated wikilinks, synthesis pages | `<EXAMPLE>` |
| **Function/purpose** | Concept pages, era/context pages | `<EXAMPLE>` |
| **Stocks & flows** | The datasets themselves | `<EXAMPLE>` |
| **Emergent phenomena** | Concept pages (category: emergent), event pages | `<EXAMPLE>` |

### Role division

The LLM maintains framework pages and connects data to lenses in synthesis pages (bookkeeping — Karpathy's pattern). The **human** decides which lenses are most illuminating for a given question (thinking about what it all means). The wiki is a thinking tool, not a thinking-for-you tool.

---

## Architecture

```
<PROJECT_NAME>-wiki/          ← this repo (symlinked as wiki/ in <PROJECT_NAME>)
├── CLAUDE.md                 ← this schema file
├── overview.md               ← living top-level narrative synthesis
├── index.md                  ← content catalog (LLM-maintained)
├── backlog.md                ← compounding loop state machine
├── log.md                    ← chronological activity log (append-only)
├── entities/                 ← people, institutions, organisations
├── events/                   ← significant moments
├── concepts/                 ← structural, emergent phenomena
├── datasets/                 ← one page per data source
├── frameworks/               ← economic/philosophical/domain lenses
├── synthesis/                ← cross-dataset analysis
└── questions/                ← filed answers to research questions
```

### Raw sources (read-only, outside the wiki repo)

- `<RAW_SOURCE_PATH_1>` — `<DESCRIPTION>`
- `<RAW_SOURCE_PATH_2>` — `<DESCRIPTION>`

The wiki **reads** from these but **never modifies** them.

---

## Page Types

### Entity pages (`entities/`)

People, institutions, organisations that appear across datasets.

**Filename**: `<slug>.md`

**Frontmatter**:
```yaml
---
type: entity
entity_type: person | institution | organisation
aliases: ["<aliases>"]
datasets: [<which-datasets-mention-this>]
related: [<cross-refs>]
created: <ISO-date>
updated: <ISO-date>
---
```

### Event pages (`events/`)

Historically or operationally significant moments visible in the data.

**Filename**: `<slug>.md`

**Frontmatter**:
```yaml
---
type: event
date: "<ISO-date>"
datasets: [<datasets-where-event-visible>]
<DOMAIN_SPECIFIC_FIELD>: <value>
related: [<cross-refs>]
created: <ISO-date>
updated: <ISO-date>
---
```

### Concept pages (`concepts/`)

Concepts come in distinct categories:

**`category: structural`** — How the system is organised (mechanisms, institutions, regimes).
**`category: emergent-phenomenon`** — Things the system DOES (recurring patterns).

**Theoretical lenses are NOT concept pages** — they live in `frameworks/`.

### Dataset pages (`datasets/`)

One page per data source.

**Filename**: `<name>.md`

**Frontmatter**:
```yaml
---
type: dataset
source: "<SOURCE_NAME>"
license: "<LICENSE>"
coverage: "<DATE_RANGE_OR_SCOPE>"
correctness_grade: journalism
figures_verified: <ISO-date>
created: <ISO-date>
updated: <ISO-date>
---
```

**Mandatory `## Ground truth` section** — see below.

### Framework pages (`frameworks/`)

Economic/philosophical/domain lenses. LLM-maintained reference pages; human picks which to weight.

```yaml
---
type: framework
thinker: "<THINKER>"
key_work: "<KEY_WORK>"
role: lens            # or ground | ceiling
related: [<cross-refs>]
---
```

### Synthesis pages (`synthesis/`)

Cross-dataset analysis.

```yaml
---
type: synthesis
datasets: [<datasets-referenced>]
question: "<DRIVING_QUESTION>"
stress_tested: <ISO-date>   # set by /wiki:reflect
figures_verified: <ISO-date> # set by /wiki:audit
---
```

### Question pages (`questions/`)

Filed answers to research questions.

### `<DOMAIN_SPECIFIC_PAGE_TYPE>` pages (`<dir>/`)

*Add domain-specific page types here. For uk-legalize, this includes `eras/` for government-era synthesis. Your domain may want `releases/`, `subjects/`, `campaigns/`, `trials/`, etc.*

---

## Operations

Full skill descriptions live at `llm-wiki-os/commands/*.md`. Quick reference:

- **`/wiki:discover <question>`** — find gaps, research online, propose data sources
- **`/wiki:ingest <source>`** — process a source into the wiki, disperse across pages
- **`/wiki:query <question>`** — answer from wiki first, disperse findings
- **`/wiki:lint`** — structural health-check
- **`/wiki:audit [scope]`** — verify numeric claims against primary data
- **`/wiki:reflect <synthesis-page>`** — stress-test conjectures
- **`/wiki:pilot`** — ideation advisor (loaded with blueprints + this schema)

---

## Conventions

### Wikilinks

Use `[[wikilinks]]` for internal cross-references.

### No bare links — every link needs a why-clause

Karpathy describes "associative trails between documents" — links that tell you *why* the next page matters, not just that it exists. Every cross-reference in a `## Cross-references` or `## Connections` section must have an annotation explaining the connection.

**Wrong:**
```markdown
- [[datasets/<example>]]
- [[entities/<example>]]
```

**Right:**
```markdown
- [[datasets/<example>]] — <why this page matters in this context>
- [[entities/<example>]] — <why this page matters in this context>
```

### Data citations

Where a dataset page has a `## Ground truth` section, prose should cite the row ID: `[[datasets/<name>#<row-id>]]`. This makes the claim traceable to a canonical fact and auditable by `/wiki:audit`.

### Ground truth sections — the fidelity layer

**Generic methodology**: `llm-wiki-os/docs/karpathy-fidelity.md` — three-layer compilation model, row-ID grammar, path disambiguation, coverage-gap handling, external-claim syntax. Read the blueprint for the full framework.

**Mandatory on dataset pages and any synthesis page that consolidates numeric claims.** This is the layer-2 canonical-facts section in the three-layer compilation (primary-source → ground truth → synthesis prose).

**Dataset-page format:**

```markdown
## Ground truth

Computed from `<RAW_DATA_PATH>` at <ISO-date>.

| ID | Fact | Value | Coordinates |
|----|------|-------|-------------|
| `<dataset>.<fact-id>` | <description> | <value> | <coordinates> |
| ... | ... | ... | ... |
```

Row ID grammar: `<page-slug>.<stable-kebab-identifier>`. See blueprint for full rules.

### Correctness grade

Every page carries a `correctness_grade:` frontmatter field:

| Grade | Meaning |
|-------|---------|
| `journalism` | Every numeric claim cites a ground-truth row OR is explicitly marked external |
| `interpretive` | Numeric claims cite ground-truth rows transitively; lens-dependent analysis |
| `exploratory` | Work-in-progress; claims may be un-sourced |

### External claims — marking things not in wiki data

**Generic methodology**: `llm-wiki-os/docs/karpathy-fidelity.md`. Skills read this section to know what to parse.

Three accepted syntaxes (any other form triggers UNVERIFIABLE verdict):

1. **Inline parenthetical**: `... value Y (external claim; <optional source note>).`
2. **Inline short-form**: `... value Y *(external)*.`
3. **Sectioned**: `### External context` section — auditor skips entirely.

### Dates

ISO format: `<ISO-date>` for specific dates, `<YYYY-MM>` for monthly observations, `<YYYY>` for annual.

### Tone

Factual. `<DOMAIN_SPECIFIC_TONE_GUIDANCE>`.

### Contradictions

Surface rather than hide. `### Disputed` subsection on the relevant page.

### Data quality conventions

Three categories of data issues should ALWAYS be documented on dataset pages. If a dataset page lacks the relevant section, `/wiki:lint` should flag it.

*See also `llm-wiki-os/docs/data-quality-discontinuities.md` — generic blueprint version.*

**1. Splice discontinuities** — When a dataset splices multiple source series, the splice point MUST be documented as a `### Disputed` section.

**2. Coverage gaps** — When a dataset ends before the present day, note what events fall outside its range.

**3. Overlap divergence** — When two datasets cover the same period, compare them in the overlap.

### Source epistemology — `<PROJECT_NAME>`-specific instantiation

**Generic methodology**: `llm-wiki-os/docs/source-epistemology.md` — 7-question framework, skepticism-spectrum table *structure*, "right grip" principle, `### Source assessment` template.

Popper applied to the data itself. Not all sources are equal; the wiki should be skeptical of its own inputs, not just its own conclusions.

`<PROJECT_NAME>`'s source-type skepticism-spectrum (fill in your domain's institutions):

| Source type | Methodology | Incentive | Skepticism level |
|-------------|-------------|-----------|-----------------|
| **<DOMAIN_STATS_BODY>** | <HOW_PRODUCED> | <INCENTIVE> | Low |
| **<DOMAIN_ACADEMIC>** | Peer-reviewed | Publication bias | Low-medium |
| **<DOMAIN_REGULATORS>** | Investigatory | Problem-finding | Medium |
| **<DOMAIN_GOV_OR_ADMIN>** | Administrative data | Political priorities | Medium |
| **<DOMAIN_ADVOCACY>** | Curated | Position-driven | Medium-high |
| **<DOMAIN_COMMERCIAL>** | Proprietary methodology | Industry clients | Medium-high |
| **<DOMAIN_JOURNALISM>** | Secondary reporting | Editorial line | High |
| **Social media / blogs** | Unverified | Attention | Very high |

The table above is **orientation, not classification.** Source types blur; every specific source needs its own deep assessment (see 7 questions in the blueprint).

### Questions to ask of every source

*Full 7-question framework in `llm-wiki-os/docs/source-epistemology.md` — read there.* Summary:

1. Methodology
2. Definitions
3. What's NOT measured
4. Who commissioned it and why
5. Who benefits from this conclusion
6. Revisions and controversies
7. Comparison sources

**The goal is not to reject sources but to hold them with the right grip** — tight enough to use, loose enough to doubt.

Dataset pages should include a `### Source assessment` section applying these questions.

### Frontmatter

Every page has YAML frontmatter with at minimum: `type`, `created`, `updated`.

**Stub pages** (created by `/wiki:discover` before data is ingested) add `status: stub`.

### File naming

Lowercase, hyphen-separated slugs: `<slug>.md`.

### Synthesis pages — the highest-value output

Synthesis pages (`synthesis/`) connect multiple datasets in ways that aren't obvious from any single dataset page. They are the wiki's most valuable output — the "connections" Karpathy describes as "already there" rather than re-derived on every query.

**Create synthesis pages aggressively.** If a query or ingest reveals a cross-dataset connection, create a synthesis page.

### Output format flexibility

Wiki pages are markdown, but structured content can take multiple forms: comparison tables, timeline narratives, data extracts, annotated lists.

---

## Schema Evolution

This schema is not static. It co-evolves with the wiki as new patterns emerge.

After any operation, the LLM should consider whether the schema needs updating:
- New page type needed?
- New frontmatter field needed?
- New convention needed?
- Existing convention unclear or wrong?

If so, propose the change to the user. If approved, update this file. The schema should reflect the wiki's actual patterns, not prescribe patterns the wiki doesn't follow.

---

## Index, Backlog, and Log

### `overview.md`

Living top-level narrative. Tells the story of what the wiki knows.

### `index.md`

Content-oriented catalog. Organized by page type.

### `log.md`

Chronological, append-only.

```
## [<ISO-date>] <operation> | <description>
<summary paragraph>
Created: N. Updated: M. Total pages touched: N+M.
Pages: <comma-separated list>
```

### `backlog.md`

The compounding loop's state machine:

```
discovered → approved → built → ingested
```

**Every skill reads and writes the backlog.** It's the shared state that makes the compounding loop actually loop.

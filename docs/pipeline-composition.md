# Pipeline Composition

How a Karpathy-pattern wiki project composes into multiple linked pipelines: data quality → product strategy → implementation. Names the shape of each pipeline, the handoff between them, the feedback loop that makes the composition perpetual, and the schema-level questions that make handoffs mechanical rather than narrative.

**This is a blueprint.** Projects using `llm-wiki-os` specialize via a companion overlay at `thoughts/architecture/pipeline-composition.md` (or equivalent project-local path — often named after the specific product-strategy methodology the project uses, e.g. `story-map-pipeline-design.md`, `jobs-to-be-done-pipeline.md`). See the *"How projects specialize"* section at the end.

Related blueprints:
- `cleaning-gates.md` — the four cleaning agents inside Pipeline 1 (`/wiki:lint` → `/wiki:audit` → `/wiki:reflect` → `/wiki:coherence`)
- `karpathy-fidelity.md` — the write-time correctness invariant that makes Pipeline 1's output trustworthy as input to Pipeline 2
- `prompt-engineering.md` — the iteration methodology applied to every skill in every pipeline
- `philosophical-framework.md` — the ground/ceiling/lenses scaffold Pipeline 1's synthesis pages apply at their epistemic layer
- `planning-discipline.md` — Pipeline 3's `<plan>` step is where this discipline applies most directly; reconnaissance depth scales with assumption density at every pipeline step that depends on external authorities

Related skills: `llm-wiki-os/commands/*` (Pipeline 1 skills).

---

## The three pipelines

```
PIPELINE 1: Data quality (wiki)          → verified findings
PIPELINE 2: Product strategy             → GH issues with user stories / prioritized work items
PIPELINE 3: Implementation               → shipped code / shipped content / shipped research outputs
```

Each pipeline's output is the next pipeline's input. **Side effects from any loop can kick off another pipeline** — a wiki ingest discovers a gap → files a product-strategy item; a shipped feature produces user-behaviour data → surfaces new wiki questions; a story-map validation fails → returns a new hypothesis for the wiki to investigate.

## Pipeline 1: Data quality (the wiki)

```
/wiki:lint (structural precondition)
     │
     ▼
/wiki:discover → /wiki:ingest (authors synthesis) → /wiki:audit → /wiki:reflect → /wiki:coherence (planned)
                                                                                      ↓
                                                                upgrade/downgrade/hold + internal-consistency check
                                                                                      ↓
                                                     verified findings (figures_verified:
                                                     + stress_tested: + coherent_as_of: [planned]
                                                     frontmatter markers)
```

(Synthesis pages are authored during `/wiki:ingest` as part of dispersal; `/wiki:audit` verifies their numeric claims against ground-truth tables; `/wiki:reflect` stress-tests their causal conjectures; `/wiki:coherence` — planned — checks internal consistency. `/wiki:lint` runs as a structural precondition for the whole chain. The dependency chain matches `cleaning-gates.md` canonical order: `lint → audit → reflect → coherence`. When `/wiki:coherence` ships, the handoff contract to Pipeline 2 extends from 2 markers (`figures_verified:` + `stress_tested:`) to 3 (adding `coherent_as_of:`).)

**Output**: synthesis pages with stress-tested conjectures, calibrated confidence levels, `### Stress-tested` sections, and `figures_verified:` / `stress_tested:` frontmatter markers that downstream consumers gate on.

**Skills**: ship with `llm-wiki-os/commands/`. Generic across projects. Specialized via the project's `wiki/CLAUDE.md` schema.

**Quality gates**: `/wiki:lint` (structural integrity) → `/wiki:audit` (claim-level fidelity) → `/wiki:reflect` (causal-conjecture validity). See `cleaning-gates.md` for the full four-gate model.

## Pipeline 2: Product strategy (varies by project methodology)

Pipeline 2's shape depends on which product-strategy methodology the project uses — Patton-style story mapping, jobs-to-be-done, OKRs, user-story-mapping-lite, etc. The blueprint prescribes only the **pipeline shape**, not the methodology:

```
<discover> → <integrate verified findings> → <plan slices> → <validate post-ship> → <audit periodically>
```

- **`<discover>`**: find gaps in the current product/research/output by walking the methodology's primary abstraction (personas, jobs, stakeholders, research questions)
- **`<integrate>`**: take a verified finding from Pipeline 1 (a synthesis page with `stress_tested: <date>` + `figures_verified: <date>`), map it to the methodology's structure, produce a work item with a hypothesis
- **`<plan>`**: slice work items into releases/milestones/campaigns with explicit hypotheses
- **`<validate>`**: post-ship, test whether the hypothesis held. Projects use different verdict vocabularies — some split outcomes into three tiers (validated / learned / wrong), others use richer scales; the pipeline shape doesn't mandate a specific vocabulary, only that post-ship validation produces a verdict that can feed back into Pipelines 1 and 2.
- **`<audit>`**: periodic self-critique against the methodology's own principles to catch staleness, coverage gaps, hygiene issues

**Output**: prioritized work items (GitHub issues, tickets, research briefs) with explicit hypotheses + acceptance criteria. Each item traces back to a Pipeline 1 verified finding.

**Skills**: project-specific; live in the project's `.claude/commands/<methodology>/` (e.g., `.claude/commands/story-map/`, `.claude/commands/jtbd/`).

## Pipeline 3: Implementation

```
<plan> → <implement> → <validate> → <review> → <describe> → ship
```

Generic steps applicable to any shipping pipeline:

- **`<plan>`**: detailed implementation plan from the Pipeline 2 work item
- **`<implement>`**: build from the plan with verification checkpoints
- **`<validate>`**: check implementation against plan's success criteria
- **`<review>`**: architecture / conventions / dead code / tests / security
- **`<describe>`**: PR description / release note / change log
- **`ship`**: merge, deploy, announce

**Output**: shipped artifact + validation results that feed back to Pipeline 1 (new user-behaviour data, observed performance, discovered gaps).

**Skills**: often project-specific (`/rpi:*`, `/rw:*` patterns in the reference implementation), though some generic plan/implement/review skills may be shareable across projects.

## The perpetual loop

```
Pipeline 1 finds data → Pipeline 1 makes conjectures → /wiki:reflect stress-tests
    ↓ (side effect: verified findings with frontmatter markers)
Pipeline 2 integrates findings → plans releases → files work items
    ↓ (side effect: work items + release hypotheses)
Pipeline 3 builds → ships
    ↓ (side effect: user behaviour data, shipped-artifact telemetry, new questions)
Pipeline 2 validates → did the hypothesis hold?
    ↓ (side effect: new questions, upgraded/downgraded assumptions)
Pipeline 1 discovers new gaps → loop continues
```

Each pipeline turn can trigger turns in other pipelines. The system is itself a **complex adaptive system** (Meadows would appreciate it) — the feedback loops and stock-flow dynamics between the three pipelines produce emergent behaviour (compounding knowledge, drift toward unvalidated assumptions, cascade effects when a wiki figure changes).

The composition is what makes the Karpathy wiki valuable beyond "a nice knowledge base." The wiki is the **epistemic substrate**; the pipelines downstream are what convert epistemic substance into action. A wiki without Pipelines 2 and 3 is a dead-end read-only artifact; Pipelines 2 and 3 without a Pipeline 1 fidelity layer are strategy and implementation running on unverified beliefs.

## Key design questions (schema-level)

These questions don't get answered once-and-for-all — each project resolves them locally — but the **questions themselves are generic**.

### 1. Where do Pipeline 2 skills live?

Not in `llm-wiki-os` (generic wiki kit — domain-agnostic). Not in the wiki content repo (content, not tooling). Options:

- Project's main repo under `.claude/commands/<methodology>/` — common for solo-project build-for-self work
- Dedicated methodology-skill repo (analogous to llm-wiki-os, but for product strategy) — only justified if the methodology is reused across projects
- `thoughts/` if the methodology is still being designed

### 2. What's the handoff from Pipeline 1 to Pipeline 2? (mechanical, not narrative)

The seam needs to be checkable in code, not left to "the human remembers which findings are verified." Two contracts:

- **Frontmatter marker on the synthesis page**: `stress_tested: <ISO-date>` (and/or `figures_verified: <ISO-date>`) set by the corresponding cleaning agent. Missing = Pipeline 2's integrate skill refuses to run.
- **Hypothesis catalogue with stable IDs**: each synthesis page's conjectures are enumerated as rows with kebab-case IDs. Each row carries a verdict drawn from a **controlled vocabulary** (the specific enum is project-specific — see your project's overlay for the exact list). Pipeline 2 integrate is invoked as `<skill> <synthesis-page>#<conjecture-id>` and quotes the cited row's verdict + evidence for traceability.

Without these contracts the handoff rots — projects without them accumulate "verified findings" that are verified by informal memory, not by checkable precondition. Full design rationale in `karpathy-fidelity.md` (frontmatter contracts section).

### 3. What's the schema for Pipeline 2 state?

Pipeline 2 needs persistent state: personas (or their methodology-equivalent), backbone (or equivalent), releases, walking-skeletons, assumptions, learnings. Where does this live?

- Inside the wiki as a parallel content tree (e.g., `wiki/story-map/`) — pros: unified; cons: mixes knowledge-base and strategy-state, violating Karpathy's "the wiki is long-term memory of facts"
- In a separate product-strategy repo — pros: clean separation; cons: more repos to coordinate
- In `thoughts/product/story-map/` (or equivalent) of the project repo — pros: pragmatic, pros: version-controlled, pros: colocated with other strategy docs; cons: only accessible to someone who's cloned the project

Reference implementations tend to pick the third option. The blueprint doesn't prescribe — but the question must be answered explicitly, not drifted into.

### 4. Do you need a separate "conjecture" skill, or is synthesis creation the conjecture production step?

Projects bootstrapping this pipeline sometimes ask whether they need a dedicated skill (e.g., `/wiki:conjecture`) separate from `/wiki:ingest`'s synthesis-creation behavior. The answer for most projects: **no — synthesis creation IS the conjecture production step**. Splitting them adds a coordination surface without adding capability; the Pipeline 1 skill chain already covers it (discover finds gaps → ingest authors synthesis → audit verifies figures → reflect stress-tests conjectures).

The exception: if a project treats "conjecture" as a distinct artifact class from "synthesis" (e.g., conjectures are lightweight hypotheses without data attached; syntheses are fully cited narratives), a separate skill may be justified. In practice this is rare — the synthesis page pattern with a hypothesis-catalogue section already carries both the narrative and the extractable conjectures.

Related but distinct: **Pipeline 1's `<discover>` vs Pipeline 2's `<discover>`**. Both pipelines have a `<discover>` step but with different purposes — Pipeline 1's finds knowledge gaps (what do we not know?); Pipeline 2's finds product gaps (what user needs aren't served?). They can feed each other but remain distinct skills with distinct preconditions. Projects that conflate the two end up with one skill trying to do both jobs and doing neither well.

### 5. What's the feedback loop from Pipeline 3 back to Pipeline 1?

Shipped artifacts produce user-behaviour data (click-through, dwell time, return visits, qualitative feedback). That data is a primary source the wiki should ingest. Questions:

- Where does user-behaviour data live? (the project's analytics layer, usually)
- How does it become a wiki primary source? (via a `/wiki:discover` round that proposes an analytics ETL, same as any other data source)
- How is the causal question framed? (not "did users click?" but "was the hypothesis from the Pipeline 2 plan supported by behaviour?")

The loop-closing step is often the weakest — many projects ship artifacts, never return to validate, and the wiki's knowledge of "what worked vs didn't" stays at N=1 forever.

## Non-goals (explicit scope boundaries)

- **Don't collapse the three pipelines into one "do everything" pipeline.** The separation is what enables cleaning gates (Pipeline 1), hypothesis discipline (Pipeline 2), and plan/implement discipline (Pipeline 3) — each a different abstraction.
- **Don't skip the handoff contracts.** A synthesis page without `stress_tested:` + `figures_verified:` is not consumable by Pipeline 2 mechanically. Letting Pipeline 2 "just read" the synthesis with no precondition means the first error in the wiki silently propagates through strategy and implementation. (When `/wiki:coherence` ships, `coherent_as_of:` becomes a third mandatory marker on pages that pass internal-consistency check — see `cleaning-gates.md` for the four-gate model's frontmatter-marker contract.)
- **Don't build Pipeline 2 before Pipeline 1 has produced at least one verified synthesis.** Without verified findings to integrate, Pipeline 2's integrate skill has no input; the methodology becomes ungrounded.
- **Don't claim the pipeline composition is a hierarchy.** It's a cycle. Pipeline 1 depends on Pipeline 3's feedback as much as Pipeline 3 depends on Pipeline 1's output. "Upstream" and "downstream" in any single turn become the opposite in the next turn.

---

## How projects specialize

Projects using `llm-wiki-os` create a companion overlay at a project-local path (by convention: `thoughts/architecture/pipeline-composition.md`, OR named after the specific product-strategy methodology the project uses — e.g., `story-map-pipeline-design.md` for Patton-methodology projects, `jtbd-pipeline.md` for jobs-to-be-done projects). The overlay cites this blueprint and adds **only** project-specific content:

- **Chosen product-strategy methodology** — which methodology Pipeline 2 uses (Patton story-mapping, jobs-to-be-done, OKRs, custom blend) and why
- **Concrete Pipeline 2 skill names** — e.g., `/story-map:discover`, `/story-map:integrate`, `/jtbd:plan`
- **Concrete Pipeline 3 skill names** — e.g., `/rpi:create_plan`, `/rpi:implement_plan`, `/rw:review`
- **Answered versions of the 5 design questions** — with the project's specific answers and the rationale
- **Project-specific feedback-loop details** — how user-behaviour data actually gets ingested in practice, what the analytics ETL looks like, what "did the hypothesis hold?" means concretely
- **Staleness / drift notes** — where in the loop this particular project has drifted off-pattern (e.g., "Pipeline 3 ships but Pipeline 2 validate-step rarely runs") and what's being done about it

The overlay stays thin. Conceptual composition lives here; project-specific answers and operational details live in the overlay.

### Candidates for upstream elevation

When the project's overlay accumulates methodology-neutral content — new composition patterns, new design questions, handoff-contract refinements that aren't specific to a single methodology — propose upstream elevation:

1. The overlay names the candidate in its own *"## Candidates for upstream elevation"* section, with a brief rationale for why it might be generic.
2. `/meta propose-edit llm-wiki-os/docs/pipeline-composition.md` drafts the blueprint absorption.
3. User approval → commit to `llm-wiki-os`. Same commit or follow-up: overlay thins, citing the new blueprint section.

This is the doc-level equivalent of the N=2 codification rule for skill files (see `prompt-engineering.md`).

---

## Notes on this blueprint's own evolution

- The three-pipeline composition is the foundational claim. If a fourth pipeline becomes load-bearing (e.g., a dedicated "research-publication pipeline" distinct from implementation), add it to the model; don't treat the three-count as fixed.
- The design questions (5 today) are the main elevation-surface. Projects answering these questions will surface new questions worth adding here. If you see a question appear independently in two overlays, elevate it.
- The handoff-contract mandate (`stress_tested:` + hypothesis-catalogue IDs) currently lives both here and in `karpathy-fidelity.md`'s frontmatter-contracts section. If that duplication drifts, reconcile — the contract is one thing, described from two angles.
- The "complex adaptive system" framing (Meadows) is Karpathy-wiki-specific because the wiki's epistemological framework uses Meadows as the ground-layer lens. Projects using a different epistemological framework may re-word this; the substantive claim (feedback loops between pipelines produce emergent behaviour) is generic.

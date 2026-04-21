# Planning Discipline

How to approach non-trivial implementation work: Popperian, reconnaissance-first. Anchored in the philosophical framework shared across Karpathy-pattern wikis — specifically the Popperian ceiling (*"conjecture supported, not proven"*) applied to project planning rather than empirical claims.

**This is a blueprint.** Projects using `llm-wiki-os` specialize via a companion overlay at `thoughts/architecture/planning-discipline.md` (or equivalent project-local path). See the *"How projects specialize"* section at the end.

Related blueprints:
- `karpathy-fidelity.md` — the write-time correctness invariant, which is the data-layer analogue of what planning-discipline is at the work-layer (both apply Popperian falsification to different substrates)
- `cleaning-gates.md` — the gates that catch errors the planning discipline is supposed to have prevented upstream
- `prompt-engineering.md` — the iteration methodology for skills, which is itself an instance of the reconnaissance-first pattern (fresh-session test IS the reconnaissance)

---

## Principle: plans are hypotheses

A written plan is a claim about what should be done and how. It rests on assumptions: data shape, API availability, codebase patterns, integration surfaces. **Any plan that takes more than 30 minutes to execute must have a reconnaissance step that empirically tests its riskiest assumption before commitment.**

Plans are not contracts with the future. They are hypotheses about what will work. The point is not to get the plan right on first draft — it's to test the plan's assumptions cheaply and re-scope when reality disagrees.

This parallels the Popperian framing in the wiki's epistemological stance: claims are conjectures supported by evidence, not proven truths. Plans are the same shape. Reconnaissance is the falsification step.

## Pattern: reconnaissance-kills-assumption

**Phases of non-trivial work:**

1. **Draft** a plan with assumptions made explicit
2. **Reconnaissance** — run the cheapest steps that test the riskiest assumption (fetch + inspect, grep + enumerate, single-call + eyeball)
3. **If reconnaissance confirms** → execute the plan
4. **If reconnaissance falsifies** → halt, re-scope, produce a revised plan. **Do not paper over.**

The halt is the important move. The failure mode is papering over: *"the xlsx doesn't have history but I'll figure out the API at parse time."* That masks a scope change inside an execution step and produces a half-done artifact that has to be unwound later.

## Reconnaissance depth should scale to assumption depth

Not all plans have the same assumption density. The reconnaissance step should be sized against the surface area of externally-dependent assumptions.

**High assumption density (deep reconnaissance required):**

- Plans depending on third-party APIs (schema, auth, rate limits, pagination semantics)
- Plans depending on bulk data schemas (xlsx row/column layout, date formats, null markers, per-series presence)
- Plans depending on platform-specific config behavior (deploy-target header merge rules, rewrite semantics)
- Plans depending on library internals (router behavior, framework lifecycle, build-tool output)
- Plans depending on cloud-host quirks that aren't documented at the surface

**Low assumption density (light reconnaissance sufficient):**

- Plans against code whose behavior is fully visible in the repo
- Plans against patterns already verified in prior work this session
- Plans whose integration surfaces were recently touched and are known-current

**The common trap:** plans against *external authorities* that don't *feel* like "external data" in the obvious sense. Library internals, platform config semantics, cloud-host behavior — these get treated as internal-code-shape plans where code-survey reconnaissance is considered sufficient, and the load-bearing assumptions get papered over with *"research notes"* that didn't verify against the actual behavior.

Matching reconnaissance depth to assumption density prevents implementation halts that force mid-flight scope revision.

## Worked examples (from the reference implementation)

### 1. xlsx→API pivot

- **Initial plan:** parse a bulk xlsx for multiple time-series, with full history.
- **Reconnaissance:** fetch the xlsx and inspect structure.
- **Finding:** the xlsx carried only 7 recent months + annual average — a reference card, not a historical dataset.
- **Halt:** plan's core assumption was wrong.
- **Revision:** switch to the provider's per-series JSON API (reuse an existing ETL pattern from prior work). Expand series count based on what the API's schema actually supported. Sanity check via three reference values, no hard-coded benchmark.
- **Result:** plan shipped cleanly on revision. The wrong ETL was never built.

### 2. Commodity framing as hypothesis

- **Initial framing:** *"Did specific commodity prices drive [outcome X]?"* — treated as a question with a presumed positive answer.
- **Reconnaissance:** ran `/wiki:discover` with the claim explicitly labelled *"from general knowledge — will verify with data"*, split into sub-hypotheses.
- **Finding:** the framing held partially. Commodities moved materially AND reverted. But the specific sub-claim about peer-comparison was not commodity-driven (separate finding).
- **Result:** the resulting synthesis was calibrated (Supported / Partially supported / Supported-with-important-reframing / Not testable across the sub-claims) rather than confirmation-biased.

Without this discipline, the synthesis would have been stuffed with a misleading hero claim. With it, a `### Disputed` section documented that one widely-cited figure didn't reconcile with the underlying data, and the real headline was a different finding that the reconnaissance surfaced.

### 3. Library-behavior plan-halt (the inverse)

- **Plan:** deploy to a specific platform, assuming a route rendered bare and the platform's header merge was additive.
- **Reconnaissance:** skipped at plan time because the assumptions *felt* like internal-code knowledge.
- **Implementation halts:** three mid-flight — pre-existing lint errors surfaced, the route was wrapped by a root layout unconditionally, and platform config merged headers differently than assumed, producing duplicates.
- **Lesson:** library internals and platform config semantics are *external authorities*. Treat them as bulk-data-schema-class reconnaissance targets, not internal-code-shape assumptions.

## When this applies

- Any ETL build or data integration — **data sources lie** (or document incompletely)
- Any plan whose correctness depends on an external schema (API shape, xlsx structure, upstream library behaviour, platform-config semantics)
- Any `/wiki:discover` or equivalent hypothesis-walking round — the question itself is the hypothesis being tested
- Any skill iteration where the fix-theory hasn't been tested against a fresh-session execution (see `prompt-engineering.md`)
- Any plan that takes more than ~30 minutes to execute and depends on at least one non-trivially-knowable external authority

## When this doesn't apply

- Small, contained edits (fix a typo, update a copy string, rename a variable)
- Plans whose assumptions were already verified in prior work this session
- Pure prompt engineering on skill files (the skill file itself is the artifact; iteration via fresh-session test *is* the reconnaissance — see `prompt-engineering.md`)
- Plans against only code visible in the repo, with no external-authority dependencies

## Enumeration aid for plan drafters

Before committing to a plan, enumerate:

1. **Every external authority the plan depends on** — APIs, data schemas, platform behaviors, library internals, cloud-host quirks, config-merge semantics
2. **For each:** has this authority been verified in a reconnaissance artifact (fetch output, schema dump, curl transcript, behavior test)? If not, plan to verify before drafting any code-shape.
3. **For each:** is the verification still current? (APIs change; library versions drift; platform defaults shift.)

If the enumeration is empty, the plan is probably low-assumption-density and light reconnaissance is fine. If the enumeration has 3+ entries, the plan is reconnaissance-heavy and the discipline should be followed explicitly before any code is drafted.

---

## How projects specialize

Projects using `llm-wiki-os` create a companion overlay at a project-local path (by convention: `thoughts/architecture/planning-discipline.md`). The overlay cites this blueprint and adds **only** project-specific content:

- **Project-specific worked examples** — the actual xlsx pivots, platform halts, framing corrections this project has seen, with dates and commit references
- **Project-specific external authorities** — the specific APIs, platforms, libraries this project depends on and the reconnaissance conventions around each
- **Project-specific skill integrations** — e.g., `/rpi:create_plan` calling out an "Implementation Note" section, `/wiki:discover` using a specific pre-research format
- **Project-specific learnings** — documented cases where the discipline was skipped and what happened, typically cross-referenced from `thoughts/product/story-map/learnings.md` or equivalent
- **Project-specific triggers** — custom rules about when the discipline applies beyond the generic "non-trivial with external dependencies" trigger

The overlay stays thin. The discipline itself lives in this blueprint; project-specific applications live in the overlay.

### Candidates for upstream elevation

When the project's overlay accumulates methodology-level content — new failure classes, new reconnaissance patterns, refinements to the scaling heuristic — propose upstream elevation:

1. The overlay names the candidate in its own *"## Candidates for upstream elevation"* section, with a brief rationale for why it might be generic.
2. `/meta propose-edit llm-wiki-os/docs/planning-discipline.md` drafts the blueprint absorption.
3. User approval → commit to `llm-wiki-os`. Same commit or follow-up: overlay thins, citing the new blueprint section.

See `prompt-engineering.md` for the full N=2 codification methodology this inherits from.

---

## Notes on this blueprint's own evolution

- The Popperian framing is foundational. Changes to the blueprint should preserve *"plans are hypotheses, reconnaissance is falsification"* as the underlying stance — if a change implies plans-as-contracts, it's a different discipline.
- The scaling heuristic (reconnaissance depth scales with assumption density) is the second-most important piece. Refinements to how "assumption density" is recognised are welcome; removals would gut the discipline.
- Worked examples here are illustrations of the pattern. Projects add their own in their overlays. If a worked example here ever becomes misleading (e.g., the example platform behavior changes), strike it or replace it — don't leave stale examples.
- If a fourth worked-example class emerges (beyond API/data-schema, framing-as-hypothesis, and library-behavior), add it with the same shape (plan → reconnaissance → finding → halt/revision → result → lesson).

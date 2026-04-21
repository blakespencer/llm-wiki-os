# Wiki Cleaning Gates — the four-agent model

Strategic model for keeping a Karpathy-pattern wiki high-fidelity over time. Distinguishes generative agents (which grow the wiki) from cleaning agents (which catch errors). Names the four invariants, the dependency chain between them, and the path toward CI/CD-for-the-brain.

**This is a blueprint.** Projects using `llm-wiki-os` specialize via a companion overlay at `thoughts/architecture/wiki-cleaning-gates.md` (or equivalent project-local path). See the *"How projects specialize"* section at the end.

Related blueprints:
- `karpathy-fidelity.md` — diagnosis of the write-time correctness invariant that `/wiki:audit` (the second gate) exists to enforce
- `prompt-engineering.md` — the skill-iteration methodology that governs how gates evolve and how overlays propose elevations
- `pipeline-composition.md` — the three-pipeline composition model; the cleaning gates produce the `figures_verified:` + `stress_tested:` + `coherent_as_of:` frontmatter markers that Pipeline 2 consumers gate on
- `source-epistemology.md` — source-level skepticism fires during `/wiki:discover` and `/wiki:ingest`; cleaning gates fire after ingest to catch what source epistemology couldn't prevent
- `data-quality-discontinuities.md` — `/wiki:lint` flags dataset pages missing required discontinuity sections (splice / coverage / overlap); the three categories feed into audit verdicts ("all-time X" claims hinge on documented coverage range)

Related skills: `llm-wiki-os/commands/lint.md`, `audit.md`, `reflect.md`, and a planned `coherence.md`.

---

## The model

Six agent skills operate on a mature wiki. Three GENERATIVE, three-going-on-four CLEANING:

```
  GENERATIVE (grow the wiki)                   CLEANING (catch errors)
  ──────────────────────────                   ────────────────────────

  /wiki:discover   finds gaps                  /wiki:lint       structural integrity
  /wiki:ingest     absorbs + disperses         /wiki:audit      factual fidelity
  /wiki:query      answers + disperses         /wiki:reflect    epistemic honesty
                                               /wiki:coherence  internal consistency  [planned]
```

Each cleaning agent targets a distinct invariant. They share execution discipline (approval gates, deterministic diff where applicable, wiki-repo-only commits) but catch different failure classes.

The separation matters: a single agent that both ingests AND verifies can rationalize its own failures silently. Generative and cleaning must be distinct skills, distinct approval gates, distinct commits — even when a human operates them in quick succession.

## The four invariants

| Skill | Invariant | Catches | Misses |
|---|---|---|---|
| `/wiki:lint` | Structural integrity — does the wiki follow its own schema? | Broken wikilinks, orphans, missing `## Ground truth` sections, missing frontmatter fields, stale scaffold labels, one-way links | Everything factual |
| `/wiki:audit` | Factual fidelity — do prose claims match primary data? | Numeric claims disagreeing with ground-truth rows, ground-truth rows disagreeing with the primary-source artifact (e.g., JSON file, xlsx cell), broken citations, uncited claims | Whether the claim's conjecture makes sense |
| `/wiki:reflect` | Epistemic honesty — are conjectures supported + explicitly falsifiable? | Un-stress-tested conjectures, missing refuter criteria, single-answer synthesis, stale verdicts after new evidence | Whether the facts underpinning the conjecture are correct; whether different conjectures inside a page contradict each other |
| `/wiki:coherence` *(planned)* | Internal consistency — do a page's own conjectures imply contradicting things? Does a synthesis's dispersed cross-references agree with each other across pages? | Conjecture A implies X, conjecture B implies not-X; synthesis page quotes figure Z, but two different ground-truth rows both claim to be Z with different values; event page says X happened during era Y, but era page says X happened during era Z | Everything the other three already catch |

## Dependency chain

The cleaning agents run in a specific order because each assumes the previous has passed:

```
  /wiki:lint  ─── passes ───►  /wiki:audit  ─── passes ───►  /wiki:reflect  ─── passes ───►  /wiki:coherence
  (schema OK)                  (facts OK)                    (conjectures                    (consistency OK)
                                                              calibrated)
     │                            │                              │                              │
     │ fails                      │ fails                        │ fails                        │ fails
     ▼                            ▼                              ▼                              ▼
  retrofit                      fix data / rows              hold verdict, file             file Reflect candidate
  (ground-truth                 (correct ground-truth         Reflect candidate,             OR /wiki:ingest follow-up
   sections, etc.)              rows from primary sources)    suggest ingest if               to acquire disambiguating
                                                              evidence needed                 evidence
```

Running out of order produces garbage:
- Running audit against a broken schema → false UNVERIFIABLE verdicts (no ground-truth rows to diff against)
- Running reflect against unverified figures → stress-testing conjectures against wrong baselines
- Running coherence against unreflected conjectures → flagging tensions that reflect would have resolved by downgrading a verdict

The dependency order is not a style preference. It is the condition under which each gate's output is meaningful.

## Downstream consumers gate on the cleaning agents

The cleaning agents produce frontmatter markers that downstream consumers use as preconditions:

```
  /wiki:lint      ─► no frontmatter marker (structural state is implicit from disk + dates)
                     but lint refuses to run on missing schema
  /wiki:audit     ─► figures_verified: <date>    (gates claim-level consumers — e.g., product-strategy,
                                                   research-publication, any skill building on verified claims)
  /wiki:reflect   ─► stress_tested: <date>       (gates consumers of causal-conjecture output)
  /wiki:coherence ─► coherent_as_of: <date>      (planned — proposed marker for pages that pass
                                                   internal-consistency check)
```

Downstream gate enforcement is the **mechanical seam** that makes the gates load-bearing rather than advisory. A gate without a consumer that refuses to run on its absence is a gate that can be silently skipped.

## CI/CD for the brain

The analogy is load-bearing, not decorative. In software CI/CD:

- Lint = static-analysis / type-check
- Test = behavior-verification
- Build = artifact assembly
- Deploy = promotion to production

Triggers are post-commit. Gates are automatic. Failures block promotion. Developers see a dashboard of build status per branch.

The wiki analogy:

- `/wiki:lint` = static-analysis (structure)
- `/wiki:audit` = test suite (claims)
- `/wiki:reflect` = integration test (conjectures under evidence)
- `/wiki:coherence` = cross-module consistency check

Triggers SHOULD be post-commit (git hook notices an ingest → queues gate runs).
Gates SHOULD refuse to promote when failing.
A dashboard SHOULD surface which pages are at which gate level.

Today, all of this is manual. The candidate improvements below are the path toward "CI/CD for the brain."

## Candidate improvements (design space)

Ranked by leverage × cost. Projects specialize the ordering in their overlay based on local state, but the generic ranking reflects dependency structure (coherence is the fourth gate; mechanical enforcement needs the fourth gate to be live; the trigger queue needs enforcement to be load-bearing; coverage stats sit on top of all three).

### (1) New `/wiki:coherence` skill — the fourth gate

Different role from the other three — catches a failure class none of them touch.

**What it does:**
- On a target synthesis page: extract the hypothesis-catalogue conjectures; for each pair, check whether they imply contradicting things. Use LLM-based pairwise comparison (with false-positive risk noted).
- Across pages: check that the same claim (same value, same coordinates) appears consistently across every page that cites it. Implementable via row-ID grep + value comparison.
- Across ground-truth rows: for rows with the same semantic key (e.g., *"Bank Rate all-time high"* or *"GDP peak Q3 2008"*), check that the value + coordinates agree.

**What it does not:**
- Re-verify facts (that's `/wiki:audit`'s job)
- Stress-test conjectures (that's `/wiki:reflect`'s job)
- Adjudicate "which is right" when it finds a contradiction — surfaces it for the human to resolve

**Frontmatter marker:** `coherent_as_of: <date>`.

**Approach:**
1. Build under `llm-wiki-os/commands/coherence.md` following the same pattern as `audit.md` / `reflect.md`.
2. Draft scorecard alongside (project-local path, e.g., `thoughts/notes/scorecard-wiki-coherence.md`).
3. First-run fixture: a synthesis page with a hypothesis catalogue AND cross-page references to test. Project-specific choice.

### (2) Mechanical gate enforcement

Cheap, self-healing. Each cleaning agent should refuse-to-run when preconditions aren't met.

**Specific edits:**
- `/wiki:reflect` — refuses to run on a page where any cited dataset has `figures_verified:` stale (or absent). If audit is overdue, reflect halts with *"audit this page's cited datasets first."*
- `/wiki:audit` — refuses to run when last `/wiki:lint` run is more than N days old OR when the target page has unresolved lint findings. Halt with *"lint first; structural gaps will produce false audit verdicts."*
- **Downstream consumer skills** — refuse when either `figures_verified:` or `stress_tested:` on the target synthesis is missing or stale. Analogous to existing `stress_tested:` enforcement patterns.

**Priority:** after coherence; these are skill-file edits rather than new-skill builds.

### (3) Post-commit trigger queue

Automation layer. Git hook on commits touching `wiki/` writes a queue entry; a status-reporting skill reads it.

**Pattern:**
1. `.git/hooks/post-commit` on wiki repo checks commit metadata. If commit touches ingested datasets (via regex on commit message or file paths), appends to `wiki/.gate-queue`:
   ```
   <ISO-timestamp> /wiki:audit --dataset <name>
   <ISO-timestamp> /wiki:reflect <synthesis-path>
   ```
2. A project-specific status-reporting skill reads `.gate-queue`. If non-empty and no *"deploy critical path"* overrides, the recommended next action is the oldest queued gate run.
3. On successful gate completion, the entry gets removed from the queue.

**Priority:** after mechanical enforcement. Infrastructure layer that sits on top of skill contracts.

### (4) Per-gate coverage stats in status-reporting

Visibility. Cheap. Surfaces gate health at a glance.

**Pattern:**
Extend the Stats block in `/wiki:lint` (or a project-specific status-reporting skill) to report:

```
- Pages with figures_verified (<30 days old): N / M (%)
- Pages with stress_tested (<30 days old): N / M (%)
- Pages with coherent_as_of (<30 days old): N / M (%)  [requires /wiki:coherence]
- Pages never audited: K (list)
- Pages with stale audit (cited dataset re-ingested after verification): J (list)
```

**Priority:** low-medium. Adds visibility but doesn't catch new failure classes.

## Non-goals (explicit scope boundaries)

- **Don't auto-apply gate fixes.** The gates catch failures; humans resolve them. Automation is trigger-side (queue gate runs), not resolution-side.
- **Don't enforce gates on non-tracked pages.** The wiki's schema might evolve; new page types might lag gate coverage. Gates apply only where the frontmatter markers mandate them.
- **Don't collapse cleaning and generative agents.** Discovery/ingest grow the wiki; gates keep it honest. Mixing the two breaks the approval-gate discipline — a single agent that both ingests AND verifies can rationalize its own failures silently.
- **Don't build `/wiki:coherence` before the first three are load-bearing.** Dependencies matter. Coherence on an unreflected wiki produces garbage findings.
- **Don't run gates out of dependency order for convenience.** Each gate's output is only meaningful if its predecessors have passed. *"Just run reflect first because it's more interesting"* produces stress-tests against unverified baselines.

---

## How projects specialize

Projects using `llm-wiki-os` create a companion overlay at a project-local path (by convention: `thoughts/architecture/wiki-cleaning-gates.md`). The overlay cites this blueprint and adds **only** project-specific content:

- **Concrete consumer-skill names** — e.g., `/story-map:integrate` (product-strategy projects), `/release-gate:check` (research-publication projects), `/operator status` (projects using an operator-layer status reporter)
- **Priority-ordered shipping sequence** — which improvements this specific project has shipped / is shipping / is holding, with dates and rationale
- **Concrete fixture pages** — specific synthesis pages or test cases the project uses to validate new gates (e.g., *"first-run fixture for /wiki:coherence: synthesis/why-uk-building-costs-high"*)
- **Project-specific markers or grades** — any extra frontmatter fields sitting alongside the generic `figures_verified:` / `stress_tested:` / `coherent_as_of:` contracts
- **Integration with the project's meta / debt tracking** — how gate-related work gets queued (e.g., `thoughts/notes/meta-debt-queue.md`)
- **Project-specific non-goals** — scope boundaries that apply to this wiki but not to all wikis (e.g., *"we don't gate on coherence for the journal pages because they're interpretation-heavy"*)

The overlay stays thin. Conceptual content (what a gate IS, why the dependency chain matters, the CI/CD analogy) lives in this blueprint. Project-specific operational content (what's shipping, in what order, by whom) lives in the overlay.

### Candidates for upstream elevation

When the project's overlay accumulates content that turns out to be generic — observed across multiple projects, OR recognized as a pattern not specific to this project — propose upstream elevation:

1. The overlay names the candidate in its own *"## Candidates for upstream elevation"* section, with a brief rationale for why it might be generic.
2. `/meta propose-edit llm-wiki-os/docs/cleaning-gates.md` drafts the blueprint absorption.
3. User approval → commit to `llm-wiki-os`. Same commit or follow-up: overlay thins, citing the new blueprint section.

This is the doc-level equivalent of the N=2 codification rule for skill files (see `prompt-engineering.md`).

---

## Notes on this blueprint's own evolution

- Subsequent re-occurrence of any pattern in this blueprint (N=2) in a different project should reference back to this diagnosis rather than re-deriving it.
- If the first `/wiki:coherence` implementation in any project reveals additional failure subclasses not captured in the *"What it does"* subsection above, append here rather than opening a sibling doc.
- If a fifth gate turns out to be needed (e.g., a `/wiki:currency` gate that checks whether cited primary sources have been updated since last read), add it to the four-agent model and update the dependency chain — don't treat this blueprint as frozen at four.
- The CI/CD-for-the-brain analogy is the animating idea. Changes to the gate model should preserve the dependency-chain discipline the analogy justifies.

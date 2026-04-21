# Prompt Engineering Process

How to iterate on skill quality for LLM-operated wikis (and skill-based systems more broadly). A human-facing checklist — the test sessions don't know they're being tested. Also codifies the N=1 → N=2 emergent-capabilities workflow that governs when observed patterns get promoted into skill files.

**This is a blueprint.** Projects using `llm-wiki-os` specialize via a companion overlay at `thoughts/architecture/prompt-engineering-process.md` (or equivalent project-local path). See the *"How projects specialize"* section at the end.

Related blueprints:
- `karpathy-fidelity.md` — the write-time correctness invariant the cleaning gates enforce
- `cleaning-gates.md` — the four-gate model whose skills get iterated via this process
- `planning-discipline.md` — reconnaissance-kills-assumption pattern, which applies to iteration on skills just as much as to implementation plans

Related skills: every `llm-wiki-os/commands/*.md` skill file is an artifact of this process.

---

## The two-session pattern

**Never mix engineering and testing in the same session.**

| Session | Role | What it does |
|---------|------|-------------|
| **Engineering session** | Designs, analyses, fixes | Reads test output, scores it, updates skill instructions, reverts wiki for re-testing |
| **Test session** | Executes, produces | Runs the skill from cold with no context from the engineering session. Doesn't know it's being tested. |

The engineering session's context contaminates results. If you design and test in the same session, the model has all the context of what you want — so it'll produce good output even with bad instructions. A fresh session with only the schema and skill instructions is the real test.

This principle scales beyond wiki skills. Any time you are iterating on a prompt or skill contract, the fresh-session discipline applies: the session that writes the contract must not be the session that tests it.

---

## The process

### 1. Write

Write or update the skill in the source repo (e.g., `llm-wiki-os/commands/` for generic wiki skills; project-local `.claude/commands/` for project-specific skills). Commit and push.

### 2. Test

Open a **fresh session** in the project. Run the skill with a real prompt — not a toy example. Let it execute fully, including any wiki writes or side effects.

### 3. Capture

Copy the full output back to the engineering session. Include:

- The pre-research summary (if applicable — e.g., for discover/query)
- The main output (report, ingest plan, lint report, stress-test)
- What it wrote to the wiki or other persistent state (pages created, pages updated, backlog entries added)
- The *"suggested next"* section

### 4. Score

Score the output against a checklist (often called a "scorecard" in project-local conventions). The checklist depends on the skill but always includes:

**Universal checks:**
- [ ] Did it read `wiki/CLAUDE.md` as Step 1?
- [ ] Did it read `wiki/backlog.md` (or equivalent shared state)?
- [ ] Did it apply any three-systems-style framing where relevant (for wikis that use one)?
- [ ] Did it apply lenses from the project's framework directory (not hardcoded)?
- [ ] Did it include a Popperian caveat where causal claims appeared?
- [ ] Did it present multiple interpretations (single-answer check)?
- [ ] Did it suggest next actions?
- [ ] Did it commit with a descriptive message?

**Skill-specific checks** are catalogued per-skill — the scorecard file is the contract against which the skill is graded.

### 5. Identify fixes

For each failed check:

- Is the instruction missing from the skill? → Add it
- Is the instruction present but vague? → Make it explicit
- Is the instruction present but the model ignored it? → Make it louder (bold, caps, "MANDATORY")
- Is it a schema issue, not a skill issue? → Update `wiki/CLAUDE.md`

### 6. Baseline

**Before re-testing, revert the test session's wiki changes.**

```bash
cd wiki && git log --oneline -3  # find the test's commit
git revert --no-edit <commit-hash>
git push
```

Without this, the next test starts from a different state and the comparison is meaningless. The test session wrote facts into pages, created stubs, updated the backlog — all of that needs to be undone so the next test has the same starting point.

### 7. Re-test

Fresh session, same prompt, same starting wiki state. Run the skill again.

### 8. A/B compare

Side-by-side the two outputs on the same scorecard. For each dimension:

- Did it improve? ✅
- Same? ➡️
- Worse? ❌

Document the comparison. This is the evidence that the fix worked.

### 9. Iterate

If quality is good → done, move on.
If still failing checks → go back to Step 5.

Typically 2-4 iterations to stabilise a new skill. Some skills take more if a philosophical framework is co-evolving with the skill.

### 10. Scorecard-drift check — MANDATORY after any skill-file commit

**After every commit to a skill file, review the corresponding scorecard file (`thoughts/notes/scorecard-<skill>.md` or equivalent) for drift.** Skill files are the contract; scorecards are the grader rubric against that contract. When skills evolve faster than scorecards, the scorecard silently loses coverage of newly-added skill mandates — executors still comply (they read the skill file), but the grader can't verify compliance against criteria that don't exist in the rubric yet.

**Specifically, ask:**

- Does the scorecard have a check for every mandate in the updated skill file?
- Does the scorecard's vocabulary (section names, step numbers, field names) match the skill's?
- Do any scorecard items refer to skill behaviors that no longer exist?

**If any check is missing or stale, update the scorecard in the same commit as the skill-file change** (or in an immediate follow-up commit). The scorecard should never be more than one commit behind the skill it grades.

**Why this matters even under N=2 codification discipline:** scorecard drift is not an emergent agent capability to track cautiously at N=1. It's a maintenance discipline for the prompt-engineering workflow itself. Once observed, codify the discipline — don't wait for a third drift to trigger the N=2 threshold. The N=2 rule exists to prevent over-fitting skills to one-off agent behaviors; it does not apply to scorecard hygiene rules about the author's own workflow.

---

## Anti-patterns

1. **Testing in the engineering session.** The model has all your context — it'll do what you want even with bad instructions. Fresh session is the only valid test.

2. **Not reverting before re-testing.** The wiki state changed from the first test. If you test again without reverting, you're testing a different input. A/B comparison requires same input.

3. **Fixing the output instead of the instruction.** If the model didn't apply source epistemology, don't manually add it to the wiki page. Fix the skill instruction so the model does it next time.

4. **Adding too many instructions at once.** Change one thing, test, see if it worked. Multiple changes make it impossible to know what helped.

5. **Blanket "be better" instructions.** *"Apply the framework more thoroughly"* doesn't work. *"Read wiki/frameworks/ and apply whichever lenses genuinely illuminate THIS question — cite evidence"* does.

6. **Hardcoding content in skills.** Don't list specific philosophers or frameworks in the skill. Say *"read wiki/frameworks/"* — so the skill works when new frameworks are added.

7. **Conflating skill-file edits with scorecard edits.** The two are a contract pair. Edit them together or the grader rots silently.

8. **Scoring against your own memory of what the skill should do.** Load the skill file into the engineering session before scoring. The specification is the ground truth, not the grader's recollection.

---

## Emergent capabilities — the N=1 → N=2 codification rule

Agents (especially strong ones) sometimes do valuable things their skills' explicit instructions didn't mandate. Examples: handling partial outputs gracefully, flagging cross-item contradictions, composing contextualized invocations. These emerge from model capability, not from prompt engineering.

### Why this matters

Without a staging discipline, emergent patterns have two failure modes:

- **Lost to context:** session ends, observation evaporates, pattern isn't available to the next session
- **Over-fit to a one-off:** pattern codified from a single observation turns out not to generalize, skill file gets bloated with rules that fire on corner cases

The N=1 → N=2 rule balances both: capture at first observation; codify at second independent observation.

### The mechanism

Projects maintain a log file (convention: `thoughts/architecture/emergent-capabilities.md` or equivalent project-local path). Each entry captures:

- **Pattern name** — short, memorable
- **Observed** — date + skill run + commit reference
- **What happened** — specific behavior, verbatim output where useful
- **Why valuable** — what a weaker model would miss
- **Codification candidate status** — N=1 (observed, staged) or N=2 territory (ready for codification)
- **Where it might be codified** — candidate skill file + section

### The promotion rule

- **N=1 (first observation):** add to the log. Nothing changes in skill files.
- **N=2 (second independent observation, different run / different context):** promote — edit the appropriate skill file or schema doc to codify the pattern; move the log entry to a "Codified" section with commit link.
- **Retired:** if a pattern turns out not to generalize, archive with a one-line note explaining why. Don't silently delete — the record of the bad call is itself informative.

**"Independent" matters.** Two runs in the same session operating on the same input aren't two independent observations. Two fresh sessions on different tasks observing the same pattern are.

### Exceptions to the N=2 rule

The N=2 discipline applies to **agent behaviors** being codified into skill files (where over-fitting is the real risk). It does NOT apply to:

- **Maintenance disciplines for the prompt-engineering workflow itself** (like scorecard-drift review — codify on first observation, no risk of over-fitting because it's about the author's process, not the agent's)
- **Bug-class failures in the existing skill** (a single reproducible failure is enough to fix the skill; you don't need to see it twice)
- **Schema-level contracts** (e.g., forbidding rename-suggesting language in a staging-entry schema — contract hygiene, not behavior codification)

---

## The lifecycle, at a glance

```
NEW SKILL
   │
   ├── Write (Step 1)
   ├── Test in fresh session (Step 2-3)
   ├── Score + identify fixes (Step 4-5)
   ├── Baseline + re-test + A/B (Step 6-8)
   └── Iterate (Step 9)
         │
         └── ship → runs in production

RUNNING SKILL
   │
   ├── Emergent pattern observed (N=1) → log to emergent-capabilities
   │      │
   │      └── second observation (N=2) → promote → edit skill file → scorecard-drift check (Step 10)
   │
   └── Bug class observed → fix skill file → scorecard-drift check (Step 10)
```

Step 10 fires on every skill-file commit, regardless of whether the commit came from iteration, codification, or bug-fix. The scorecard-drift discipline is orthogonal to the cause of the edit.

---

## Future: `/meta:prompt-engineer <skill-path>` or equivalent

A planned skill that formalizes this entire process as a collaborative guided workflow. The agent handles scaffolding; the human handles judgment.

**The agent would:**

1. Read the skill file, extract every requirement, generate a scorecard
2. Draft a test prompt and tell the user to run it in a fresh session
3. Score the pasted output against the scorecard
4. Propose specific fixes to the skill instructions
5. Generate revert instructions for the wiki/state changes
6. Draft the re-test prompt (same prompt, clean baseline)
7. A/B compare the two outputs side-by-side
8. Iterate until the human says quality is stable

**The human would:**

- Run test sessions (the agent can't — it's contaminated)
- Paste output back
- Approve or redirect fix proposals
- Make the final quality call

**Build this AFTER manually testing several skills.** The manual process will reveal what the skill needs to do. Build from experience, not imagination.

---

## Worked example: the reflect A/B test

(Example preserved for illustration of the full A/B loop.)

**Version 1**: Ran `/wiki:query` as a stress-test on a synthesis page.

- Result: blanket skepticism. Only downgraded claims. No upgrades.
- Diagnosis: query skill doesn't have *"upgrade strong claims"* in its instructions.

**Fix**: Created `/wiki:reflect` with explicit *"upgrade what survived AND downgrade what didn't. Calibrated confidence, not blanket skepticism."*

**Baseline**: Reverted the query's wiki changes.

**Version 2**: Ran `/wiki:reflect` on the same page from a fresh session.

- Result: calibrated confidence. Upgraded some claims, downgraded others, reframed categories, held the rest with appropriate confidence.
- A/B comparison documented alongside.

**Conclusion**: Dedicated skill with explicit balance instruction > generic query used as stress-test.

---

## How projects specialize

Projects using `llm-wiki-os` create a companion overlay at a project-local path (by convention: `thoughts/architecture/prompt-engineering-process.md`). The overlay cites this blueprint and adds **only** project-specific content:

- **Project-specific scorecard locations and conventions** — e.g., `thoughts/notes/scorecard-*.md`, naming rules, frontmatter schemas
- **Skill-specific universal-check additions** — any checks this project wants on every scorecard (e.g., *"did the skill file a GH issue for any new ETL it proposed?"*)
- **Project-specific anti-patterns** — failure modes observed in this project's particular context that aren't generic enough to elevate
- **Concrete emergent-capabilities examples** — the actual log entries for this project, including both in-progress (N=1) and codified entries
- **Project-specific exceptions to the N=2 rule** — workflow-maintenance patterns that got codified without the two-observation threshold, and why
- **References to project-specific `/meta` handlers** — e.g., `/meta grade`, `/meta propose-edit`, `/meta log-emergent` for projects that have built them

The overlay stays thin. The methodology itself lives in this blueprint; project-specific instantiation lives in the overlay.

### Candidates for upstream elevation

When the project's overlay accumulates methodology-level content — not just project-specific instantiation — propose upstream elevation:

1. The overlay names the candidate in its own *"## Candidates for upstream elevation"* section, with a brief rationale for why it might be generic.
2. `/meta propose-edit llm-wiki-os/docs/prompt-engineering.md` drafts the blueprint absorption.
3. User approval → commit to `llm-wiki-os`. Same commit or follow-up: overlay thins, citing the new blueprint section.

This blueprint IS the N=2 codification mechanism, applied recursively to itself: if a pattern appears in multiple projects' overlays, the pattern itself has reached N=2 and earns elevation.

---

## Notes on this blueprint's own evolution

- Subsequent re-occurrence of any pattern in this blueprint (N=2) in a different project should reference back to this methodology rather than re-deriving it.
- If a new step emerges in the iteration loop (e.g., a parallel-sessions pattern, a multi-model grader, etc.), add it to the numbered process rather than opening a sibling doc.
- If the N=2 rule needs additional exceptions beyond the three listed (workflow-maintenance, bug-class, schema-level), append to the "Exceptions" subsection rather than relaxing the rule itself.
- The two-session pattern is the foundational discipline. Changes to the blueprint should preserve it — any mechanism that blurs engineering and testing is the anti-pattern this blueprint exists to prevent.

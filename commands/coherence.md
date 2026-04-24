---
description: "Catch internal contradictions — conjecture pairs implying opposite things; cross-page same-subject disagreements; ground-truth semantic-key collisions. Fourth cleaning gate."
argument-hint: "<synthesis page name or path>"
---

# /wiki-coherence

The wiki's internal-consistency checker. After a synthesis page has been linted (schema OK), audited (figures verified), and reflected (conjectures calibrated), this skill checks whether the page is internally coherent AND consistent with the rest of the wiki that cites it.

Fourth cleaning gate. Catches the failure class none of the other three touch: a page that is structurally clean, factually verified, and epistemically calibrated but still contains contradictions — because two conjectures inside it imply opposite things, or because the same cited row disagrees across pages.

Per `thoughts/architecture/wiki-cleaning-gates.md` §The four invariants and §Dependency chain.

## What this skill does (and does not)

**Does:**
- Pairwise within-page conjecture comparison — for each pair in the target page's hypothesis catalogue, check whether they imply contradicting propositions.
- Cross-page row-ID citation scan — for each `[[page#row-id]]` cited from the target page, grep the wiki for other citations of the same row-ID and flag value disagreements.
- Ground-truth semantic-key scan — group ground-truth rows across pages by semantic key (subject + coordinates + unit) and flag values that disagree.
- Surface contradictions for human resolution.
- Update `coherent_as_of: <date>` frontmatter on pages that pass.

**Does not:**
- Re-verify facts (that's `/wiki-audit`'s job).
- Stress-test conjectures (that's `/wiki-reflect`'s job).
- Check structural integrity (that's `/wiki-lint`'s job).
- Adjudicate "which value is right" when a contradiction is found — surfaces candidates, never picks.
- Auto-resolve contradictions by editing prose.
- Manufacture contradictions out of thin semantic similarity — requires named evidence on both sides.

## Process

### Step 1: Read the wiki state + contracts

1. Read `wiki/CLAUDE.md` — refresh on ground-truth schema, hypothesis-catalogue format, external-claim syntax.
2. Read `wiki/frameworks/` dynamically — all framework pages (new lens adds surface without skill edit).
3. Read `wiki/backlog.md` — pipeline state + Reflect candidates.
4. Read `wiki/index.md`.
5. Read the target synthesis page in full.
6. Read every page the target links to (datasets, events, eras, concepts, other syntheses).

### Step 1.5: Precondition — refuse on missing `stress_tested:`

**Refuse to run if the target synthesis page lacks `stress_tested: <date>` frontmatter.** Coherence on un-reflected conjectures produces garbage: tensions that `/wiki:reflect` would have resolved by downgrading a verdict appear as contradictions, drowning the real ones. Per `thoughts/architecture/wiki-cleaning-gates.md` §Running out of order, coherence depends on reflect.

**If absent, halt with:**

```
REFUSE: cannot check coherence on <synthesis-path> — synthesis is un-reflected.

No `stress_tested:` frontmatter on target page.

Run /wiki:reflect <synthesis-page> first, then re-invoke /wiki:coherence.
```

Do not proceed to Step 2.

- [ ] Refuse to run before Step 2 when target page lacks `stress_tested:` frontmatter — HARD FAIL if skipped.

```check
id: coherence.step1_5.stress-tested-gate
severity: hard-fail
observable: When the target synthesis page lacks `stress_tested:` frontmatter, transcript contains the literal refuse string "REFUSE: cannot check coherence" with the synthesis path named, AND no Step 2 hypothesis-catalogue extraction output appears later in the same session. When `stress_tested:` is present, Step 2 proceeds and the refuse string does not appear.
rationale: Coherence on un-reflected conjectures flags tensions reflect would have resolved by verdict downgrade, drowning real contradictions. Per wiki-cleaning-gates.md §Running out of order + §Dependency chain, coherence depends on reflect. (codified 2026-04-24 per Tranche 3)
```

### Step 1.6: Precondition — refuse on missing/stale `figures_verified:`

**Refuse to run if the target synthesis page's `figures_verified:` frontmatter is missing or stale.** Coherence's ground-truth semantic-key scan (Step 5) would flag value disagreements that audit would have caught first — producing contradictions against unverified baselines.

**Staleness rule:** the synthesis page's `figures_verified:` is stale when the page has been committed *after* the verification date (`git log -1 --format=%cs -- wiki/synthesis/<synthesis-page>.md` returns a date later than the `figures_verified:` value). Same convention as `/story-map:integrate` Step 1 Step 3.

**If missing or stale, halt with:**

```
REFUSE: cannot check coherence on <synthesis-path> — synthesis is un-audited or audit is stale.

`figures_verified:` on target page: <absent | YYYY-MM-DD stale since YYYY-MM-DD>

Run /wiki:audit <synthesis-page> first, then re-invoke /wiki:coherence.
```

Do not proceed to Step 2.

- [ ] Refuse to run before Step 2 when target page's `figures_verified:` is missing or stale (page last-commit date > verification date) — HARD FAIL if skipped.

```check
id: coherence.step1_6.figures-verified-gate
severity: hard-fail
observable: When the target synthesis page's `figures_verified:` is missing or stale, transcript contains the refuse string "REFUSE: cannot check coherence" with the figures_verified state reported, AND no Step 2 extraction output appears later in the same session. When `figures_verified:` is present and fresh (date ≥ page's last-commit date), Step 2 proceeds.
rationale: Without verified figures, Step 5's semantic-key scan flags value disagreements that audit would have resolved. Per wiki-cleaning-gates.md §Dependency chain, coherence runs after reflect, which runs after audit. (codified 2026-04-24 per Tranche 3)
```

### Step 2: Extract conjectures and cited references

From the target synthesis page, extract:

1. **Hypothesis catalogue rows** — the `| ID | Hypothesis | Verdict | Movement | Evidence summary |` table established by `/wiki:reflect`. Each row becomes a candidate for Step 3 pairwise comparison.

2. **Cited row-IDs** — every `[[page#row-id]]` reference in the target's prose. Each becomes a candidate for Step 4 cross-page scan.

3. **Ground-truth rows on linked dataset/era pages** — collected from the pages read in Step 1 step 6. Each row has `(page, row-id, subject, value, coords)`. Each becomes a candidate for Step 5 semantic-key scan.

**If the target has no hypothesis catalogue, halt with:**

```
REFUSE: cannot check coherence on <synthesis-path> — no hypothesis catalogue.

The target page lacks the `| ID | Hypothesis | Verdict | Movement | Evidence summary |` table that /wiki:reflect establishes. Without it there are no conjectures to pairwise-compare.

Run /wiki:reflect <synthesis-page> (which will create the catalogue) first.
```

- [ ] Refuse to run before Step 3 when target page lacks a hypothesis catalogue table — HARD FAIL if skipped.

```check
id: coherence.step2.catalogue-gate
severity: hard-fail
observable: When the target page has no hypothesis-catalogue table, transcript contains the refuse string "REFUSE: cannot check coherence" citing the missing catalogue, AND no Step 3 pairwise comparison output appears. When a catalogue exists, Step 3 proceeds.
rationale: Coherence's within-page pairwise comparison depends on the catalogue's controlled-vocabulary verdicts + stable row IDs. Without the catalogue, Step 3 has no input. (codified 2026-04-24 per Tranche 3)
```

### Step 3: Within-page pairwise conjecture comparison

For every pair of hypothesis-catalogue rows on the target page, ask: **do these two hypotheses, interpreted under their stated verdicts + evidence summaries, imply contradicting propositions about the same subject?**

A genuine contradiction requires:
1. **Same subject axis** — both hypotheses concern the same phenomenon, mechanism, or system (not merely neighboring topics).
2. **Named evidence on both sides** — each hypothesis cites specific evidence that is mutually incompatible with the other's cited evidence.
3. **Non-trivial overlap** — the propositions genuinely intersect, not just share vocabulary.

**Decline to manufacture.** If either hypothesis lacks specific cited evidence, OR if the conflict is semantic-surface only (e.g., "productivity is flat" vs. "productivity is the biggest factor" describe different layers — one observation, one attribution), report "no genuine contradiction" rather than invent one. Per `thoughts/architecture/wiki-cleaning-gates.md` §Observed cross-skill learnings (Zero-Movement re-reflect discipline, 2026-04-20).

Report format per pair (only render pairs where a genuine contradiction is found):

```
#### Within-page contradiction candidate: <row-id-A> vs <row-id-B>
- Hypothesis A: "<text>" (verdict: <>, evidence: <one-line>)
- Hypothesis B: "<text>" (verdict: <>, evidence: <one-line>)
- Shared subject axis: <named axis>
- Why they collide: <one-line>
- Candidate resolution: <genuine contradiction needing reflect re-pass | false-positive | semantic-layer mismatch>
```

- [ ] Do not report a contradiction without named evidence on both sides — HARD FAIL if skipped.

```check
id: coherence.step3.decline-to-manufacture
severity: hard-fail
observable: Every within-page contradiction rendered in Step 3 names specific evidence from both hypotheses' evidence-summary columns. Pairs where either row lacks cited evidence are not rendered as contradictions; the report explicitly says "N pairs checked, M without specific evidence skipped, K genuine candidates surfaced." A reader can audit each surfaced pair back to quoted evidence.
anti-pattern: manufactured-contradiction
rationale: Surfacing semantic-surface conflicts as contradictions drowns real findings and undermines the skill. Per wiki-cleaning-gates.md §Observed cross-skill learnings, calibration-discipline from the 4th-pass re-reflect applies here too. (codified 2026-04-24 per Tranche 3)
```

### Step 4: Cross-page row-ID citation scan

For every `[[page#row-id]]` cited from the target synthesis:

1. Find the row's canonical value on its host page's `## Ground truth` section.
2. Grep the wiki for other citations of `<page>#<row-id>` (or the same numeric value + coordinates).
3. For each inheritor, check that the quoted value matches the canonical row.
4. Flag mismatches.

Report format:

```
#### Cross-page citation disagreement: <page#row-id>
- Canonical value (in <host-page>): <value> at <coords>
- Disagreeing citations:
  - <page-A>: quotes "<value-A>" at <coords-A>
  - <page-B>: quotes "<value-B>" at <coords-B>
- Candidate resolution: <stale-dispersal on target | stale-dispersal on inheritor | semantic-key collision | external-claim mis-marked>
```

Zero-state: if no disagreements found, render `Cross-page citation disagreements: 0` explicitly.

- [ ] Every cited `[[page#row-id]]` on the target page is checked against every wiki citation of the same row — zero disagreements is rendered as `0`, not omitted.

```check
id: coherence.step4.cross-page-zero-state
severity: failure
observable: Step 4 output shows a count line "Cross-page citation disagreements: N" with N rendered as an explicit integer (including 0). The count reconciles against the number of distinct row-IDs the target page cites — transcript shows the set of cited row-IDs and confirms each was grepped.
anti-pattern: silent-omission
rationale: A reader cannot distinguish "skipped check" from "none found" without the explicit zero. (codified 2026-04-24 per Tranche 3)
```

### Step 5: Ground-truth semantic-key scan

Across all ground-truth rows on pages linked from the target, group by semantic key: `(subject, coords, unit)`. Flag groups where member rows disagree on value.

A semantic-key group is a set of rows that *claim to describe the same fact* (e.g., three rows across three pages all claiming to be "Bank Rate all-time high, 1979 Q4, %"). If values within the group disagree, exactly one is right — surface all of them.

Report format:

```
#### Ground-truth semantic-key collision: <subject | coords | unit>
- Rows in group:
  - <page-A>#<row-id-A>: value <V-A>
  - <page-B>#<row-id-B>: value <V-B>
  - <page-C>#<row-id-C>: value <V-C>
- Candidate resolution: <one row is authoritative; others should cite it | coordinates differ subtly (timezone / fiscal year); reconcile | genuine disputed fact; file ### Disputed>
```

Zero-state applies identically.

- [ ] Every ground-truth-row group with same semantic key is compared; zero collisions renders as `0`.

```check
id: coherence.step5.semantic-key-zero-state
severity: failure
observable: Step 5 output shows a count line "Ground-truth semantic-key collisions: N" with N explicit. Transcript shows the grouping logic (rows bucketed by subject+coords+unit) and confirms each multi-row bucket was value-compared.
anti-pattern: silent-omission
rationale: Same reason as Step 4 zero-state. (codified 2026-04-24 per Tranche 3)
```

### Step 6: Report (structured)

```
## Coherence Report: <target synthesis>

### Check coverage
- Hypothesis-catalogue rows: N
- Within-page pairs checked: N*(N-1)/2 = K
- Cited row-IDs scanned: M
- Ground-truth rows in linked pages: J
- Semantic-key groups formed: G

### Contradictions surfaced
- Within-page: N (list each)
- Cross-page citations: N (list each)
- Ground-truth semantic-key: N (list each)
- **Total outstanding contradictions**: N

### Decline-to-manufacture counts
- Within-page pairs without specific evidence on both sides (skipped): K
- Semantic-surface-only conflicts (not rendered as contradictions): L
```

Zero-state discipline applies to every count — 0 renders as 0, never omitted.

- [ ] Every count in the report renders as an explicit integer including 0.

```check
id: coherence.step6.report-zero-state
severity: failure
observable: Every numbered field in the Check coverage + Contradictions sections renders an explicit integer. A grep of the output for each listed field returns a line with an integer value.
anti-pattern: silent-omission
rationale: Silent omission and zero-found are indistinguishable to the reader. Load-bearing for downstream trust. (codified 2026-04-24 per Tranche 3)
```

### Step 7: Surface for human — never adjudicate

For each contradiction surfaced in Step 6, propose candidate resolutions (genuine / stale-dispersal / semantic-layer-mismatch / false-positive / disputed-fact) but **do not pick one**. The human adjudicates.

Output per contradiction (appended to Step 6's listings):

```
#### Candidate resolutions for <contradiction-id>
1. <genuine contradiction — run /wiki:reflect to re-calibrate; may require data gap>
2. <stale dispersal — propagate the correction using /wiki:audit on inheritor pages>
3. <semantic-layer mismatch — reframe one hypothesis to clarify layer; no data change>
4. <false-positive — the two propositions don't actually collide once evidence is read carefully>
5. <genuine disputed fact — file `### Disputed` entry on the host page>

Recommend: <which candidate seems likeliest given the evidence, with one-line reasoning>
Decision: <pending human>
```

- [ ] Never auto-pick a resolution; always enumerate candidates and leave Decision pending — HARD FAIL if skipped.

```check
id: coherence.step7.do-not-adjudicate
severity: hard-fail
observable: For every contradiction rendered in Step 6, Step 7 output shows the "Candidate resolutions" block with at least 2 candidates enumerated and a "Decision: <pending human>" line. No file edits follow Step 7 in the transcript before Step 8's approval gate. Output does NOT say "I picked resolution X and applied it."
anti-pattern: coherence-auto-adjudicates
rationale: Coherence surfaces, humans decide. Auto-adjudication erases the investigation trail and commits to one reading when evidence may not support it. Per wiki-cleaning-gates.md §What it does not. (codified 2026-04-24 per Tranche 3)
```

### Step 8: Approval gate before frontmatter write

**STOP.** Do not write any files yet. Ask the user explicitly:

> Outstanding contradictions: N. Should I mark `<target-path>` with `coherent_as_of: <today's date>`?
>
> - Yes (only valid if N=0)
> - No — leave frontmatter unchanged
> - Resolve first — wait for human to address contradictions before marking

Wait for explicit approval before Step 9.

- [ ] Pause with the frontmatter question before writing `coherent_as_of:` — HARD FAIL if skipped.

```check
id: coherence.step8.approval-gate
severity: hard-fail
observable: Before any Edit/Write tool call modifying frontmatter, transcript contains the literal pause string "Should I mark" with the target path named, AND the session then waits for a user reply before Step 9.
anti-pattern: auto-apply-without-approval
rationale: Every state-changing skill pauses for scope approval. Bypassing destroys the user's option to redirect. (codified 2026-04-24 per Tranche 3)
```

### Step 9: Write `coherent_as_of:` — only if zero contradictions

**Strict rule**: `coherent_as_of: <today's date>` is set ONLY when the Step 6 total outstanding contradictions count is 0 AND the user approved at Step 8. If contradictions remain unresolved, leave frontmatter unchanged — silent bump would over-promise downstream consumers (future `/story-map:integrate` extension, etc.).

If the field was missing, add it. If older, update it.

- [ ] Never bump `coherent_as_of:` when contradictions remain outstanding — HARD FAIL if skipped.

```check
id: coherence.step9.no-bump-with-contradictions
severity: hard-fail
observable: `coherent_as_of:` is set in frontmatter only in sessions where Step 6's total contradiction count was 0. In sessions with N>0, the target page's frontmatter is unchanged — grep of the page after the session shows the pre-session `coherent_as_of:` value (or its continued absence).
rationale: Parallel to audit.md's strict figures_verified: rule. Bumping with unresolved contradictions silently over-promises the marker's contract. (codified 2026-04-24 per Tranche 3)
```

### Step 10: Log

Append to `wiki/log.md`. Word ceiling ~200. Required components:

- Date header `## [YYYY-MM-DD] coherence | <target path>`
- Check coverage counts (catalogue rows, pairs, row-IDs, semantic-key groups)
- Contradiction counts by class (within-page / cross-page / semantic-key)
- Decline-to-manufacture counts
- Resolution status (pending / resolved this session / deferred)
- `coherent_as_of:` updated? (yes/no with reason)
- Pages: <comma-separated target + any page referenced in findings>

Template:

```
## [YYYY-MM-DD] coherence | <target-path>

Checked N hypothesis rows (K pairs), M cited row-IDs, J ground-truth rows (G semantic-key groups). Contradictions: W within-page / C cross-page / S semantic-key (total T). Declined-to-manufacture: L pairs without specific evidence, P semantic-surface-only skipped. Resolution: <pending human | R resolved this session | D deferred to /wiki:reflect or /wiki:audit>. `coherent_as_of:` <updated to YYYY-MM-DD | unchanged because T>0 | unchanged because user declined>.
Pages: <list>
```

- [ ] Log entry conforms to template — all required components present, ≤200 words.

```check
id: coherence.step10.log-template
severity: failure
observable: Appended log entry in wiki/log.md after the session matches the Step 10 template shape: date header, check-coverage counts, contradiction counts, decline-to-manufacture counts, resolution status, coherent_as_of: status, pages list. Word count ≤200 on the appended entry.
rationale: Dense narrative template ensures downstream readability + machine-parseability across runs. (codified 2026-04-24 per Tranche 3)
```

### Step 11: Commit

```bash
cd wiki && git add -A && git commit -m "coherence: <scope> — <outcome>"
```

Commit scope: **wiki repo only.** Coherence does not touch skill files, architecture docs, or scorecards — those edits belong to `/meta` workflows.

- [ ] Commit scope is `wiki/` only; commit message follows `coherence: <scope> — <outcome>` shape.

```check
id: coherence.step11.commit-shape
severity: failure
observable: Post-session `git log -1` in wiki repo shows a commit whose message begins `coherence:` and whose changed-files are all under `wiki/`. No edits to `.claude/`, `thoughts/`, `llm-wiki-os/`, or `apps/` appear in the same commit.
anti-pattern: commit-wrong-repo
rationale: Four-repo mental model requires per-skill commit-scope discipline. (codified 2026-04-24 per Tranche 3)
```

---

## Invocation patterns

**Per-page coherence check** (default):
```
/wiki-coherence <synthesis-page-path-or-name>
```
Example: `/wiki-coherence synthesis/why-uk-building-costs-high`. Runs all five checks (within-page pairs, cross-page row-IDs, semantic-key groups) against the target.

**Empty invocation:**
```
/wiki-coherence
```
Lists all synthesis pages with `stress_tested:` AND `figures_verified:` frontmatter (eligible for coherence check) and asks which to target. Pages missing either marker are listed separately with "needs /wiki:reflect" or "needs /wiki:audit" tags.

**Future hardening (not yet enforced):**
- **Global scan** (`/wiki-coherence --global`): semantic-key scan across ALL ground-truth rows in the wiki, not just rows on pages linked from a target. Produces a wiki-wide collision report. Deferred because first-run fixture validates per-page first; global opens up quadratic-compute scope and merits its own design pass.
- **Downstream gating** on `coherent_as_of:`: `/story-map:integrate` could extend its precondition check to require `coherent_as_of:` alongside `stress_tested:` + `figures_verified:`. Deferred until the fourth gate has proven load-bearing across multiple runs.

## Interaction with other skills

- **After `/wiki:reflect`** (primary): reflect produces/updates the hypothesis catalogue + stress_tested: frontmatter. Coherence reads the catalogue and checks within-page + cross-page consistency. Natural next step after a significant reflect.
- **After `/wiki:audit`** (secondary): when audit resolves CONTRADICTED claims across pages, coherence can verify the propagation actually landed consistently. Useful on pages that inherit many cited values.
- **Before `/story-map:integrate`** (future): integrate may gate on `coherent_as_of:` in addition to `stress_tested:` + `figures_verified:` once the fourth gate is established. Currently future-hardening.

## Why this skill is separate from the others

Lint checks **structure**. Audit checks **facts**. Reflect checks **conjectures**. Coherence checks **consistency**.

A page can:
- Pass lint (schema perfect) and fail audit (a figure is wrong).
- Pass lint + audit (figures correct) and fail reflect (a conjecture is unfalsifiable).
- Pass all three and fail coherence (two of its calibrated conjectures imply opposite things about the same subject; OR the same cited row appears with different values on two other pages).

The first three catch production-line errors; coherence is the integration test. Without it, a wiki can be structurally clean, factually verified, and epistemically calibrated and still tell contradicting stories.

Per `thoughts/architecture/wiki-cleaning-gates.md` §The four invariants — this is the fourth one.

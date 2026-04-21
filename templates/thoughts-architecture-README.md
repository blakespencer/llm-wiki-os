# thoughts/architecture/ — project-local overlays

This directory holds **project-local overlays** of the generic blueprints at `llm-wiki-os/docs/*.md`. Drop this README into your `<project>-thoughts/architecture/` directory as a starter; it tells future Claude Code sessions what this directory is for.

## The blueprint + overlay + elevation pattern

`llm-wiki-os/docs/*.md` holds **generic methodology** — the ground/ceiling/lenses scaffold, the three-layer compilation model, the four-gate cleaning model, the plans-are-hypotheses principle, etc. That methodology is reusable across any project using `llm-wiki-os`.

Projects specialize each blueprint with a **thin overlay** here. The overlay:

- Cites the blueprint (at the top, as *"See also `llm-wiki-os/docs/<name>.md` — the genericized blueprint"*)
- Contains **only project-specific content**: motivating incidents, concrete row-IDs, integration points with project-specific consumer skills, build-order progress, worked examples with your domain's actual entities/datasets
- Does NOT restate the generic methodology (that's in the blueprint)

**Canonical-reading principle.** For files read by skills — the project's own `wiki/CLAUDE.md` — the project's canonical reading lives there, with the blueprint as a "see also" rather than a replacement. For thin overlays here, the blueprint carries the methodology and the overlay carries the project-specific instantiation.

## Overlay files you might create

The typical overlay set mirrors the blueprint set:

| Blueprint | Typical overlay filename |
|-----------|-------------------------|
| `llm-wiki-os/docs/karpathy-fidelity.md` | `wiki-claim-fidelity.md` — your project's motivating incidents + specific row-ID examples |
| `llm-wiki-os/docs/cleaning-gates.md` | `wiki-cleaning-gates.md` — your project's shipping priority for cleaning-gate improvements |
| `llm-wiki-os/docs/prompt-engineering.md` | `prompt-engineering-process.md` — your project's scorecard conventions + A/B test history |
| `llm-wiki-os/docs/planning-discipline.md` | `planning-discipline.md` — your project's worked examples of reconnaissance-kills-assumption |
| `llm-wiki-os/docs/pipeline-composition.md` | `<methodology>-pipeline.md` — your project's product-strategy methodology choice (if any) and its instantiation |
| `llm-wiki-os/docs/philosophical-framework.md` | Usually instantiated in `wiki/CLAUDE.md` directly rather than a separate overlay |
| `llm-wiki-os/docs/source-epistemology.md` | Usually instantiated in `wiki/CLAUDE.md` directly |
| `llm-wiki-os/docs/data-quality-discontinuities.md` | Usually instantiated in `wiki/CLAUDE.md` directly |

You do not need to create all of these up front. Start empty; add an overlay when you have project-specific thinking substantive enough to record.

## Elevation — overlay → blueprint

When overlay content turns out to be **generic** (observed across multiple projects, OR recognized as not project-specific), propose it back to the blueprint. Each overlay can end with a *"## Candidates for upstream elevation"* section listing patterns that might elevate.

Elevation mechanism:
1. Overlay's *"Candidates for upstream elevation"* section names the candidate with rationale.
2. `/meta propose-edit llm-wiki-os/docs/<name>.md` (or equivalent authorised tool) drafts the blueprint absorption.
3. User approves → commit to `llm-wiki-os`. Overlay thins, citing new blueprint section.

This is the doc-level equivalent of the N=2 codification rule that governs skill-file edits (see `llm-wiki-os/docs/prompt-engineering.md`).

## Preservation default

When editing overlays (and any project-carried architecture doc), **preservation is the default**. The LLM's default behavior of "tidy up / dedupe when editing a doc" is WRONG for documents carrying careful thought. Explicit rule:

- Removing content requires proving it exists at a specific readable location skills can find
- "The blueprint has it" is NOT sufficient if the overlay's removed content is project-specific instantiation that the blueprint (being generic) doesn't carry
- Before any non-trivial edit, run `git diff <pre-state> HEAD -- <file>` as part of the audit

## Reference

The uk-legalize project's `thoughts/architecture/` directory is the reference implementation:

- `wiki-claim-fidelity.md`
- `wiki-cleaning-gates.md`
- `prompt-engineering-process.md`
- `planning-discipline.md`
- `story-map-pipeline-design.md`

Worth browsing when you're writing your own overlays.

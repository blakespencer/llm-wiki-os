# Philosophical Framework

The ground/ceiling/lenses scaffold that Karpathy-pattern wikis use to hold multiple interpretations without collapsing into single-answer analysis. Generic methodology; each project instantiates it with its own specific ground substrate, ceiling posture, and lens set.

**This is a blueprint.** Projects using `llm-wiki-os` specialize via their `wiki/CLAUDE.md` schema file (and optionally a companion overlay at `thoughts/architecture/philosophical-framework.md` if the framework evolves substantially). See the *"How projects specialize"* section at the end.

Related blueprints:
- `karpathy-fidelity.md` — the write-time correctness invariant; fidelity is what keeps "multiple lenses" from becoming "multiple unverified claims"
- `cleaning-gates.md` — `/wiki:reflect` (epistemic-honesty gate) is where the philosophical framework gets exercised against real claims
- `source-epistemology.md` — applies the Popperian ceiling to the *input* layer (data sources) rather than only the output layer (interpretations)
- `pipeline-composition.md` — the framework governs what synthesis pages look like at the end of Pipeline 1
- `data-quality-discontinuities.md` — the ceiling's *"surface disagreement between data sources"* mandate manifests concretely in splice/coverage/overlap documentation

Related skills: `llm-wiki-os/commands/{ingest,query,reflect}.md` (these read `wiki/CLAUDE.md` to apply the project's specific framework).

---

## The ground/ceiling/lenses scaffold

Two foundations — the **ground** and the **ceiling** — govern every page in the wiki. They are not lenses; they are the terrain and the limits of the map. Between them sit **lenses** — different viewpoints on the same terrain.

```
GROUND: The terrain we're studying — complex adaptive systems
                    │
    ┌───────────────┼───────────────┐
    │               │               │
  Lens A          Lens B          Lens C         ...more lenses...
  (e.g., info    (e.g., agent    (e.g., evo-
   flow)          behaviour)     lutionary)
    │               │               │
    └───────────────┼───────────────┘
                    │
CEILING: The limits of what we can know — Popperian falsification
```

The scaffold is **not a hierarchy**. Ground and ceiling bracket the analysis; lenses interact at the middle level. The human weights lenses for a given question; the wiki holds all of them.

## The ground: complex systems

Everything a Karpathy-pattern wiki studies is a **complex adaptive system** — you cannot understand it by decomposition. You have to stress it under different conditions and observe what emerges.

For domain wikis, the ground layer typically decomposes into interlocking sub-systems. Example shape (uk-legalize's instance, with variable names for portability):

```
<EMERGENT LAYER> (the outcomes — observed, not designed)
    │
    │ emerges from
    │
<RULES LAYER> (institutions, policies, regulations — designed, changeable)
    │
    │ created by
    │
<SOCIAL LAYER> (coordination — culture, norms, institutions)
    │
    │ composed of
    │
<AGENT LAYER> (near-universal properties — psychology, physics, biology)
```

**Circular, not purely layered.** Each layer shapes the others in feedback. The wiki should be explicit about which layer each page describes — without the mapping, readers can't tell whether a claim is near-universal (agent-layer) or contingent on a specific society (rules-layer + social-layer).

**Why this matters**: no single dataset tells the story. The connections between datasets reveal what individual datasets cannot. Each crisis or major event is a **natural experiment** — the same interlocking systems under different stress, revealing different dynamics.

## The ceiling: Popperian falsification

Given that we're studying complex systems, **every causal claim is a conjecture** — testable against data, never provable. We can't run controlled experiments. Even if we could, the system's complexity means emergence would still surprise us.

**Certainty is impossible. Dogma is the enemy.**

The wiki's job is to:

1. **Present what the data shows** — factual, cited, specific
2. **Offer multiple lenses** — not pick a winner
3. **Surface disagreement** — between data sources AND between interpretations
4. **Never claim certainty** — *"the data is consistent with X"* not *"X caused Y"*
5. **Never land on a single answer** — see below

## Single-answer analysis is always wrong

This is a core principle, not a guideline. When the wiki analyses any topic — an event, a policy, an outcome — it must **never present one interpretation as THE answer.** Multiple lenses will produce multiple readings, and the honest position is that we cannot know which weighting is correct.

Why:

- The system is complex (the ground layer) — multiple causes operate simultaneously at different levels
- We can't run the counterfactual (the ceiling) — every causal claim is conjecture
- Different moral foundations / cognitive frames lead honest observers to weight the same evidence differently
- Different visions of human nature / society produce different interpretations of the same data
- The cultural moral matrix constrains which solutions are even permissible — and that matrix evolves over time, changing the interpretive space independently of the data

**A wiki page that presents one clean explanation is a wiki page that's lying about the complexity of reality.**

The `### Through different lenses` section convention (see below) exists for this reason. Every synthesis page, every query answer, every discovery report should present multiple interpretations. The human decides the weighting. The wiki never does.

## The lenses: viewpoints on the same terrain

Between ground and ceiling sit **lenses** — different viewpoints on the same complex system. Each emphasises a different aspect. None is wrong. None is complete.

Lenses are **project-specific**: a macro-economic wiki might use Hayek (information flow), Behavioral (agent biases), Schumpeter (creative destruction), Taleb (antifragility). A health wiki might use biomedical, behavioural, environmental, evolutionary. A due-diligence wiki might use financial, strategic, operational, cultural. The scaffold is generic; the lens choices are domain decisions.

**Lens interactions**: lenses are not independent silos. A well-designed lens set has interaction effects:

- Lens A's output becomes Lens B's input (e.g., price signals → agent psychology → revised signals)
- Lens B's assumptions invert Lens C's (e.g., rational-actor models vs bounded-rationality models on the same data)
- All lenses are ultimately conjectural under the ceiling (the Popperian constraint)

Projects should document lens interactions explicitly in their framework pages, not leave them as implicit.

## Lenses in synthesis pages

Synthesis pages may include a `### Through different lenses` section. **Present each lens as a perspective, not a conclusion.** The human weights; the wiki presents.

Template:

```markdown
### Through different lenses

**<Lens A name> (<thinker/tradition>)**: <one-paragraph reading of the event/topic
through this lens. Cite specific data. Keep hedged.>

**<Lens B name> (<thinker/tradition>)**: <one-paragraph reading through this lens.
Note where it disagrees with Lens A above, if it does.>

**<Lens C name> (<thinker/tradition>)**: <one-paragraph reading.>

**Popperian caveat**: We observe <what the data shows>. We conjecture <the causal
interpretation>. But we cannot run the counterfactual. This is our best conjecture.
```

The Popperian caveat is not optional — it's the ceiling manifest in every synthesis.

## Systems-thinking → page-type mapping

The ground layer's structure (elements, relationships, function, stocks-and-flows, emergent phenomena) maps to wiki page types:

| System component | Wiki page type | Notes |
|---|---|---|
| **Elements** | Entity pages, dataset pages | Named actors, datasets, institutions |
| **Relationships** | Annotated wikilinks, synthesis pages | The "associative trails" Karpathy describes — the connections that compound |
| **Function / purpose** | Concept pages, era pages | What a mechanism is supposed to do (stated purpose) vs what it actually does (observed outcome) |
| **Stocks & flows** | Dataset pages (the stocks); event pages (the flow changes) | Stock = level at a point in time; flow = change over time |
| **Emergent phenomena** | Concept pages (category: emergent-phenomenon), event pages | Recurring patterns observed across multiple instances that nobody designed |

**Emergent phenomena are distinct from lenses**: emergent phenomena are recurring patterns *observed* across multiple instances (bubbles, productivity paradoxes, regime shifts). Lenses are interpretive *frameworks* used to explain the phenomena. Label concept pages with `category: emergent-phenomenon` in frontmatter when they describe observed system behaviour rather than an interpretive framework.

## Role division (LLM vs human)

The Karpathy pattern's implicit division of labour:

- **The LLM maintains framework pages, does the bookkeeping** (cross-links, dispersal, pre-compilation of facts). This is what makes the wiki compound — the LLM does the labor the human would otherwise abandon.
- **The human decides which lenses are most illuminating for a given question** (thinking about what it all means). The wiki is a thinking tool, not a thinking-for-you tool.
- **The human directs the research** — chooses which sources to pursue, which questions to file, which conjectures to stress-test.

**Violation shapes** to watch for:

- LLM decides which lens is correct → single-answer drift
- Human hand-writes every cross-reference → LLM isn't pulling its weight; wiki stops compounding
- LLM refuses to synthesize because "the human should do it" → wiki loses the "connections already there" property

The division is load-bearing. Get it wrong in either direction and the pattern collapses.

---

## How projects specialize

Projects using `llm-wiki-os` specialize this blueprint in their `wiki/CLAUDE.md` schema file (and optionally an overlay at `thoughts/architecture/philosophical-framework.md`). Specialization includes:

- **Ground substrate** — the specific complex-system decomposition for this domain. Macro-economic wiki: agent psychology → society → rules → economy. Health wiki: molecular → cellular → organ-system → organism → population. Startup due-diligence wiki: founders → team → product → market → ecosystem.
- **Ceiling posture** — does the project use pure Popper, or Popper + Hume's is/ought, or Taleb's epistemic humility, or something else? The ceiling's specific shape is a project decision.
- **Lens set** — which specific thinkers/traditions the project treats as its lens palette, and the reasoning behind each choice. Lens choices evolve; the choice itself is project-specific.
- **Framework pages** — one per lens at `wiki/frameworks/*.md` with the concrete application of the lens to this domain's datasets.
- **Worked examples** — the project's canonical events/eras/topics that illustrate the scaffold in action.

### Candidates for upstream elevation

When a project's specialization accumulates content that turns out to be generic (observed across projects, OR recognized as not domain-specific), propose upstream elevation:

1. The overlay names the candidate with a brief rationale.
2. `/meta propose-edit llm-wiki-os/docs/philosophical-framework.md` drafts the absorption.
3. User approval → commit to `llm-wiki-os`. Same commit or follow-up: overlay/schema thins, citing the new blueprint section.

Doc-level equivalent of the N=2 rule (see `prompt-engineering.md`).

---

## Notes on this blueprint's own evolution

- The ground/ceiling/lenses scaffold is foundational. Changes should preserve the three-layer structure — if a change implies collapsing lenses into "the right answer" or dropping the Popperian ceiling, it's a different framework.
- The role division (LLM bookkeeping + human interpretation) is the second-most-important piece. Any change that blurs it (e.g., "the LLM picks the best lens") is the anti-pattern this blueprint exists to prevent.
- Specific lens choices (Hayek, Kahneman, etc.) are NOT in the blueprint — those are project-specific. Adding them here would make the blueprint project-coupled and less reusable.
- The worked-example template (`### Through different lenses` with Popperian caveat) is Karpathy-wiki canon. Alternative template shapes may emerge (lens-table format, per-lens dedicated pages); add to this blueprint when a second project uses an alternative shape.

# llm-wiki-os

A generic operating system for LLM-maintained wikis. Based on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

## What this is

A set of Claude Code skills + architecture blueprints that operate on any markdown wiki following the Karpathy LLM Wiki pattern. The skills are domain-agnostic — they read the wiki's `CLAUDE.md` schema to learn the domain-specific conventions, page types, and philosophical framework. The blueprints document the generic methodology; each project overlays them with its own specific instantiation.

## Skills

| Skill | What it does |
|-------|-------------|
| `/wiki:discover` | Find gaps, research online, propose new data sources. The compounding-loop entry point. |
| `/wiki:ingest` | Process a source (dataset, article, URL) into the wiki, dispersing knowledge across multiple pages |
| `/wiki:query` | Ask a question, answer from wiki first, disperse findings, file the answer back |
| `/wiki:lint` | Structural health-check: broken links, missing sections, orphan pages, zero-state discipline |
| `/wiki:audit` | Verify numeric claims in wiki prose against primary data; set `figures_verified:` frontmatter |
| `/wiki:reflect` | Stress-test synthesis-page conjectures (seven-lens falsification); set `stress_tested:` frontmatter |
| `/wiki:pilot` | Wiki-kit ideation advisor — primed context on blueprints + schema + overlays; helps you design, bootstrap, and think |

Cleaning-gate dependency chain: `/wiki:lint` → `/wiki:audit` → `/wiki:reflect` → `/wiki:coherence` *(planned)*. See `docs/cleaning-gates.md`.

## Blueprints (`docs/`)

Generic architecture blueprints that every project using this kit can read. Projects specialize via thin overlays at `thoughts/architecture/*.md` (see "Blueprint + overlay pattern" below).

| Blueprint | What it covers |
|-----------|---------------|
| `docs/karpathy-fidelity.md` | Write-time correctness invariant, three-layer compilation (primary sources → ground-truth tables → synthesis prose), row-ID grammar, external-claim marking syntax |
| `docs/cleaning-gates.md` | Four-gate cleaning model (lint/audit/reflect/coherence), dependency chain, CI/CD-for-the-brain analogy |
| `docs/prompt-engineering.md` | Two-session iteration pattern for skill quality, N=1→N=2 codification rule, scorecard-drift discipline |
| `docs/planning-discipline.md` | Reconnaissance-kills-assumption pattern; plans are hypotheses, not contracts |
| `docs/pipeline-composition.md` | Three-pipeline composition (data quality → product strategy → implementation); perpetual feedback loop |
| `docs/philosophical-framework.md` | Ground/ceiling/lenses scaffold (complex systems / Popperian falsification / interpretive lenses) |
| `docs/source-epistemology.md` | 7-question framework for source skepticism, source-type spectrum table, "right grip" principle |
| `docs/data-quality-discontinuities.md` | Splice / coverage / overlap three-category documentation discipline |

## How it works

The skills are the **operating system**. The wiki's `CLAUDE.md` is the **configuration**. The wiki pages are the **data**. The blueprints are the **shared methodology**.

```
llm-wiki-os (this repo)
├── commands/    — skills: HOW to operate (what agents do)
└── docs/        — blueprints: generic methodology, reusable across projects
    reads ↓
wiki/CLAUDE.md               — WHAT the wiki is (schema + domain-specific instantiation)
    operates on ↓
wiki/**/*.md                  — THE KNOWLEDGE (pages, links, synthesis)

thoughts/architecture/*.md   — project overlays (uk-legalize-specific thinking
                                that specializes each blueprint)
```

The skills never reference any domain-specific content. They say "read the schema and do what it says." You could point them at:

- A UK government accountability wiki (the reference implementation: `uk-legalize`)
- A personal health wiki
- A startup due diligence wiki
- A book-reading companion wiki
- A clinical-research wiki
- A personal journal

Same skills. Different `CLAUDE.md`. Different content.

## The blueprint + overlay + elevation pattern

Generic wiki-kit architecture lives at `llm-wiki-os/docs/*.md` as **blueprints** — reusable across any project using this kit. Projects specialize via thin **overlays** at `thoughts/architecture/*.md` that cite their blueprint counterpart and add only project-specific content (motivating incidents, concrete instance examples, integration points with project-specific consumer skills). When overlay content turns out to be generic — observed across multiple projects or recognized as not project-specific — it can be **elevated** back to the blueprint via `/meta propose-edit llm-wiki-os/docs/<name>.md` or equivalent.

Each blueprint has a closing *"How projects specialize"* section explaining what goes in its corresponding overlay. Each overlay has a closing *"Candidates for upstream elevation"* section tracking patterns that might belong in the blueprint.

## Bootstrap a new project

Setting up a new project that uses this wiki kit is a 5-step sequence. Each project is multi-repo: a main repo + a wiki-content repo + (optionally) a thoughts/architecture repo for overlays.

### Step 0 — Pick your domain

Before writing any code, decide what this wiki is ABOUT. The domain choice shapes everything downstream: your ground-layer decomposition, your lens set, your source landscape, your page types.

Examples: *"UK government accountability"*, *"personal health over time"*, *"startup due diligence for early-stage VC"*, *"books I've read and what connects them."*

### Step 1 — Create the sibling-repo structure

```
<parent-dir>/
├── llm-wiki-os/              ← this repo (clone once, shared)
├── <project>/                ← your project's main repo
├── <project>-wiki/           ← wiki content repo (Karpathy pattern)
└── <project>-thoughts/       ← (optional) project-local overlays + state
```

```bash
# From <parent-dir>:
git clone https://github.com/blakespencer/llm-wiki-os.git  # if not already present
mkdir <project>
mkdir <project>-wiki
mkdir <project>-thoughts   # optional
cd <project>
git init
```

### Step 2 — Set up symlinks from the main repo

```bash
# Inside <project>/:
ln -s ../<project>-wiki wiki
ln -s ../<project>-thoughts thoughts    # optional
ln -s ../llm-wiki-os llm-wiki-os        # so blueprints resolve from wiki/CLAUDE.md
mkdir -p .claude/commands
ln -s ../../../llm-wiki-os/commands .claude/commands/wiki

# Add to .gitignore:
echo -e "/wiki\n/thoughts\n/llm-wiki-os" >> .gitignore
```

The symlinks make `wiki/`, `thoughts/`, and `llm-wiki-os/` appear inside your project while the actual content stays in sibling repos.

(There's also an optional `templates/bootstrap.sh` script that automates this setup.)

### Step 3 — Write your `wiki/CLAUDE.md` schema

This is where the real domain work lives. Start from the template:

```bash
cp llm-wiki-os/templates/wiki-CLAUDE-template.md <project>-wiki/CLAUDE.md
```

Open `<project>-wiki/CLAUDE.md` and fill in the `<PLACEHOLDERS>` — your domain's:

- **Ground-layer decomposition** — what are the 3-5 interlocking systems your domain studies? (For uk-legalize: emergent economy / rules / society / human-nature. For a clinical wiki: molecular / cellular / organ-system / organism / population.)
- **Lens set** — 3-7 thinkers/traditions that illuminate your domain. Each becomes a page at `wiki/frameworks/<thinker>.md`.
- **Source-type skepticism-spectrum table** — your domain's actual institutional landscape, each row rated low / low-medium / medium / high / very high skepticism.
- **Page types** — entity / event / concept / dataset / synthesis / question are common; add domain-specific types as needed.

The blueprints at `docs/philosophical-framework.md` and `docs/source-epistemology.md` are designed to read as fill-in-the-blanks templates. Reference them while writing your CLAUDE.md.

### Step 4 — Run `/wiki:pilot` for the intellectual bootstrap

Open a fresh Claude Code session in the project and invoke:

```
/wiki:pilot help me bootstrap this new project
```

Pilot loads the blueprints + your new `wiki/CLAUDE.md` + overlays, then walks you through:

- Does the schema match the domain? Where does it not fit?
- Are the lens choices illuminating or ceremonial?
- Is the source-type table matching your actual sources?
- Any hardcoded uk-legalize assumptions you're about to inherit?

This is the cheapest way to surface drift before it becomes content drift.

### Step 5 — Ingest your first source

Start small. Pick one concrete question or data source. Run the full pipeline:

```
/wiki:discover "<your first question>"
```

Then when approved:

```
/wiki:ingest <source>   # one source, not ten
/wiki:audit <dataset>   # verify figures before synthesis
/wiki:reflect <synthesis-page>  # stress-test conjectures
```

Observe what breaks. Fix the kit OR your CLAUDE.md OR the overlay. Iterate.

## The compounding loop

```
/wiki:discover → finds gaps → proposes data sources → updates backlog
    ↓ (human approves)
/wiki:ingest   → processes source → disperses across pages → fills stubs
    ↓
/wiki:audit    → verifies numeric claims against primary data → sets figures_verified:
    ↓
/wiki:query    → answers from wiki → disperses findings → reveals new gaps
    ↓
/wiki:reflect  → stress-tests synthesis → upgrades/downgrades/holds → sets stress_tested:
    ↓
/wiki:lint     → health-check → suggests next questions → reads backlog
    ↓
/wiki:discover → cycle continues, wiki compounds
```

Each skill reads and writes `wiki/backlog.md` — the shared state that makes the loop actually loop.

## Project-specific vs generic

A useful mental model for what lives where:

| Lives in | Contains |
|---|---|
| `llm-wiki-os/commands/` | Generic skills (read your schema to specialize) |
| `llm-wiki-os/docs/` | Generic blueprints (methodology reusable across projects) |
| `wiki/CLAUDE.md` | Your project's schema + domain-specific instantiation (canonical reading of the blueprints) |
| `wiki/**/*.md` | Your project's knowledge content |
| `thoughts/architecture/` | Project-local overlays (your specific choices, motivating incidents, integration points with your project-specific skills) |
| `.claude/commands/` | Project-specific skills (operator, meta, product-strategy methodology skills) |

**Preservation default:** when editing `wiki/CLAUDE.md` or any project-carried architecture doc, preservation is the default. Removing content requires proving it exists at a specific readable location. The LLM default of "tidy up / dedupe" is the wrong default for documents carrying careful thought.

## Key principles baked into the skills

1. **Information dispersal** — every operation enriches many pages, not just one
2. **Pre-compilation** — write facts into pages during ingest so future queries don't re-derive from raw data
3. **No bare links** — every `[[wikilink]]` needs a why-clause (associative trails)
4. **Single-answer analysis is always wrong** — multiple lenses, multiple interpretations
5. **Source epistemology** — question who produced the data and why
6. **Schema co-evolution** — skills propose schema improvements when patterns emerge
7. **Suggested next** — every skill ends by recommending the highest-value next action
8. **Write-time fidelity** — numeric claims cite ground-truth rows; the wiki's correctness is a precondition, not a defensive surface (see `docs/karpathy-fidelity.md`)
9. **Calibrated confidence** — upgrade strong claims AND downgrade weak ones, not blanket skepticism

## Reference implementation

The `uk-legalize` project at [https://github.com/blakespencer/uk-legalize](https://github.com/blakespencer/uk-legalize) is the reference implementation. Its `wiki/CLAUDE.md`, overlays at `thoughts/architecture/`, and `.claude/commands/` demonstrate the patterns this kit was designed around. Worth browsing when you get stuck on "what should this look like in my project?"

## Credits

Pattern: [Andrej Karpathy](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
Reference implementation + blueprint set: [blakespencer/uk-legalize](https://github.com/blakespencer/uk-legalize)

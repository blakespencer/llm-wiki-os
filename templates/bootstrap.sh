#!/usr/bin/env bash
# Bootstrap a new project using llm-wiki-os.
#
# Run from the parent directory where llm-wiki-os is already cloned.
# Creates: <project>/, <project>-wiki/, (optionally) <project>-thoughts/
# Wires: symlinks + .gitignore + starter CLAUDE.md from template
#
# Usage:
#   ./llm-wiki-os/templates/bootstrap.sh <project-name> [--no-thoughts]
#
# Example:
#   ./llm-wiki-os/templates/bootstrap.sh my-health-wiki

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <project-name> [--no-thoughts]" >&2
  exit 1
fi

PROJECT="$1"
INCLUDE_THOUGHTS=true
if [ "${2:-}" = "--no-thoughts" ]; then
  INCLUDE_THOUGHTS=false
fi

# Run from the parent directory containing llm-wiki-os/
if [ ! -d "llm-wiki-os" ]; then
  echo "Error: llm-wiki-os/ not found in current directory." >&2
  echo "Run this script from the parent directory where llm-wiki-os is cloned." >&2
  exit 1
fi

if [ -d "$PROJECT" ]; then
  echo "Error: directory '$PROJECT' already exists." >&2
  exit 1
fi

TEMPLATE="llm-wiki-os/templates/wiki-CLAUDE-template.md"
if [ ! -f "$TEMPLATE" ]; then
  echo "Error: template not found at $TEMPLATE" >&2
  exit 1
fi

echo "→ Creating sibling repo directories..."
mkdir "$PROJECT"
mkdir "${PROJECT}-wiki"
if [ "$INCLUDE_THOUGHTS" = true ]; then
  mkdir "${PROJECT}-thoughts"
fi

echo "→ Copying wiki/CLAUDE.md template into ${PROJECT}-wiki/..."
cp "$TEMPLATE" "${PROJECT}-wiki/CLAUDE.md"

echo "→ Initializing git in each repo..."
(cd "$PROJECT" && git init -q)
(cd "${PROJECT}-wiki" && git init -q)
if [ "$INCLUDE_THOUGHTS" = true ]; then
  (cd "${PROJECT}-thoughts" && git init -q)
fi

echo "→ Creating symlinks inside $PROJECT/..."
cd "$PROJECT"
ln -s "../${PROJECT}-wiki" wiki
if [ "$INCLUDE_THOUGHTS" = true ]; then
  ln -s "../${PROJECT}-thoughts" thoughts
fi
ln -s "../llm-wiki-os" llm-wiki-os
mkdir -p .claude/commands
ln -s "../../../llm-wiki-os/commands" .claude/commands/wiki

echo "→ Writing .gitignore..."
cat > .gitignore <<'EOF'
# Sibling-repo symlinks (not part of this repo)
/wiki
/thoughts
/llm-wiki-os

# Common
node_modules/
.DS_Store
.env
.env.local
*.log
tmp/
.cache/
EOF

cd ..

echo ""
echo "✓ Bootstrap complete for project: $PROJECT"
echo ""
echo "Next steps:"
echo "  1. Open ${PROJECT}-wiki/CLAUDE.md and fill in <PLACEHOLDERS> with your domain specifics"
echo "  2. Open a Claude Code session in $PROJECT/ and run: /wiki:pilot help me bootstrap this new project"
echo "  3. Then: /wiki:discover \"<your first question>\" to begin the compounding loop"
echo ""
echo "Reference implementation: https://github.com/blakespencer/uk-legalize"
echo "Blueprints: $PROJECT/llm-wiki-os/docs/*.md"

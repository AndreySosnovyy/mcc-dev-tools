#!/usr/bin/env bash
# install-skill.sh — install a Claude Code skill from mcc-dev-tools.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/AndreySosnovyy/mcc-dev-tools/main/scripts/install-skill.sh) <skill-name>
#
# Or after cloning the repo:
#   bash dev-tools/scripts/install-skill.sh <skill-name>
#
# Available skills are listed in dev-tools/skills/*. The script downloads the
# selected skill into ~/.claude/skills/<skill-name>/, replacing any previous
# version. After install, restart Claude Code (or open a new session) for the
# skill to be picked up.

set -euo pipefail

# Prerequisites.
command -v git >/dev/null 2>&1 || {
  echo "[install-skill] git is required (brew install git or xcode-select --install)"
  exit 1
}

SKILL_NAME="${1:-}"
# MCC_DEV_TOOLS_REPO / MCC_DEV_TOOLS_BRANCH — опциональные overrides (для CI /
# форков). Override ТОЛЬКО если понимаешь security implications — указывая
# кастомный репо, ты доверяешь его содержимому выполняться как Claude Code skill.
REPO_URL="${MCC_DEV_TOOLS_REPO:-https://github.com/AndreySosnovyy/mcc-dev-tools.git}"
BRANCH="${MCC_DEV_TOOLS_BRANCH:-main}"

if [[ -z "$SKILL_NAME" ]]; then
  echo "Usage: install-skill.sh <skill-name>"
  echo ""
  echo "Available skills (from $REPO_URL):"
  echo "  mr-template-author  — author MCC MR description templates (Mustache)"
  exit 1
fi

# Validation: only [a-zA-Z0-9_-]+, length ≤ 50.
if ! [[ "$SKILL_NAME" =~ ^[a-zA-Z0-9_-]+$ ]] || [[ ${#SKILL_NAME} -gt 50 ]]; then
  echo "[install-skill] invalid skill name: $SKILL_NAME (only [a-zA-Z0-9_-]+, ≤50 chars)"
  exit 1
fi

DST_DIR="$HOME/.claude/skills/$SKILL_NAME"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "[install-skill] cloning mcc-dev-tools (shallow)..."
if ! git clone --quiet --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMPDIR/repo" 2>&1 | tail -5; then
  echo "[install-skill] git clone failed — check network / repo access"
  exit 1
fi

SRC_DIR="$TMPDIR/repo/skills/$SKILL_NAME"
if [[ ! -d "$SRC_DIR" ]]; then
  echo "[install-skill] skill '$SKILL_NAME' not found in $REPO_URL/skills/"
  echo "[install-skill] available:"
  ls "$TMPDIR/repo/skills/" 2>/dev/null | sed 's/^/  /'
  exit 1
fi

if [[ ! -f "$SRC_DIR/SKILL.md" ]]; then
  echo "[install-skill] $SKILL_NAME missing SKILL.md — invalid skill structure"
  exit 1
fi

# Backup existing version если есть.
if [[ -d "$DST_DIR" ]]; then
  BACKUP="$DST_DIR.bak.$(date +%Y%m%d-%H%M%S)"
  echo "[install-skill] existing version found → backup to $(basename "$BACKUP")"
  mv "$DST_DIR" "$BACKUP"
fi

mkdir -p "$(dirname "$DST_DIR")"
cp -R "$SRC_DIR" "$DST_DIR"

echo "[install-skill] installed: $DST_DIR"
echo "[install-skill] files:"
find "$DST_DIR" -type f | sed "s|$DST_DIR/|  |"
echo ""
echo "[install-skill] done. Restart Claude Code (or open new session) to pick up the skill."
echo "[install-skill] usage in CC: just describe what you want — the skill activates by description."

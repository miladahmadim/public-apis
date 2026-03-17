#!/usr/bin/env bash
# sync-claude-config.sh
# Syncs global ~/.claude/CLAUDE.md into the project CLAUDE.md
# Preserves project-specific sections marked between tags
#
# Usage: ./scripts/sync-claude-config.sh
# Runs automatically via Claude Code session-start hook

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GLOBAL_CONFIG="$HOME/.claude/CLAUDE.md"
PROJECT_CONFIG="$PROJECT_ROOT/CLAUDE.md"
PROJECT_TEMPLATE="$PROJECT_ROOT/.claude/project-config.md"

# ── Check if global config exists ──
if [[ ! -f "$GLOBAL_CONFIG" ]]; then
    echo "[sync-claude-config] No global config found at $GLOBAL_CONFIG, skipping sync."
    exit 0
fi

# ── Read global config ──
GLOBAL_CONTENT=$(cat "$GLOBAL_CONFIG")

# ── Read project-specific template (if exists) ──
PROJECT_SPECIFIC=""
if [[ -f "$PROJECT_TEMPLATE" ]]; then
    PROJECT_SPECIFIC=$(cat "$PROJECT_TEMPLATE")
fi

# ── Generate synced CLAUDE.md ──
cat > "$PROJECT_CONFIG" << HEREDOC
<!-- AUTO-SYNCED from ~/.claude/CLAUDE.md — $(date '+%Y-%m-%d %H:%M') -->
<!-- Do not edit the GLOBAL section manually. Edit ~/.claude/CLAUDE.md instead. -->
<!-- Project-specific config: .claude/project-config.md -->

# Global Configuration

${GLOBAL_CONTENT}

---

# Project: public-apis

${PROJECT_SPECIFIC}
HEREDOC

echo "[sync-claude-config] Synced CLAUDE.md (global + project config)"

#!/bin/bash
# Quick launcher — downloads and runs the full setup script from GitHub
# Usage: curl -sL https://raw.githubusercontent.com/miladahmadim/public-apis/claude/ai-tools-setup-dashboard-C0Xvg/scripts/setup-mcp-tools.sh | bash
set -e
REPO="miladahmadim/public-apis"
BRANCH="claude/ai-tools-setup-dashboard-C0Xvg"
SCRIPT="scripts/setup-mcp-tools.sh"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/${SCRIPT}"
TMP=$(mktemp /tmp/setup-mcp-XXXXXX.sh)
echo "Downloading Ninja AI Tools setup script..."
curl -fsSL "$RAW_URL" -o "$TMP"
chmod +x "$TMP"
bash "$TMP"
rm -f "$TMP"

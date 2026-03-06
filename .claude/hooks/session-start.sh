#!/bin/bash
set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Install Node.js dependencies for the dashboard
cd "$CLAUDE_PROJECT_DIR/dashboard"
npm install

# Install Python dependencies for the scripts
cd "$CLAUDE_PROJECT_DIR/scripts"
pip install -r requirements.txt

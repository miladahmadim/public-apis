#!/bin/bash
# ============================================================
#  🥷 NINJA AI TOOLS — Claude Code MCP Setup Script
#  Interactieve installer voor alle AI tool integraties
# ============================================================

set -e

# Kleuren
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

INSTALLED=0
SKIPPED=0
FAILED=0

print_header() {
  clear
  echo -e "${PURPLE}"
  echo "  ╔══════════════════════════════════════════════════╗"
  echo "  ║   🥷 NINJA AI TOOLS — MCP Setup Script          ║"
  echo "  ║   Claude Code Integration Installer             ║"
  echo "  ╚══════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo ""
}

print_section() {
  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  $1"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

print_tool() {
  echo -e "  ${CYAN}$1${NC} $2"
  echo -e "  ${DIM}$3${NC}"
  echo ""
}

ask_key() {
  local prompt="$1"
  local var_name="$2"
  echo -e "  ${YELLOW}?${NC} ${prompt}"
  echo -e "  ${DIM}(druk Enter om over te slaan)${NC}"
  printf "  → "
  read -r value
  eval "$var_name=\"$value\""
  echo ""
}

ask_yes_no() {
  local prompt="$1"
  echo -e "  ${YELLOW}?${NC} ${prompt} ${DIM}[j/n]${NC}"
  printf "  → "
  read -r answer
  echo ""
  [[ "$answer" =~ ^[jJyY]$ ]]
}

success() {
  echo -e "  ${GREEN}✓${NC} $1"
  INSTALLED=$((INSTALLED + 1))
}

skip() {
  echo -e "  ${DIM}⊘ $1 — overgeslagen${NC}"
  SKIPPED=$((SKIPPED + 1))
}

fail() {
  echo -e "  ${RED}✗${NC} $1"
  FAILED=$((FAILED + 1))
}

# ============================================================
#  PREREQUISITES CHECK
# ============================================================

print_header

echo -e "  ${BOLD}Systeem check...${NC}"
echo ""

# Check Node.js
if command -v node &> /dev/null; then
  NODE_V=$(node --version)
  echo -e "  ${GREEN}✓${NC} Node.js ${NODE_V}"
else
  echo -e "  ${RED}✗${NC} Node.js niet gevonden"
  echo -e "  ${DIM}  Installeer via: brew install node${NC}"
  echo ""
  if ask_yes_no "Wil je doorgaan zonder Node.js?"; then
    echo -e "  ${YELLOW}⚠${NC}  Sommige tools werken mogelijk niet"
  else
    echo -e "  Installeer eerst Node.js en draai dit script opnieuw."
    exit 1
  fi
fi

# Check Python
if command -v python3 &> /dev/null; then
  PY_V=$(python3 --version)
  echo -e "  ${GREEN}✓${NC} ${PY_V}"
else
  echo -e "  ${RED}✗${NC} Python 3 niet gevonden"
  echo -e "  ${DIM}  Installeer via: brew install python${NC}"
fi

# Check uv
if command -v uv &> /dev/null; then
  echo -e "  ${GREEN}✓${NC} uv (Python package manager)"
else
  echo -e "  ${YELLOW}⊘${NC} uv niet gevonden"
  if ask_yes_no "Wil je uv nu installeren? (nodig voor ElevenLabs)"; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    echo -e "  ${GREEN}✓${NC} uv geïnstalleerd"
  fi
fi

# Check Claude Code
if command -v claude &> /dev/null; then
  echo -e "  ${GREEN}✓${NC} Claude Code CLI"
else
  echo -e "  ${YELLOW}⊘${NC} Claude Code CLI niet gevonden"
  if ask_yes_no "Wil je Claude Code nu installeren?"; then
    npm install -g @anthropic-ai/claude-code
    echo -e "  ${GREEN}✓${NC} Claude Code geïnstalleerd"
  else
    echo -e "  ${RED}✗${NC} Claude Code is vereist. Installeer met:"
    echo -e "      npm install -g @anthropic-ai/claude-code"
    exit 1
  fi
fi

echo ""
echo -e "  ${DIM}Druk op Enter om te beginnen met de setup...${NC}"
read -r

# ============================================================
#  TIER 1 — DIRECT KOPPELBAAR (GRATIS + MCP)
# ============================================================

print_header
print_section "🟢 TIER 1 — Direct Koppelbaar (Gratis + MCP)"

# --- ElevenLabs ---
print_tool "🎙️  ElevenLabs" "(Text-to-Speech, Voice cloning, Transcriptie)" "10.000 characters/maand gratis — elevenlabs.io"

if ask_yes_no "Wil je ElevenLabs configureren?"; then
  echo -e "  ${DIM}Stap 1: Maak gratis account op elevenlabs.io${NC}"
  echo -e "  ${DIM}Stap 2: Ga naar Settings → API Keys → Generate${NC}"
  echo -e "  ${DIM}Stap 3: Kopieer je API key${NC}"
  echo ""
  ask_key "Plak je ElevenLabs API key:" ELEVENLABS_KEY

  if [ -n "$ELEVENLABS_KEY" ]; then
    if claude mcp add-json "ElevenLabs" "{\"command\":\"uvx\",\"args\":[\"elevenlabs-mcp\"],\"env\":{\"ELEVENLABS_API_KEY\":\"$ELEVENLABS_KEY\"}}" 2>/dev/null; then
      success "ElevenLabs MCP geconfigureerd"
    else
      fail "ElevenLabs configuratie mislukt"
    fi
  else
    skip "ElevenLabs"
  fi
else
  skip "ElevenLabs"
fi

# --- Hugging Face ---
print_tool "🤗 Hugging Face" "(45K+ modellen, NLP, Image classification, Sentiment)" "Gratis Inference API — huggingface.co"

if ask_yes_no "Wil je Hugging Face configureren?"; then
  echo -e "  ${DIM}Stap 1: Maak gratis account op huggingface.co${NC}"
  echo -e "  ${DIM}Stap 2: Settings → Access Tokens → New token${NC}"
  echo -e "  ${DIM}Stap 3: Selecteer 'Make calls to Inference Providers'${NC}"
  echo ""
  ask_key "Plak je HuggingFace token (hf_...):" HF_TOKEN

  if [ -n "$HF_TOKEN" ]; then
    pip install huggingface-mcp-server 2>/dev/null || pip3 install huggingface-mcp-server 2>/dev/null
    if claude mcp add-json "huggingface" "{\"command\":\"python3\",\"args\":[\"-m\",\"huggingface_mcp_server\"],\"env\":{\"HF_TOKEN\":\"$HF_TOKEN\"}}" 2>/dev/null; then
      success "Hugging Face MCP geconfigureerd"
    else
      fail "Hugging Face configuratie mislukt"
    fi
  else
    skip "Hugging Face"
  fi
else
  skip "Hugging Face"
fi

# --- Replicate ---
print_tool "🔁 Replicate" "(FLUX image gen, Stable Diffusion, Video, 50K+ modellen)" "Gratis startcredits — replicate.com"

if ask_yes_no "Wil je Replicate configureren?"; then
  echo -e "  ${DIM}Stap 1: Maak account op replicate.com${NC}"
  echo -e "  ${DIM}Stap 2: Account → API Tokens${NC}"
  echo -e "  ${DIM}Stap 3: Kopieer token${NC}"
  echo ""
  ask_key "Plak je Replicate API token:" REPLICATE_KEY

  if [ -n "$REPLICATE_KEY" ]; then
    if claude mcp add-json "replicate" "{\"command\":\"npx\",\"args\":[\"-y\",\"@felores/kie-ai-mcp-server\"],\"env\":{\"KIE_AI_API_KEY\":\"$REPLICATE_KEY\"}}" 2>/dev/null; then
      success "Replicate MCP geconfigureerd"
    else
      fail "Replicate configuratie mislukt"
    fi
  else
    skip "Replicate"
  fi
else
  skip "Replicate"
fi

# --- Suno ---
print_tool "🎵 Suno (Music AI)" "(Muziekgeneratie, Lyrics, Instrumentaal)" "5 songs/dag gratis — suno.com"

if ask_yes_no "Wil je Suno configureren?"; then
  echo -e "  ${DIM}Gebruikt dezelfde kie-ai MCP server als Replicate${NC}"
  echo ""
  ask_key "Plak je Suno/kie-ai API key (of dezelfde Replicate key):" SUNO_KEY

  if [ -n "$SUNO_KEY" ]; then
    if claude mcp add-json "suno" "{\"command\":\"npx\",\"args\":[\"-y\",\"@felores/kie-ai-mcp-server\"],\"env\":{\"KIE_AI_API_KEY\":\"$SUNO_KEY\",\"KIE_AI_ENABLED_TOOLS\":\"suno_generate_music\"}}" 2>/dev/null; then
      success "Suno MCP geconfigureerd"
    else
      fail "Suno configuratie mislukt"
    fi
  else
    skip "Suno"
  fi
else
  skip "Suno"
fi

# ============================================================
#  TIER 2 — FREEMIUM + MCP KOPPELBAAR
# ============================================================

print_header
print_section "🟡 TIER 2 — Freemium + MCP Koppelbaar"

# --- Perplexity ---
print_tool "🔍 Perplexity" "(AI-powered search, Geciteerde antwoorden, Research)" "Gratis tier beschikbaar — perplexity.ai"

if ask_yes_no "Wil je Perplexity configureren?"; then
  echo -e "  ${DIM}Stap 1: Account op perplexity.ai → Settings → API${NC}"
  echo -e "  ${DIM}Stap 2: Genereer API key${NC}"
  echo ""
  ask_key "Plak je Perplexity API key (pplx_...):" PERPLEXITY_KEY

  if [ -n "$PERPLEXITY_KEY" ]; then
    if claude mcp add-json "perplexity" "{\"command\":\"npx\",\"args\":[\"-y\",\"perplexity-mcp\"],\"env\":{\"PERPLEXITY_API_KEY\":\"$PERPLEXITY_KEY\"}}" 2>/dev/null; then
      success "Perplexity MCP geconfigureerd"
    else
      fail "Perplexity configuratie mislukt"
    fi
  else
    skip "Perplexity"
  fi
else
  skip "Perplexity"
fi

# --- Zapier ---
print_tool "⚡ Zapier" "(8000+ app integraties, Webhooks, No-code automation)" "100 tasks/maand gratis — zapier.com"

if ask_yes_no "Wil je Zapier configureren?"; then
  echo -e "  ${DIM}Stap 1: Login op zapier.com → ga naar zapier.com/mcp${NC}"
  echo -e "  ${DIM}Stap 2: Klik 'Generate URL' → kopieer je MCP URL${NC}"
  echo ""
  ask_key "Plak je Zapier MCP URL:" ZAPIER_URL

  if [ -n "$ZAPIER_URL" ]; then
    if claude mcp add --transport http "zapier" "$ZAPIER_URL" 2>/dev/null; then
      success "Zapier MCP geconfigureerd"
    else
      fail "Zapier configuratie mislukt"
    fi
  else
    skip "Zapier"
  fi
else
  skip "Zapier"
fi

# --- DALL·E / OpenAI ---
print_tool "🖼️  DALL·E" "(Image generation, Image editing, Variations)" "\$0.04/image — platform.openai.com"

if ask_yes_no "Wil je DALL·E / OpenAI configureren?"; then
  echo -e "  ${DIM}Stap 1: Account op platform.openai.com${NC}"
  echo -e "  ${DIM}Stap 2: Maak API key aan${NC}"
  echo ""
  ask_key "Plak je OpenAI API key (sk-...):" OPENAI_KEY

  if [ -n "$OPENAI_KEY" ]; then
    if claude mcp add-json "openai" "{\"command\":\"npx\",\"args\":[\"-y\",\"openai-mcp-server\"],\"env\":{\"OPENAI_API_KEY\":\"$OPENAI_KEY\"}}" 2>/dev/null; then
      success "OpenAI/DALL·E MCP geconfigureerd"
    else
      fail "OpenAI configuratie mislukt"
    fi
  else
    skip "DALL·E"
  fi
else
  skip "DALL·E"
fi

# --- Stability AI ---
print_tool "✂️  Clipdrop / Stability AI" "(Background removal, Upscaling, Image editing)" "25 gratis credits — platform.stability.ai"

if ask_yes_no "Wil je Stability AI configureren?"; then
  echo -e "  ${DIM}Stap 1: Account op platform.stability.ai${NC}"
  echo -e "  ${DIM}Stap 2: Genereer API key${NC}"
  echo ""
  ask_key "Plak je Stability AI API key:" STABILITY_KEY

  if [ -n "$STABILITY_KEY" ]; then
    pip install stability-mcp-server 2>/dev/null || pip3 install stability-mcp-server 2>/dev/null
    if claude mcp add-json "stability" "{\"command\":\"python3\",\"args\":[\"-m\",\"stability_mcp\"],\"env\":{\"STABILITY_API_KEY\":\"$STABILITY_KEY\"}}" 2>/dev/null; then
      success "Stability AI MCP geconfigureerd"
    else
      fail "Stability AI configuratie mislukt"
    fi
  else
    skip "Stability AI"
  fi
else
  skip "Stability AI"
fi

# --- Playwright (Browser automation) ---
print_tool "🤖 Playwright" "(Browser automation, Web scraping, Testing)" "100% gratis, open-source"

if ask_yes_no "Wil je Playwright MCP configureren? (geen API key nodig)"; then
  if claude mcp add-json "playwright" "{\"command\":\"npx\",\"args\":[\"-y\",\"@anthropic/mcp-playwright\"]}" 2>/dev/null; then
    success "Playwright MCP geconfigureerd"
  else
    fail "Playwright configuratie mislukt"
  fi
else
  skip "Playwright"
fi

# ============================================================
#  TIER 3 — CREATIEVE OPLOSSINGEN
# ============================================================

print_header
print_section "🔴 TIER 3 — Creatieve Oplossingen"

# --- NotebookLM ---
print_tool "📓 NotebookLM" "(Research, Audio overviews, Samenvattingen)" "Gratis — via unofficial Python API"

if ask_yes_no "Wil je NotebookLM installeren?"; then
  echo -e "  ${DIM}Installeert notebooklm-py + Playwright browser...${NC}"
  if pip install "notebooklm-py[browser]" 2>/dev/null || pip3 install "notebooklm-py[browser]" 2>/dev/null; then
    playwright install chromium 2>/dev/null
    success "NotebookLM geïnstalleerd"
    echo -e "  ${DIM}  Draai 'notebooklm login' om in te loggen met Google${NC}"
    echo -e "  ${DIM}  Draai 'notebooklm skill install' voor Claude Code integratie${NC}"
  else
    fail "NotebookLM installatie mislukt"
  fi
else
  skip "NotebookLM"
fi

echo ""
echo -e "  ${DIM}Tier 3 tools zoals Gamma, Pi, Khroma, Descript en Warp${NC}"
echo -e "  ${DIM}worden al gedekt door Claude Code zelf (geen setup nodig).${NC}"

# ============================================================
#  VERIFICATIE & SAMENVATTING
# ============================================================

print_header
print_section "📋 Setup Samenvatting"

echo -e "  ${GREEN}✓ Geïnstalleerd:${NC}  ${BOLD}${INSTALLED}${NC} tools"
echo -e "  ${DIM}⊘ Overgeslagen:${NC}   ${BOLD}${SKIPPED}${NC} tools"
if [ "$FAILED" -gt 0 ]; then
  echo -e "  ${RED}✗ Mislukt:${NC}        ${BOLD}${FAILED}${NC} tools"
fi

echo ""
echo -e "  ${BOLD}Huidige MCP configuratie:${NC}"
echo ""
claude mcp list 2>/dev/null || echo -e "  ${DIM}(kon claude mcp list niet uitvoeren)${NC}"

echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}${BOLD}✅ Ninja AI Tools setup compleet!${NC}"
echo ""
echo -e "  ${DIM}Volgende stappen:${NC}"
echo -e "  ${CYAN}1.${NC} Start Claude Code:  ${BOLD}claude${NC}"
echo -e "  ${CYAN}2.${NC} Test een tool:      ${DIM}\"Genereer een voiceover met ElevenLabs\"${NC}"
echo -e "  ${CYAN}3.${NC} Bekijk MCP lijst:   ${BOLD}claude mcp list${NC}"
echo ""
echo -e "  ${DIM}Draai dit script opnieuw om meer tools toe te voegen.${NC}"
echo ""

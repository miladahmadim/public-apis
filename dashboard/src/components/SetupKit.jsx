import { useState } from "react";

const sections = [
  {
    id: "tier1",
    emoji: "\u{1F7E2}",
    title: "TIER 1 \u2014 Direct Koppelbaar (Gratis + MCP)",
    color: "#10b981",
    tools: [
      {
        name: "ElevenLabs",
        icon: "\u{1F399}\uFE0F",
        status: "Offici\u00EBle MCP server",
        free: "10.000 characters/maand gratis",
        powers: ["Text-to-Speech", "Voice cloning", "Transcriptie", "Sound effects"],
        setup: {
          step1: "Maak gratis account op elevenlabs.io",
          step2: "Ga naar Settings \u2192 API Keys \u2192 Generate",
          step3: "Kopieer je API key",
          command: `claude mcp add-json "ElevenLabs" '{"command":"uvx","args":["elevenlabs-mcp"],"env":{"ELEVENLABS_API_KEY":"JOUW_KEY_HIER"}}'`,
          prereq: "pip install uv (of: curl -LsSf https://astral.sh/uv/install.sh | sh)"
        },
        example: '"Genereer een voiceover voor mijn wine review video in het Nederlands"'
      },
      {
        name: "Hugging Face",
        icon: "\u{1F917}",
        status: "Custom MCP via Python wrapper",
        free: "Gratis Inference API (rate limited)",
        powers: ["45.000+ modellen", "NLP", "Image classification", "Embeddings", "Sentiment analysis"],
        setup: {
          step1: "Maak gratis account op huggingface.co",
          step2: "Ga naar Settings \u2192 Access Tokens \u2192 New token",
          step3: "Selecteer 'Make calls to Inference Providers'",
          command: `# Installeer eerst de HF MCP server
pip install huggingface-mcp-server

# Voeg toe aan Claude Code
claude mcp add-json "huggingface" '{"command":"python","args":["-m","huggingface_mcp_server"],"env":{"HF_TOKEN":"hf_JOUW_TOKEN_HIER"}}'`,
          prereq: "Python 3.10+, pip install huggingface-hub"
        },
        example: '"Analyseer het sentiment van deze wine reviews" of "Classificeer deze afbeelding"'
      },
      {
        name: "Replicate",
        icon: "\u{1F501}",
        status: "MCP via Zapier of custom wrapper",
        free: "Gratis startcredits, daarna ~$0.003/image",
        powers: ["FLUX image gen", "Stable Diffusion", "Video gen", "Audio", "50K+ modellen"],
        setup: {
          step1: "Maak account op replicate.com",
          step2: "Ga naar Account \u2192 API Tokens",
          step3: "Kopieer token",
          command: `# Optie A: Via npm MCP package (aanbevolen)
npm install -g @felores/kie-ai-mcp-server

claude mcp add-json "replicate" '{"command":"npx","args":["-y","@felores/kie-ai-mcp-server"],"env":{"KIE_AI_API_KEY":"JOUW_KEY"}}'

# Optie B: Direct via Python wrapper
pip install replicate
# Dan custom MCP server script (zie setup-script hieronder)`,
          prereq: "Node.js 18+ of Python 3.10+"
        },
        example: '"Genereer een professionele foto van een wijnglas bij zonsondergang met FLUX"'
      },
      {
        name: "Suno (Music AI)",
        icon: "\u{1F3B5}",
        status: "Community MCP server",
        free: "5 songs/dag gratis",
        powers: ["Muziekgeneratie", "Lyrics + melodie", "Instrumentaal", "Meerdere genres"],
        setup: {
          step1: "Maak account op suno.com",
          step2: "Verkrijg API key (via Suno API of kie-ai package)",
          step3: "Configureer MCP",
          command: `# Via kie-ai MCP (bevat Suno + meer)
claude mcp add-json "suno" '{"command":"npx","args":["-y","@felores/kie-ai-mcp-server"],"env":{"KIE_AI_API_KEY":"JOUW_KEY","KIE_AI_ENABLED_TOOLS":"suno_generate_music"}}'

# Of standalone Suno MCP:
git clone https://github.com/your-suno-mcp-repo
cd MCP-Suno && npm install && npm run build
claude mcp add-json "suno-mcp" '{"command":"node","args":["./MCP-Suno/build/index.js"]}'`,
          prereq: "Node.js 18+"
        },
        example: '"Maak een upbeat lofi track als achtergrondmuziek voor mijn wine tasting video"'
      },
      {
        name: "Stable Diffusion (via Replicate/HF)",
        icon: "\u{1F3A8}",
        status: "Beschikbaar via Replicate of HuggingFace MCP",
        free: "Open-source, gratis via HF Inference",
        powers: ["Image generation", "Img2Img", "Inpainting", "ControlNet"],
        setup: {
          step1: "Geen apart account nodig \u2014 gebruik via Replicate of HuggingFace",
          step2: "Wordt automatisch beschikbaar als je die MCP servers hebt geconfigureerd",
          step3: "\u2014",
          command: `# Al beschikbaar via Replicate MCP hierboven
# Of direct via HuggingFace:
# Model: stabilityai/stable-diffusion-xl-base-1.0`,
          prereq: "Replicate of HuggingFace MCP actief"
        },
        example: '"Genereer een Stable Diffusion afbeelding van een Spaanse villa met uitzicht op zee"'
      },
      {
        name: "Continue (IDE Assistant)",
        icon: "\u{1F4BB}",
        status: "VS Code / JetBrains extensie",
        free: "100% gratis, open-source",
        powers: ["Code completion", "Chat in IDE", "Werkt met Claude API", "Custom models"],
        setup: {
          step1: "Installeer Continue extensie in VS Code",
          step2: "Open Continue sidebar \u2192 Settings",
          step3: "Voeg Claude als model provider toe",
          command: `# In VS Code:
# 1. Extensions \u2192 Zoek "Continue" \u2192 Install
# 2. Open ~/.continue/config.json en voeg toe:
{
  "models": [{
    "title": "Claude Sonnet",
    "provider": "anthropic",
    "model": "claude-sonnet-4-5-20250929",
    "apiKey": "JOUW_ANTHROPIC_KEY"
  }]
}`,
          prereq: "VS Code, Anthropic API key"
        },
        example: "Werkt als AI pair programmer direct in je IDE voor Zaminor development"
      }
    ]
  },
  {
    id: "tier2",
    emoji: "\u{1F7E1}",
    title: "TIER 2 \u2014 Freemium + MCP Koppelbaar",
    color: "#f59e0b",
    tools: [
      {
        name: "Perplexity",
        icon: "\u{1F50D}",
        status: "MCP server beschikbaar",
        free: "Gratis tier, Pro voor meer requests",
        powers: ["AI-powered search", "Geciteerde antwoorden", "Research automation"],
        setup: {
          step1: "Account op perplexity.ai \u2192 Settings \u2192 API",
          step2: "Genereer API key",
          step3: "Voeg MCP toe",
          command: `claude mcp add-json "perplexity" '{"command":"npx","args":["-y","perplexity-mcp"],"env":{"PERPLEXITY_API_KEY":"pplx_JOUW_KEY"}}'`,
          prereq: "Node.js 18+"
        },
        example: '"Research de laatste trends in Spaanse vastgoedmarkt voor Zaminor"'
      },
      {
        name: "Zapier",
        icon: "\u26A1",
        status: "Offici\u00EBle MCP server",
        free: "100 tasks/maand gratis",
        powers: ["8000+ app integraties", "Webhooks", "No-code automation", "MCP endpoint"],
        setup: {
          step1: "Login op zapier.com \u2192 ga naar zapier.com/mcp",
          step2: "Klik 'Generate URL' \u2192 kopieer je MCP URL",
          step3: "Voeg toe aan Claude Code",
          command: `# Zapier MCP werkt als remote HTTP server
claude mcp add --transport http "zapier" "https://actions.zapier.com/mcp/JOUW_UNIEKE_URL/sse"

# Of in config:
claude mcp add-json "zapier" '{"type":"http","url":"https://actions.zapier.com/mcp/JOUW_URL/sse"}'`,
          prereq: "Zapier account (gratis)"
        },
        example: '"Stuur een email via Gmail en post het op Slack wanneer een nieuwe Zaminor lead binnenkomt"'
      },
      {
        name: "Make (Integromat)",
        icon: "\u{1F527}",
        status: "Via webhook + custom MCP",
        free: "1000 operaties/maand gratis",
        powers: ["Visuele automation", "Complex branching", "100+ integraties"],
        setup: {
          step1: "Account op make.com",
          step2: "Maak een scenario met Webhook trigger",
          step3: "Gebruik webhook URL als endpoint in custom MCP",
          command: `# Make heeft geen native MCP, maar je kunt het via webhooks koppelen:
# 1. Maak scenario in Make met "Custom Webhook" trigger
# 2. Gebruik de webhook URL in een custom fetch MCP:
claude mcp add-json "make-webhook" '{"command":"npx","args":["-y","@anthropic/mcp-fetch"]}'
# Claude kan dan fetch calls doen naar je Make webhooks`,
          prereq: "Make account, webhook URL"
        },
        example: '"Trigger mijn Make workflow om nieuwe KYC data door te sturen naar de database"'
      },
      {
        name: "Canva",
        icon: "\u{1F3A8}",
        status: "MCP via Zapier of Canva Dev MCP",
        free: "Freemium (basis gratis)",
        powers: ["Design creatie", "Template autofill", "Asset upload", "Export"],
        setup: {
          step1: "Optie A: Via Zapier MCP (makkelijkst)",
          step2: "Optie B: Canva Dev MCP voor development",
          step3: "Koppel Canva account in Zapier",
          command: `# Via Zapier MCP (als je Zapier al hebt):
# Ga naar zapier.com/mcp \u2192 Enable Canva actions
# Dit werkt via dezelfde Zapier MCP URL

# Of Canva Dev MCP (voor developers):
npx @anthropic/create-mcp@latest --from @anthropic/mcp-canva`,
          prereq: "Zapier account of Canva Developer account"
        },
        example: '"Maak een Instagram post design voor mijn wijn review van deze week"'
      },
      {
        name: "DALL\u00B7E",
        icon: "\u{1F5BC}\uFE0F",
        status: "Via OpenAI API",
        free: "$0.04/image (niet gratis maar goedkoop)",
        powers: ["Image generation", "Image editing", "Variations"],
        setup: {
          step1: "Account op platform.openai.com",
          step2: "Maak API key aan",
          step3: "Gebruik via fetch MCP of custom wrapper",
          command: `# Via een OpenAI MCP server:
npm install -g openai-mcp-server
claude mcp add-json "openai" '{"command":"npx","args":["-y","openai-mcp-server"],"env":{"OPENAI_API_KEY":"sk-JOUW_KEY"}}'`,
          prereq: "OpenAI account + API credits"
        },
        example: '"Genereer een professionele header afbeelding voor de Zaminor landing page"'
      },
      {
        name: "Clipdrop / Stability AI",
        icon: "\u2702\uFE0F",
        status: "Via Stability AI API",
        free: "25 gratis credits",
        powers: ["Background removal", "Upscaling", "Cleanup", "Image editing"],
        setup: {
          step1: "Account op platform.stability.ai",
          step2: "Genereer API key",
          step3: "Gebruik via custom MCP of direct API calls",
          command: `# Via Stability AI MCP:
pip install stability-mcp-server
claude mcp add-json "stability" '{"command":"python","args":["-m","stability_mcp"],"env":{"STABILITY_API_KEY":"JOUW_KEY"}}'`,
          prereq: "Stability AI account"
        },
        example: '"Verwijder de achtergrond van deze productfoto en schaal op naar 4K"'
      },
      {
        name: "Play.ht",
        icon: "\u{1F50A}",
        status: "Via API wrapper",
        free: "Freemium tier",
        powers: ["Text-to-speech", "Realistische stemmen", "Meerdere talen"],
        setup: {
          step1: "Account op play.ht \u2192 API tab",
          step2: "Kopieer User ID + API key",
          step3: "Custom MCP wrapper",
          command: `# Play.ht heeft geen native MCP, gebruik als backup voor ElevenLabs
# Via custom Python wrapper of direct API calls via fetch MCP`,
          prereq: "Play.ht account"
        },
        example: "Backup voor ElevenLabs als je maandelijks limiet bereikt"
      },
      {
        name: "Bardeen",
        icon: "\u{1F916}",
        status: "Browser extensie + automations",
        free: "Freemium",
        powers: ["Web scraping", "Browser automation", "Data extraction"],
        setup: {
          step1: "Installeer Bardeen Chrome extensie",
          step2: "Maak automations (playbooks)",
          step3: "Trigger via API/webhooks",
          command: `# Bardeen werkt als browser extensie, niet direct via MCP
# Maar je kunt het koppelen via:
# 1. Bardeen webhooks \u2192 Make/Zapier \u2192 Claude
# 2. Of gebruik Playwright MCP voor vergelijkbare functionaliteit:
claude mcp add-json "playwright" '{"command":"npx","args":["-y","@anthropic/mcp-playwright"]}'`,
          prereq: "Chrome browser"
        },
        example: '"Scrape concurrentie-prijzen van Spaanse vastgoedwebsites"'
      }
    ]
  },
  {
    id: "tier3",
    emoji: "\u{1F534}",
    title: "TIER 3 \u2014 Creatieve Oplossingen (Geen API)",
    color: "#ef4444",
    tools: [
      {
        name: "NotebookLM",
        icon: "\u{1F4D3}",
        status: "\u{1F527} OPLOSSING: Unofficial Python API",
        free: "Gratis",
        powers: ["Research grounded in bronnen", "Audio overviews", "Samenvattingen"],
        setup: {
          step1: "Installeer de unofficial NotebookLM Python client",
          step2: "Login via browser (eenmalig)",
          step3: "Gebruik via CLI of als MCP wrapper",
          command: `# Unofficial maar werkend:
pip install "notebooklm-py[browser]"
playwright install chromium

# Eerste keer: login via browser
notebooklm login

# Gebruik:
notebooklm create "Zaminor Research"
notebooklm source add "https://jouw-url.com"
notebooklm ask "Wat zijn de kernpunten?"
notebooklm generate audio "maak het engaging"

# MCP integratie: notebooklm-py heeft ingebouwde Claude Code skills!
notebooklm skill install`,
          prereq: "Python 3.10+, Playwright, Google account"
        },
        example: '"Upload al mijn Zaminor research docs en genereer een podcast-style audio briefing"'
      },
      {
        name: "Gamma (Presentations)",
        icon: "\u{1F4CA}",
        status: "\u{1F527} OPLOSSING: Alternatief via Python-pptx",
        free: "\u2014",
        powers: ["AI slide decks", "Presentaties"],
        setup: {
          step1: "Gamma heeft geen API, maar Claude Code kan zelf presentaties maken!",
          step2: "Gebruik python-pptx skill die al in Claude Code zit",
          step3: "Of gebruik Canva MCP voor presentaties",
          command: `# Claude Code heeft al een ingebouwde PPTX skill!
# Vraag gewoon: "Maak een presentatie over X"
# Claude gebruikt python-pptx om professionele slides te maken

# Alternatief via Canva:
# Gebruik Canva MCP om templates te vullen met content`,
          prereq: "Geen extra setup nodig \u2014 al ingebouwd in Claude Code"
        },
        example: '"Maak een investor deck voor Zaminor met 12 slides"'
      },
      {
        name: "Pi (Personal AI)",
        icon: "\u{1F4AC}",
        status: "\u{1F527} OPLOSSING: Niet nodig \u2014 Claude doet dit beter",
        free: "\u2014",
        powers: ["Conversatie", "Reflectie"],
        setup: {
          step1: "Pi's functionaliteit wordt volledig gedekt door Claude",
          step2: "Claude Code + Memory = betere personal AI",
          step3: "Geen actie nodig",
          command: `# Niet nodig \u2014 je hebt Claude al!
# Claude's memory system onthoudt context over gesprekken
# Claude Code kan reflectieve gesprekken voeren met meer diepgang`,
          prereq: "\u2014"
        },
        example: "Je gebruikt het nu al \u{1F60A}"
      },
      {
        name: "Khroma (Color Design)",
        icon: "\u{1F3A8}",
        status: "\u{1F527} OPLOSSING: Claude kan kleuren genereren",
        free: "\u2014",
        powers: ["AI kleurpaletten"],
        setup: {
          step1: "Claude kan zelf kleurpaletten genereren op basis van mood/brand",
          step2: "Of gebruik Coolors API (gratis) als externe bron",
          step3: "Integreer via fetch MCP",
          command: `# Claude kan dit native \u2014 vraag gewoon:
# "Genereer een kleurpalet voor een luxe wijnmerk"

# Of via Coolors API:
# https://coolors.co/palettes/trending
# Fetch via de ingebouwde web fetch tool`,
          prereq: "Geen extra setup"
        },
        example: '"Genereer een warm, luxe kleurpalet voor mijn wine brand met hex codes"'
      },
      {
        name: "Descript (Audio/Video)",
        icon: "\u{1F3AC}",
        status: "\u{1F527} OPLOSSING: FFmpeg + ElevenLabs MCP",
        free: "\u2014",
        powers: ["Audio/video editing via text"],
        setup: {
          step1: "Descript's kernfeature (text-based editing) kan met FFmpeg + transcriptie",
          step2: "Gebruik ElevenLabs MCP voor TTS/transcriptie",
          step3: "FFmpeg voor video manipulatie",
          command: `# Combinatie van tools vervangt Descript:
# 1. Transcriptie: ElevenLabs MCP (al geconfigureerd)
# 2. Audio editing: FFmpeg (al beschikbaar in Claude Code)
# 3. Video editing: FFmpeg commandos via Claude Code

# Voorbeeld workflow:
# Claude transcribeert audio \u2192 bewerkt transcript \u2192
# genereert nieuwe audio via ElevenLabs \u2192
# samenvoegen met FFmpeg`,
          prereq: "ElevenLabs MCP + FFmpeg (vaak al ge\u00EFnstalleerd)"
        },
        example: '"Transcribeer mijn wine tasting video, edit de tekst, en genereer een nieuwe voiceover"'
      },
      {
        name: "Warp (AI Terminal)",
        icon: "\u2328\uFE0F",
        status: "\u{1F527} OPLOSSING: Claude Code IS je AI terminal",
        free: "\u2014",
        powers: ["AI-powered terminal"],
        setup: {
          step1: "Claude Code is al een AI-powered terminal!",
          step2: "Het doet alles wat Warp doet, en meer",
          step3: "Geen actie nodig",
          command: `# Claude Code = AI terminal met superpowers
# Je hebt Warp niet nodig als je Claude Code hebt
# Claude Code kan: bash commands uitvoeren, code schrijven,
# files bewerken, git operaties doen, en meer`,
          prereq: "\u2014"
        },
        example: "Je gebruikt het straks al via Claude Code!"
      }
    ]
  }
];

export default function SetupKit() {
  const [activeSection, setActiveSection] = useState("tier1");
  const [expandedTool, setExpandedTool] = useState(null);
  const [copiedCommand, setCopiedCommand] = useState(null);
  const [completedTools, setCompletedTools] = useState(new Set());

  const copyToClipboard = (text, name) => {
    navigator.clipboard?.writeText(text);
    setCopiedCommand(name);
    setTimeout(() => setCopiedCommand(null), 2000);
  };

  const toggleCompleted = (name) => {
    const next = new Set(completedTools);
    if (next.has(name)) next.delete(name);
    else next.add(name);
    setCompletedTools(next);
  };

  const activeData = sections.find(s => s.id === activeSection);

  return (
    <div style={{
      minHeight: "100vh",
      background: "linear-gradient(145deg, #0a0a0f 0%, #0d1117 50%, #0a0f1a 100%)",
      color: "#e2e8f0",
      fontFamily: "'JetBrains Mono', 'Fira Code', 'SF Mono', monospace",
      padding: "20px",
      maxWidth: "900px",
      margin: "0 auto"
    }}>
      {/* Header */}
      <div style={{ marginBottom: "32px", borderBottom: "1px solid #1e293b", paddingBottom: "20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "8px" }}>
          <span style={{ fontSize: "28px" }}>{"\u{1F977}"}</span>
          <h1 style={{
            fontSize: "24px",
            fontWeight: 800,
            background: "linear-gradient(135deg, #60a5fa, #a78bfa, #f472b6)",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
            margin: 0
          }}>
            Claude Code MCP Setup Kit
          </h1>
        </div>
        <p style={{ color: "#64748b", fontSize: "13px", margin: 0 }}>
          Alle Ninja AI Tools gekoppeld aan Claude Code {"\u2022"} Kopieer commands {"\u2192"} plak in terminal {"\u2192"} klaar
        </p>
        <div style={{
          marginTop: "12px",
          padding: "10px 14px",
          background: "#1a1a2e",
          borderRadius: "8px",
          border: "1px solid #2d2d5e",
          fontSize: "12px",
          color: "#94a3b8"
        }}>
          <strong style={{ color: "#f59e0b" }}>{"\u26A1"} Quick start:</strong> Zorg dat je hebt: Node.js 18+, Python 3.10+,
          uv (<code style={{ color: "#60a5fa" }}>curl -LsSf https://astral.sh/uv/install.sh | sh</code>),
          en Claude Code (<code style={{ color: "#60a5fa" }}>npm install -g @anthropic-ai/claude-code</code>)
        </div>
      </div>

      {/* Progress bar */}
      <div style={{ marginBottom: "24px" }}>
        <div style={{ display: "flex", justifyContent: "space-between", fontSize: "12px", marginBottom: "6px" }}>
          <span style={{ color: "#64748b" }}>Voortgang</span>
          <span style={{ color: "#60a5fa" }}>
            {completedTools.size} / {sections.reduce((a, s) => a + s.tools.length, 0)} tools geconfigureerd
          </span>
        </div>
        <div style={{ height: "4px", background: "#1e293b", borderRadius: "2px", overflow: "hidden" }}>
          <div style={{
            height: "100%",
            width: `${(completedTools.size / sections.reduce((a, s) => a + s.tools.length, 0)) * 100}%`,
            background: "linear-gradient(90deg, #10b981, #60a5fa, #a78bfa)",
            borderRadius: "2px",
            transition: "width 0.5s ease"
          }} />
        </div>
      </div>

      {/* Tier tabs */}
      <div style={{ display: "flex", gap: "8px", marginBottom: "24px" }}>
        {sections.map(s => (
          <button
            key={s.id}
            onClick={() => { setActiveSection(s.id); setExpandedTool(null); }}
            style={{
              flex: 1,
              padding: "10px 8px",
              background: activeSection === s.id ? `${s.color}15` : "#111827",
              border: `1px solid ${activeSection === s.id ? s.color : "#1e293b"}`,
              borderRadius: "8px",
              color: activeSection === s.id ? s.color : "#64748b",
              cursor: "pointer",
              fontSize: "12px",
              fontWeight: 600,
              fontFamily: "inherit",
              transition: "all 0.2s"
            }}
          >
            <span style={{ fontSize: "16px", display: "block" }}>{s.emoji}</span>
            <span style={{ display: "block", marginTop: "4px" }}>
              {s.id === "tier1" ? "Direct" : s.id === "tier2" ? "Freemium" : "Creatief"}
            </span>
            <span style={{ fontSize: "10px", opacity: 0.7 }}>{s.tools.length} tools</span>
          </button>
        ))}
      </div>

      {/* Section header */}
      <div style={{
        padding: "12px 16px",
        background: `${activeData.color}08`,
        border: `1px solid ${activeData.color}30`,
        borderRadius: "8px",
        marginBottom: "16px",
        fontSize: "14px",
        fontWeight: 700,
        color: activeData.color
      }}>
        {activeData.emoji} {activeData.title}
      </div>

      {/* Tool cards */}
      <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
        {activeData.tools.map(tool => {
          const isExpanded = expandedTool === tool.name;
          const isCompleted = completedTools.has(tool.name);

          return (
            <div
              key={tool.name}
              style={{
                background: isExpanded ? "#111827" : "#0d1117",
                border: `1px solid ${isCompleted ? "#10b981" : isExpanded ? "#334155" : "#1e293b"}`,
                borderRadius: "10px",
                overflow: "hidden",
                transition: "all 0.2s"
              }}
            >
              {/* Tool header */}
              <div
                onClick={() => setExpandedTool(isExpanded ? null : tool.name)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  padding: "14px 16px",
                  cursor: "pointer",
                  gap: "12px"
                }}
              >
                <input
                  type="checkbox"
                  checked={isCompleted}
                  onChange={(e) => { e.stopPropagation(); toggleCompleted(tool.name); }}
                  onClick={(e) => e.stopPropagation()}
                  style={{ width: "16px", height: "16px", accentColor: "#10b981", cursor: "pointer" }}
                />
                <span style={{ fontSize: "20px" }}>{tool.icon}</span>
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: 700, fontSize: "14px", color: "#f1f5f9" }}>
                    {tool.name}
                    {isCompleted && <span style={{ marginLeft: "8px", color: "#10b981", fontSize: "12px" }}>{"\u2713"} geconfigureerd</span>}
                  </div>
                  <div style={{ fontSize: "11px", color: "#64748b", marginTop: "2px" }}>{tool.status}</div>
                </div>
                <div style={{
                  fontSize: "10px",
                  padding: "3px 8px",
                  background: "#1e293b",
                  borderRadius: "12px",
                  color: "#94a3b8"
                }}>
                  {tool.free}
                </div>
                <span style={{ color: "#475569", fontSize: "12px" }}>{isExpanded ? "\u25B2" : "\u25BC"}</span>
              </div>

              {/* Expanded content */}
              {isExpanded && (
                <div style={{
                  padding: "0 16px 16px",
                  borderTop: "1px solid #1e293b"
                }}>
                  {/* Powers */}
                  <div style={{ display: "flex", flexWrap: "wrap", gap: "4px", marginTop: "12px" }}>
                    {tool.powers.map(p => (
                      <span key={p} style={{
                        fontSize: "10px",
                        padding: "2px 8px",
                        background: `${activeData.color}15`,
                        color: activeData.color,
                        borderRadius: "10px",
                        border: `1px solid ${activeData.color}30`
                      }}>{p}</span>
                    ))}
                  </div>

                  {/* Setup steps */}
                  <div style={{ marginTop: "16px" }}>
                    <div style={{ fontSize: "12px", fontWeight: 700, color: "#94a3b8", marginBottom: "8px" }}>
                      SETUP STAPPEN:
                    </div>
                    {[tool.setup.step1, tool.setup.step2, tool.setup.step3].filter(s => s !== "\u2014").map((step, i) => (
                      <div key={i} style={{
                        display: "flex",
                        gap: "8px",
                        fontSize: "12px",
                        marginBottom: "6px",
                        color: "#cbd5e1"
                      }}>
                        <span style={{
                          width: "18px",
                          height: "18px",
                          borderRadius: "50%",
                          background: `${activeData.color}20`,
                          color: activeData.color,
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          fontSize: "10px",
                          fontWeight: 700,
                          flexShrink: 0
                        }}>{i + 1}</span>
                        {step}
                      </div>
                    ))}
                  </div>

                  {/* Prereqs */}
                  {tool.setup.prereq && tool.setup.prereq !== "\u2014" && (
                    <div style={{
                      marginTop: "10px",
                      padding: "6px 10px",
                      background: "#1a1a2e",
                      borderRadius: "6px",
                      fontSize: "11px",
                      color: "#a78bfa"
                    }}>
                      {"\u{1F4E6}"} Vereist: {tool.setup.prereq}
                    </div>
                  )}

                  {/* Command */}
                  <div style={{ marginTop: "12px", position: "relative" }}>
                    <div style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                      marginBottom: "4px"
                    }}>
                      <span style={{ fontSize: "11px", color: "#64748b" }}>Terminal command:</span>
                      <button
                        onClick={() => copyToClipboard(tool.setup.command, tool.name)}
                        style={{
                          fontSize: "11px",
                          padding: "3px 10px",
                          background: copiedCommand === tool.name ? "#10b981" : "#1e293b",
                          color: copiedCommand === tool.name ? "#fff" : "#94a3b8",
                          border: "none",
                          borderRadius: "4px",
                          cursor: "pointer",
                          fontFamily: "inherit",
                          transition: "all 0.2s"
                        }}
                      >
                        {copiedCommand === tool.name ? "\u2713 Gekopieerd!" : "\u{1F4CB} Kopieer"}
                      </button>
                    </div>
                    <pre style={{
                      background: "#000",
                      padding: "12px",
                      borderRadius: "8px",
                      fontSize: "11px",
                      lineHeight: 1.6,
                      overflow: "auto",
                      border: "1px solid #1e293b",
                      color: "#a5f3fc",
                      margin: 0
                    }}>
                      {tool.setup.command}
                    </pre>
                  </div>

                  {/* Example */}
                  <div style={{
                    marginTop: "12px",
                    padding: "8px 12px",
                    background: "#0f172a",
                    borderRadius: "6px",
                    borderLeft: `3px solid ${activeData.color}`,
                    fontSize: "12px"
                  }}>
                    <span style={{ color: "#64748b" }}>{"\u{1F4A1}"} Voorbeeld prompt: </span>
                    <span style={{ color: "#e2e8f0", fontStyle: "italic" }}>{tool.example}</span>
                  </div>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Quick install all script */}
      <div style={{
        marginTop: "32px",
        padding: "20px",
        background: "#0f172a",
        border: "1px solid #1e40af",
        borderRadius: "12px"
      }}>
        <h3 style={{
          margin: "0 0 12px",
          fontSize: "16px",
          color: "#60a5fa",
          display: "flex",
          alignItems: "center",
          gap: "8px"
        }}>
          {"\u26A1"} One-Click Install Script
        </h3>
        <p style={{ fontSize: "12px", color: "#64748b", marginBottom: "12px" }}>
          Vul eerst je API keys in, dan installeert dit alles in {"\u00E9\u00E9"}n keer:
        </p>
        <div style={{ position: "relative" }}>
          <button
            onClick={() => copyToClipboard(`#!/bin/bash
# === NINJA AI TOOLS - Claude Code MCP Setup ===
# Vul je API keys in hieronder:

export ELEVENLABS_KEY="jouw_key"
export HF_TOKEN="hf_jouw_token"
export REPLICATE_KEY="jouw_key"
export PERPLEXITY_KEY="pplx_jouw_key"
export ZAPIER_MCP_URL="jouw_zapier_mcp_url"

# --- Prerequisites ---
curl -LsSf https://astral.sh/uv/install.sh | sh
npm install -g @anthropic-ai/claude-code

# --- TIER 1: Direct koppelbaar ---
# ElevenLabs (officieel)
claude mcp add-json "ElevenLabs" "{\\"command\\":\\"uvx\\",\\"args\\":[\\"elevenlabs-mcp\\"],\\"env\\":{\\"ELEVENLABS_API_KEY\\":\\"$ELEVENLABS_KEY\\"}}"

# Replicate + Suno (via kie-ai)
claude mcp add-json "kie-ai" "{\\"command\\":\\"npx\\",\\"args\\":[\\"-y\\",\\"@felores/kie-ai-mcp-server\\"],\\"env\\":{\\"KIE_AI_API_KEY\\":\\"$REPLICATE_KEY\\"}}"

# --- TIER 2: Freemium ---
# Perplexity
claude mcp add-json "perplexity" "{\\"command\\":\\"npx\\",\\"args\\":[\\"-y\\",\\"perplexity-mcp\\"],\\"env\\":{\\"PERPLEXITY_API_KEY\\":\\"$PERPLEXITY_KEY\\"}}"

# Zapier (remote MCP)
claude mcp add --transport http "zapier" "$ZAPIER_MCP_URL"

# --- Verify ---
claude mcp list

echo "\u2705 Ninja AI Tools setup compleet!"`, "install-all")}
            style={{
              position: "absolute",
              top: "8px",
              right: "8px",
              fontSize: "11px",
              padding: "4px 12px",
              background: copiedCommand === "install-all" ? "#10b981" : "#1e40af",
              color: "#fff",
              border: "none",
              borderRadius: "4px",
              cursor: "pointer",
              fontFamily: "inherit",
              zIndex: 1
            }}
          >
            {copiedCommand === "install-all" ? "\u2713 Gekopieerd!" : "\u{1F4CB} Kopieer script"}
          </button>
          <pre style={{
            background: "#000",
            padding: "14px",
            borderRadius: "8px",
            fontSize: "11px",
            lineHeight: 1.5,
            overflow: "auto",
            color: "#86efac",
            border: "1px solid #1e293b",
            maxHeight: "200px"
          }}>
{`#!/bin/bash
# === NINJA AI TOOLS - Claude Code MCP Setup ===
# Vul je API keys in hieronder:

export ELEVENLABS_KEY="jouw_key"
export HF_TOKEN="hf_jouw_token"
export REPLICATE_KEY="jouw_key"
export PERPLEXITY_KEY="pplx_jouw_key"
export ZAPIER_MCP_URL="jouw_zapier_mcp_url"

# --- TIER 1: Direct koppelbaar ---
claude mcp add-json "ElevenLabs" ...
claude mcp add-json "kie-ai" ...

# --- TIER 2: Freemium ---
claude mcp add-json "perplexity" ...
claude mcp add --transport http "zapier" ...

# --- Verify ---
claude mcp list`}
          </pre>
        </div>
      </div>

      {/* Footer */}
      <div style={{
        marginTop: "24px",
        padding: "14px",
        background: "#111827",
        borderRadius: "8px",
        fontSize: "11px",
        color: "#64748b",
        textAlign: "center"
      }}>
        Gebouwd voor MM {"\u2022"} {sections.reduce((a, s) => a + s.tools.length, 0)} tools {"\u2022"}
        Alle MCP configs klaar voor Claude Code {"\u2022"}
        {"\u{1F7E2}"} {sections[0].tools.length} direct {"\u2022"}
        {"\u{1F7E1}"} {sections[1].tools.length} freemium {"\u2022"}
        {"\u{1F534}"} {sections[2].tools.length} creatief opgelost
      </div>
    </div>
  );
}

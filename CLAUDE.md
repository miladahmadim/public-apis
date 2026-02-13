# CLAUDE.md

## CRITICAL RULES

### Security (NEVER VIOLATE)

NEVER hardcode secrets in code. API keys, tokens, passwords -> always `process.env` or `os.environ.get()`.

If you accidentally commit a secret:

1. STOP immediately
2. Revoke the key
3. Generate new key
4. The old key is compromised forever (git history)

### Component Review (MANDATORY)

ALWAYS use component-reviewer agent before committing component changes:

> Use the component-reviewer agent to review [component-path]

Component reviewer validates: YAML frontmatter, kebab-case naming, no secrets, relative paths, clear descriptions, security.

### Deployment Safety

ALWAYS test API endpoints before production deploy:

```bash
cd api && npm test    # Must pass
vercel --prod         # Only after tests pass
```

Breaking the download tracking API breaks the entire CLI installation flow.

## Project Context

Node.js CLI tool managing 900+ Claude Code components (agents, commands, MCPs, hooks, settings, templates). Static website at aitmpl.com. Vercel APIs for download tracking and Discord integration.

**Tech Stack:** Node.js, Vercel Serverless, Supabase (analytics), Neon (monitoring), Cloudflare Workers (monitoring/KPI)

## Essential Commands

```bash
# Development
npm install                                      # Setup
npm test                                         # Required before commit
python scripts/generate_components_json.py       # Update catalog after component changes

# Publishing
npm view claude-code-templates version           # Check registry version first
npm version patch|minor|major                    # Bump (must be > registry)
npm publish                                      # Requires granular token

# Deployment
cd api && npm test                               # Test APIs first
vercel --prod                                    # Deploy (monitor with vercel logs aitmpl.com --follow)

# Emergency
vercel ls                                        # List deployments
vercel promote <deployment-url>                  # Rollback
```

## Component Development Workflow

1. **Create:** `cli-tool/components/{type}/{category}/{kebab-case-name}.md`
2. **Review:** Use component-reviewer agent (MANDATORY)
3. **Fix:** Address all Critical issues, consider Warnings
4. **Catalog:** Run `python scripts/generate_components_json.py`
5. **Test:** Run `npm test`
6. **Commit:** Only after all checks pass

Component types: agents, commands, mcps, hooks, settings, templates

## Code Standards

### Naming

- Files: `kebab-case.js` (utilities), `PascalCase.js` (classes)
- Functions/Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Components: `hyphenated-names` (enforced by component-reviewer)

### Paths

- ALWAYS relative: `.claude/scripts/`, `.claude/hooks/`
- NEVER absolute: `~/`, `/Users/`, `/home/`
- Use `path.join()` for cross-platform compatibility

### Error Handling

- Try/catch for all async operations
- Helpful error messages with context
- Implement graceful fallbacks

### Environment Variables

```javascript
// Load with dotenv
require('dotenv').config();
const API_KEY = process.env.GOOGLE_API_KEY;

// Add to .env.example with placeholder
// GOOGLE_API_KEY=your_key_here

// Verify .env in .gitignore (already is)
```

## Publishing Workflow (npm)

**Critical:** Classic tokens revoked Dec 2025. Use granular access tokens only.

```bash
# 1. Get granular token from npmjs.com/settings/~/tokens
#    Permissions: Read + Write for claude-code-templates
#    Enable: "Bypass 2FA"

# 2. Check current registry version
npm view claude-code-templates version

# 3. Update package.json to be one patch above registry

# 4. Test
npm test

# 5. Commit version bump
git add package.json && git commit -m "chore: Bump to X.Y.Z"
git push origin main

# 6. Publish (one-time token)
npm config set //registry.npmjs.org/:_authToken=YOUR_TOKEN
npm publish
npm config delete //registry.npmjs.org/:_authToken  # ALWAYS clean up

# 7. Tag release
git tag vX.Y.Z && git push origin vX.Y.Z

# 8. Deploy website
vercel --prod
```

## API Architecture

**CRITICAL:** `/api/track-download-supabase` is called on every CLI installation. Breaking it breaks the entire product.

### Key Endpoints

- `/api/track-download-supabase` - Download analytics (Supabase)
- `/api/discord/interactions` - Discord bot commands
- `/api/claude-code-check` - Release monitoring (Vercel Cron every 30 min)

### Required Environment Variables (Vercel)

See Vercel dashboard -> Settings -> Environment Variables. Never hardcode these.

**Required:** `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `NEON_DATABASE_URL`, `DISCORD_BOT_TOKEN`, `DISCORD_PUBLIC_KEY`, `DISCORD_WEBHOOK_URL_CHANGELOG`

## Cloudflare Workers

Two independent workers in `cloudflare-workers/`:

- **docs-monitor:** Hourly monitoring of code.claude.com/docs changes -> Telegram
- **pulse:** Sunday 14:00 UTC KPI report (GitHub, Discord, Supabase, Vercel, GA) -> Telegram

```bash
cd cloudflare-workers/{worker-name}
npm run dev                # Local testing
npx wrangler deploy        # Deploy
```

## Website (docs/)

Static site at aitmpl.com. Vanilla JS, no framework.

**Data flow:**

1. Python script scans `cli-tool/components/`
2. Generates `docs/components.json` (~2MB)
3. Website loads JSON, renders cards
4. Download clicks hit `/api/track-download-supabase`

**Blog creation:**

```bash
/create-blog-article @cli-tool/components/{type}/{category}/{name}.json
```

Auto-generates: AI cover image, SEO-optimized HTML, updates `docs/blog/blog-articles.json`

## Testing

```bash
npm test                    # All tests (required before commit/deploy)
npm run test:watch         # Watch mode
npm run test:coverage      # Aim for 70%+
cd api && npm test         # API tests (CRITICAL before vercel --prod)
```

## Common Issues & Solutions

**Components not showing on website:**
- Run `python scripts/generate_components_json.py`
- Clear browser cache
- Verify `docs/components.json` size (~2MB)

**API 404 after deploy:**
- Functions must be in `/api/` directory
- Format: `/api/function-name.js` or `/api/folder/index.js`

**Download tracking broken:**
- `vercel logs aitmpl.com --follow`
- Verify env vars in Vercel dashboard
- Test endpoint: `curl -X POST https://aitmpl.com/api/track-download-supabase -d '{"component_name":"test"}'`

**npm publish fails:**
- Ensure granular token (not classic)
- Token needs "Bypass 2FA" enabled
- Check `npm view claude-code-templates version` matches expectations

## Progressive Disclosure

For detailed information, reference these files:

- **Architecture:** See `README.md`
- **Component specs:** See `cli-tool/components/README.md`
- **API details:** See `api/README.md`
- **Cloudflare setup:** See `cloudflare-workers/{worker}/README.md`
- **Troubleshooting:** See `TROUBLESHOOTING.md` (if exists)

When in doubt about implementation details, read the actual code files using `@` syntax rather than asking for explanations.

> **Remember:** This file is for context Claude can't infer from code. When Claude already does something correctly without instruction, that instruction can be removed.

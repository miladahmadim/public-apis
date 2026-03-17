<!-- AUTO-SYNCED: 2026-03-17 12:52 -->
<!-- Global: ~/.claude/CLAUDE.md | Project: .claude/project-config.md -->

# Milad's Global Rules

## Code Style
- Schrijf altijd in TypeScript waar mogelijk
- Gebruik Nederlandse comments
- Test alles voor je commit

## Favoriete Tools
- Scrapling voor web scraping
- Context7 voor actuele docs

---

<!-- Project-specific Claude configuration for public-apis -->
<!-- This file is merged with your global ~/.claude/CLAUDE.md by the sync script -->

## Repository Context

This is a fork of [public-apis/public-apis](https://github.com/public-apis/public-apis) — a community-curated list of free APIs for software and web development.

## Project Structure

- `README.md` — Main API listing organized by category
- `CONTRIBUTING.md` — Guidelines for adding new APIs
- `scripts/` — Validation scripts, tests, and tooling
- `dashboard/` — Dashboard for API statistics

## API Entry Format

Each API entry in README.md follows this table format:

```
| API | Description | Auth | HTTPS | CORS |
```

- **Auth**: `apiKey`, `OAuth`, or empty
- **HTTPS**: Yes/No
- **CORS**: Yes/No/Unknown

## Rules for This Project

- When adding APIs, always validate with `scripts/validate/links.py`
- Follow the alphabetical ordering within each category
- Descriptions should be concise (max ~100 characters)
- Only add APIs that are free or have a free tier
- Run `python scripts/validate/links.py` before committing changes

## Connected Tools & Repos

<!-- Add references to your other repos/skills here -->
<!-- Example:
- Scrapling: Use for testing API endpoints that need scraping fallback
- claude-seo: Use /seo audit for any landing pages
- claude-skills: engineering/api-design-reviewer for API quality checks
-->

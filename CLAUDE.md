<!-- AUTO-SYNCED by scripts/sync-claude-config.sh -->
<!-- Global section is synced from ~/.claude/CLAUDE.md on session start -->
<!-- Project-specific config: .claude/project-config.md -->
<!-- Run: bash scripts/sync-claude-config.sh to manually sync -->

# Project: public-apis

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

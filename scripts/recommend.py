#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Personalized API Recommendations

An interactive CLI tool that parses the public-apis README.md and recommends
APIs based on user interests, preferred authentication level, and use case.
"""

import re
import sys
import os
import random
from typing import List, Dict, Tuple, Optional

# --- README Parser ---

link_re = re.compile(r'\[(.+?)\]\((https?://[^\)]+)\)')
anchor_re = re.compile(r'###\s+(.+)')

INTEREST_PROFILES = {
    "web-dev": {
        "label": "Web Development",
        "categories": [
            "Development", "Authentication & Authorization", "Cloud Storage & File Sharing",
            "Continuous Integration", "Documents & Productivity", "Email",
            "URL Shorteners", "Test Data", "Data Validation"
        ],
        "keywords": [
            "api", "rest", "json", "webhook", "server", "deploy", "host",
            "database", "storage", "cdn", "proxy", "dns", "ssl", "docker"
        ]
    },
    "data-science": {
        "label": "Data Science & ML",
        "categories": [
            "Machine Learning", "Science & Math", "Open Data", "Data Validation",
            "Text Analysis", "Weather", "Environment", "Finance"
        ],
        "keywords": [
            "data", "dataset", "predict", "machine learning", "ai", "nlp",
            "analysis", "statistics", "research", "compute", "neural"
        ]
    },
    "fun": {
        "label": "Fun & Entertainment",
        "categories": [
            "Animals", "Anime", "Entertainment", "Games & Comics",
            "Music", "Video", "Personality", "Art & Design"
        ],
        "keywords": [
            "fun", "game", "random", "joke", "trivia", "comic", "meme",
            "cat", "dog", "anime", "movie", "tv", "gif"
        ]
    },
    "finance": {
        "label": "Finance & Business",
        "categories": [
            "Finance", "Cryptocurrency", "Currency Exchange", "Business",
            "Blockchain", "Shopping", "Jobs"
        ],
        "keywords": [
            "stock", "crypto", "bitcoin", "bank", "payment", "price",
            "market", "trade", "exchange", "currency", "invoice"
        ]
    },
    "security": {
        "label": "Security & Privacy",
        "categories": [
            "Security", "Anti-Malware", "Authentication & Authorization",
            "Phone", "Data Validation"
        ],
        "keywords": [
            "security", "breach", "malware", "phishing", "spam", "threat",
            "vulnerability", "encrypt", "password", "auth", "scan"
        ]
    },
    "media": {
        "label": "Media & Creative",
        "categories": [
            "Photography", "Music", "Video", "Art & Design", "Social",
            "News", "Books", "Dictionaries"
        ],
        "keywords": [
            "image", "photo", "video", "music", "art", "design", "color",
            "font", "icon", "stock", "creative", "media", "stream"
        ]
    },
    "geo": {
        "label": "Geography & Travel",
        "categories": [
            "Geocoding", "Transportation", "Vehicle", "Weather",
            "Government", "Events", "Tracking"
        ],
        "keywords": [
            "map", "location", "gps", "country", "city", "travel", "flight",
            "transport", "route", "address", "geocode", "weather", "climate"
        ]
    },
    "health": {
        "label": "Health & Science",
        "categories": [
            "Health", "Science & Math", "Food & Drink", "Sports & Fitness",
            "Environment"
        ],
        "keywords": [
            "health", "medical", "nutrition", "food", "fitness", "exercise",
            "science", "biology", "chemistry", "nasa", "space", "covid"
        ]
    },
}


def parse_readme(filepath: str) -> Tuple[Dict[str, List[dict]], List[str]]:
    """Parse README.md and return APIs grouped by category."""
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = [line.rstrip() for line in f]

    categories: Dict[str, List[dict]] = {}
    category_order: List[str] = []
    current_category = None

    for line in lines:
        anchor_match = anchor_re.match(line)
        if anchor_match:
            current_category = anchor_match.group(1).strip()
            categories[current_category] = []
            category_order.append(current_category)
            continue

        if not line.startswith('|') or line.startswith('|---'):
            continue

        if current_category is None:
            continue

        segments = [s.strip() for s in line.split('|')[1:-1]]
        if len(segments) < 5:
            continue

        title_match = link_re.match(segments[0])
        if not title_match:
            continue

        entry = {
            'name': title_match.group(1),
            'url': title_match.group(2),
            'description': segments[1],
            'auth': segments[2].replace('`', ''),
            'https': segments[3],
            'cors': segments[4],
            'category': current_category,
        }
        categories[current_category].append(entry)

    return categories, category_order


def score_api(api: dict, profile: dict, auth_pref: Optional[str] = None) -> float:
    """Score an API entry against a user interest profile."""
    score = 0.0

    # Category match (strong signal)
    if api['category'] in profile['categories']:
        score += 5.0

    # Keyword match in name + description
    text = (api['name'] + ' ' + api['description']).lower()
    for kw in profile['keywords']:
        if kw in text:
            score += 2.0

    # Auth preference bonus
    if auth_pref == 'none' and api['auth'] == 'No':
        score += 3.0
    elif auth_pref == 'apikey' and api['auth'] in ('No', 'apiKey'):
        score += 2.0

    # HTTPS bonus
    if api['https'] == 'Yes':
        score += 1.0

    # CORS bonus
    if api['cors'] == 'Yes':
        score += 0.5

    return score


def get_recommendations(
    categories: Dict[str, List[dict]],
    interests: List[str],
    auth_pref: Optional[str] = None,
    limit: int = 15,
) -> List[Tuple[dict, float]]:
    """Get top API recommendations based on selected interests."""
    all_apis = []
    for cat_apis in categories.values():
        all_apis.extend(cat_apis)

    scored = []
    for api in all_apis:
        total_score = 0.0
        for interest in interests:
            profile = INTEREST_PROFILES.get(interest, {})
            if profile:
                total_score += score_api(api, profile, auth_pref)
        # Small random factor to vary results between runs
        total_score += random.uniform(0, 0.3)
        scored.append((api, total_score))

    scored.sort(key=lambda x: x[1], reverse=True)
    return scored[:limit]


def print_header(text: str) -> None:
    print(f'\n{"=" * 60}')
    print(f'  {text}')
    print(f'{"=" * 60}')


def print_api(api: dict, rank: int, score: float) -> None:
    auth_display = api['auth'] if api['auth'] != 'No' else 'None (free)'
    https_icon = 'Yes' if api['https'] == 'Yes' else 'No'
    cors_icon = api['cors']

    print(f'\n  #{rank} {api["name"]}')
    print(f'      {api["description"]}')
    print(f'      Category: {api["category"]}')
    print(f'      Auth: {auth_display} | HTTPS: {https_icon} | CORS: {cors_icon}')
    print(f'      URL: {api["url"]}')
    print(f'      Match score: {score:.1f}')


def interactive_mode(categories: Dict[str, List[dict]]) -> None:
    """Run the interactive recommendation CLI."""
    print_header('Personalized API Recommendations')
    print('\n  Discover APIs from 1,400+ public APIs tailored to your interests!\n')

    # Step 1: Select interests
    print('  What are you interested in? (select numbers, comma-separated)\n')
    profile_keys = list(INTEREST_PROFILES.keys())
    for i, key in enumerate(profile_keys, 1):
        profile = INTEREST_PROFILES[key]
        cats_preview = ', '.join(profile['categories'][:3])
        print(f'    {i}. {profile["label"]}')
        print(f'       ({cats_preview}, ...)')

    print()
    while True:
        try:
            raw = input('  Your choices (e.g. 1,3,5): ').strip()
            if not raw:
                print('  Please enter at least one choice.')
                continue
            indices = [int(x.strip()) for x in raw.split(',')]
            selected = []
            for idx in indices:
                if 1 <= idx <= len(profile_keys):
                    selected.append(profile_keys[idx - 1])
            if not selected:
                print('  Invalid selection. Please try again.')
                continue
            break
        except (ValueError, IndexError):
            print('  Invalid input. Please enter numbers separated by commas.')

    selected_labels = [INTEREST_PROFILES[s]['label'] for s in selected]
    print(f'\n  Selected: {", ".join(selected_labels)}')

    # Step 2: Auth preference
    print('\n  Authentication preference?\n')
    print('    1. No auth required (easiest to start)')
    print('    2. API key is fine (free signup)')
    print('    3. Any (include OAuth, etc.)')
    print()

    auth_pref = None
    while True:
        try:
            auth_choice = input('  Your choice (1-3) [default: 2]: ').strip()
            if not auth_choice:
                auth_pref = 'apikey'
                break
            auth_choice = int(auth_choice)
            if auth_choice == 1:
                auth_pref = 'none'
            elif auth_choice == 2:
                auth_pref = 'apikey'
            elif auth_choice == 3:
                auth_pref = 'any'
            else:
                print('  Please enter 1, 2, or 3.')
                continue
            break
        except ValueError:
            print('  Please enter a number.')

    # Step 3: How many results
    print()
    while True:
        try:
            raw_limit = input('  How many recommendations? (5-30) [default: 10]: ').strip()
            if not raw_limit:
                limit = 10
                break
            limit = int(raw_limit)
            if 5 <= limit <= 30:
                break
            print('  Please enter a number between 5 and 30.')
        except ValueError:
            print('  Please enter a number.')

    # Step 4: Get and display recommendations
    results = get_recommendations(categories, selected, auth_pref, limit)

    print_header(f'Top {limit} API Recommendations for You')

    for i, (api, score) in enumerate(results, 1):
        print_api(api, i, score)

    print(f'\n{"=" * 60}')
    total_apis = sum(len(apis) for apis in categories.values())
    print(f'  Scored {total_apis} APIs across {len(categories)} categories')
    print(f'  Based on interests: {", ".join(selected_labels)}')
    print(f'{"=" * 60}\n')


def quick_mode(categories: Dict[str, List[dict]], interests: List[str],
               auth_pref: str = 'apikey', limit: int = 10) -> None:
    """Non-interactive mode for scripting/piping."""
    results = get_recommendations(categories, interests, auth_pref, limit)

    print_header(f'Top {limit} Personalized API Recommendations')

    for i, (api, score) in enumerate(results, 1):
        print_api(api, i, score)

    print()


def main() -> None:
    readme_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'README.md')

    if not os.path.exists(readme_path):
        readme_path = os.path.join(os.path.dirname(__file__), '..', 'README.md')
    if not os.path.exists(readme_path):
        print('Error: Could not find README.md', file=sys.stderr)
        sys.exit(1)

    categories, _ = parse_readme(readme_path)

    # Support CLI arguments for non-interactive use
    if len(sys.argv) > 1:
        interests = sys.argv[1].split(',')
        auth_pref = sys.argv[2] if len(sys.argv) > 2 else 'apikey'
        limit = int(sys.argv[3]) if len(sys.argv) > 3 else 10
        valid_interests = [i for i in interests if i in INTEREST_PROFILES]
        if not valid_interests:
            print(f'Error: No valid interests. Choose from: {", ".join(INTEREST_PROFILES.keys())}',
                  file=sys.stderr)
            sys.exit(1)
        quick_mode(categories, valid_interests, auth_pref, limit)
    else:
        interactive_mode(categories)


if __name__ == '__main__':
    main()

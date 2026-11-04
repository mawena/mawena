#!/usr/bin/env python3
"""Génère les cartes SVG du profil GitHub : chiffres clés, langages, activité.

Bibliothèque standard uniquement. Chaque carte existe en version claire et
sombre (le README choisit avec <picture> et prefers-color-scheme).

    GITHUB_TOKEN=... python3 scripts/profile_cards.py --user mawena --out dist

Le jeton peut être le GITHUB_TOKEN d'Actions : il suffit pour lire les
données publiques du profil.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import sys
import urllib.request
from collections import defaultdict
from xml.sax.saxutils import escape

API = "https://api.github.com/graphql"
FONT = "-apple-system,BlinkMacSystemFont,'Segoe UI','Noto Sans',Helvetica,Arial,sans-serif"
MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

# Couleurs : surfaces et encres de GitHub, accent vert de la marque.
# Accent validé (bande de luminance, contraste >= 3:1) sur chaque surface.
THEMES = {
    "light": {
        "surface": "#ffffff", "border": "#d1d9e0", "grid": "#d1d9e0",
        "text": "#1f2328", "text2": "#59636e", "accent": "#1a7f37",
    },
    "dark": {
        "surface": "#0d1117", "border": "#3d444d", "grid": "#3d444d",
        "text": "#f0f6fc", "text2": "#9198a1", "accent": "#2ea043",
    },
}

QUERY = """
query($login: String!, $after: String, $yearFrom: DateTime!, $monthsFrom: DateTime!) {
  user(login: $login) {
    name
    login
    createdAt
    followers { totalCount }
    lastYear: contributionsCollection {
      contributionCalendar {
        totalContributions
        weeks { contributionDays { date contributionCount } }
      }
      commitContributionsByRepository(maxRepositories: 100) {
        contributions { totalCount }
        repository {
          nameWithOwner
          languages(first: 20, orderBy: {field: SIZE, direction: DESC}) {
            edges { size node { name } }
          }
        }
      }
    }
    thisYear: contributionsCollection(from: $yearFrom) {
      contributionCalendar { totalContributions }
    }
    months: contributionsCollection(from: $monthsFrom) {
      contributionCalendar {
        weeks { contributionDays { date contributionCount } }
      }
    }
    repositories(first: 100, after: $after, ownerAffiliations: OWNER,
                 isFork: false, privacy: PUBLIC) {
      totalCount
      pageInfo { hasNextPage endCursor }
      nodes {
        name
        isArchived
        stargazerCount
        pushedAt
      }
    }
  }
}
"""


# --------------------------------------------------------------------- données

def graphql(token: str, variables: dict) -> dict:
    body = json.dumps({"query": QUERY, "variables": variables}).encode()
    req = urllib.request.Request(API, data=body, headers={
        "Authorization": f"bearer {token}",
        "Content-Type": "application/json",
        "User-Agent": "mawena-profile-cards",
    })
    with urllib.request.urlopen(req, timeout=30) as resp:
        payload = json.load(resp)
    if payload.get("errors"):
        sys.exit(f"Erreur GraphQL : {payload['errors']}")
    return payload["data"]["user"]


def fetch(token: str, login: str, today: dt.date) -> dict:
    first_month = (today.replace(day=1) - dt.timedelta(days=1)).replace(day=1)
    for _ in range(10):  # 11 mois pleins avant le mois courant
        first_month = (first_month - dt.timedelta(days=1)).replace(day=1)
    variables = {
        "login": login,
        "after": None,
        "yearFrom": f"{today.year}-01-01T00:00:00Z",
        "monthsFrom": f"{first_month.isoformat()}T00:00:00Z",
    }
    user = graphql(token, variables)
    repos = list(user["repositories"]["nodes"])
    page = user["repositories"]["pageInfo"]
    while page["hasNextPage"]:
        variables["after"] = page["endCursor"]
        more = graphql(token, variables)["repositories"]
        repos += more["nodes"]
        page = more["pageInfo"]
    user["repositories"]["nodes"] = repos
    user["firstMonth"] = first_month
    return user


def days_of(calendar: dict) -> list[tuple[dt.date, int]]:
    return [
        (dt.date.fromisoformat(d["date"]), d["contributionCount"])
        for w in calendar["weeks"] for d in w["contributionDays"]
    ]


def streaks(days: list[tuple[dt.date, int]], today: dt.date) -> tuple[int, int]:
    days = [(d, n) for d, n in sorted(days) if d <= today]
    longest = run = 0
    for _, n in days:
        run = run + 1 if n else 0
        longest = max(longest, run)
    # Série en cours : aujourd'hui sans contribution ne la casse pas encore.
    current = 0
    for i, (d, n) in enumerate(reversed(days)):
        if n:
            current += 1
        elif i == 0 and d == today:
            continue
        else:
            break
    return current, longest


def summarize(user: dict, today: dt.date, hide: set[str]) -> dict:
    repos = user["repositories"]["nodes"]
    year_ago = today - dt.timedelta(days=365)
    active = [r for r in repos if dt.date.fromisoformat(r["pushedAt"][:10]) >= year_ago]

    # Langages pondérés par les commits de l'année : chaque dépôt pèse son
    # nombre de commits, réparti selon la part d'octets de chaque langage.
    # Évite qu'un gros dépôt ancien ou du code compilé écrase le reste.
    weights: dict[str, float] = defaultdict(float)
    commits = 0
    for item in user["lastYear"]["commitContributionsByRepository"]:
        edges = [e for e in item["repository"]["languages"]["edges"]
                 if e["node"]["name"] not in hide]
        size = sum(e["size"] for e in edges)
        if not size:
            continue
        n = item["contributions"]["totalCount"]
        commits += n
        for e in edges:
            weights[e["node"]["name"]] += n * e["size"] / size
    ranked = sorted(weights.items(), key=lambda kv: kv[1], reverse=True)
    total = sum(weights.values()) or 1
    top = [(name, w / total) for name, w in ranked[:7]]
    rest = sum(w for _, w in ranked[7:])
    if rest:
        top.append(("Other", rest / total))

    by_month: dict[tuple[int, int], int] = defaultdict(int)
    for d, n in days_of(user["months"]["contributionCalendar"]):
        if user["firstMonth"] <= d <= today:
            by_month[(d.year, d.month)] += n
    months = []
    y, m = user["firstMonth"].year, user["firstMonth"].month
    while (y, m) <= (today.year, today.month):
        months.append((y, m, by_month.get((y, m), 0)))
        y, m = (y + 1, 1) if m == 12 else (y, m + 1)

    current, longest = streaks(days_of(user["lastYear"]["contributionCalendar"]), today)
    created = dt.date.fromisoformat(user["createdAt"][:10])
    return {
        "name": user["name"] or user["login"],
        "login": user["login"],
        "since": created.year,
        "last_year": user["lastYear"]["contributionCalendar"]["totalContributions"],
        "this_year": user["thisYear"]["contributionCalendar"]["totalContributions"],
        "current_streak": current,
        "longest_streak": longest,
        "repos": user["repositories"]["totalCount"],
        "active_repos": len(active),
        "stars": sum(r["stargazerCount"] for r in repos),
        "followers": user["followers"]["totalCount"],
        "languages": top,
        "lang_commits": commits,
        "lang_repos": len(user["lastYear"]["commitContributionsByRepository"]),
        "hidden": sorted(hide),
        "months": months,
        "today": today,
    }


# ------------------------------------------------------------------------ SVG

def fmt(n: int) -> str:
    return f"{n:,}" if n < 10_000 else f"{n / 1000:.1f}K".replace(".0K", "K")


def card(width: int, height: int, title: str, subtitle: str, body: str, t: dict, desc: str) -> str:
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img" aria-labelledby="t d">
<title id="t">{escape(title)}</title>
<desc id="d">{escape(desc)}</desc>
<style>
text {{ font-family: {FONT}; }}
.h {{ font-size: 15px; font-weight: 600; fill: {t['text']}; }}
.s {{ font-size: 12px; fill: {t['text2']}; }}
.v {{ font-size: 24px; font-weight: 600; fill: {t['text']}; }}
.l {{ font-size: 12px; fill: {t['text2']}; }}
.n {{ font-size: 12px; fill: {t['text']}; }}
.a {{ font-size: 11px; fill: {t['text2']}; font-variant-numeric: tabular-nums; }}
</style>
<rect x="0.5" y="0.5" width="{width - 1}" height="{height - 1}" rx="8" fill="{t['surface']}" stroke="{t['border']}"/>
<text class="h" x="20" y="32">{escape(title)}</text>
<text class="s" x="20" y="51">{escape(subtitle)}</text>
{body}
</svg>
"""


def overview_svg(s: dict, t: dict) -> str:
    tiles = [
        (fmt(s["last_year"]), "contributions, last 12 months"),
        (fmt(s["this_year"]), f"contributions in {s['today'].year}"),
        (f"{s['current_streak']} d", "current streak"),
        (f"{s['longest_streak']} d", "longest streak, 12 months"),
        (str(s["active_repos"]), f"public repos pushed in 12 months, of {s['repos']}"),
        (str(s["stars"]), "stars earned"),
    ]
    width, cols = 840, 3
    col_w = (width - 40) // cols
    parts = []
    for i, (value, label) in enumerate(tiles):
        x = 20 + (i % cols) * col_w
        y = 100 + (i // cols) * 64
        parts.append(f'<text class="v" x="{x}" y="{y}">{escape(value)}</text>')
        parts.append(f'<text class="l" x="{x}" y="{y + 20}">{escape(label)}</text>')
    desc = "; ".join(f"{label}: {value}" for value, label in tiles)
    subtitle = f"Public profile data · on GitHub since {s['since']} · updated {s['today'].isoformat()}"
    return card(width, 210, f"{s['name']} · @{s['login']}", subtitle, "\n".join(parts), t, desc)


def languages_svg(s: dict, t: dict) -> str:
    width, row_h, top = 410, 26, 76
    langs = s["languages"]
    label_w, value_w = 92, 44
    bar_max = width - 20 - label_w - value_w - 20
    biggest = max((p for _, p in langs), default=1) or 1
    parts = []
    for i, (name, share) in enumerate(langs):
        y = top + i * row_h
        length = max(2.0, bar_max * share / biggest)
        x0 = 20 + label_w
        r = min(4.0, length / 2)
        # Barre horizontale : extrémité arrondie, côté ligne de base carré.
        path = (f"M{x0},{y} h{length - r:.1f} a{r},{r} 0 0 1 {r},{r} v{12 - 2 * r:.1f} "
                f"a{r},{r} 0 0 1 -{r},{r} h-{length - r:.1f} z")
        parts.append(f'<text class="n" x="20" y="{y + 10}">{escape(name)}</text>')
        parts.append(f'<path d="{path}" fill="{t["accent"]}"/>')
        parts.append(f'<text class="a" x="{x0 + length + 6:.1f}" y="{y + 10}">{share * 100:.1f}%</text>')
    parts.append(f'<line x1="{20 + label_w}" y1="{top - 6}" x2="{20 + label_w}" '
                 f'y2="{top + len(langs) * row_h - 8}" stroke="{t["grid"]}"/>')
    hidden = f" · excl. {', '.join(s['hidden'])}" if s["hidden"] else ""
    subtitle = f"Weighted by {fmt(s['lang_commits'])} commits, last 12 months{hidden}"
    desc = "; ".join(f"{n}: {p * 100:.1f}%" for n, p in langs)
    height = top + len(langs) * row_h + 10
    return card(width, max(height, 290), "Languages", subtitle, "\n".join(parts), t, desc)


def activity_svg(s: dict, t: dict) -> str:
    width, height = 410, 290
    months = s["months"]
    left, right, top, bottom = 52, 16, 82, height - 40
    plot_h = bottom - top
    slot = (width - left - right) / len(months)
    bar_w = min(18.0, slot - 6)
    peak = max((n for *_, n in months), default=0)
    step = nice_step(peak)
    ymax = step * max(1, -(-peak // step))
    parts = []
    for k in range(0, ymax + 1, step):
        y = bottom - plot_h * k / ymax
        parts.append(f'<line x1="{left}" y1="{y:.1f}" x2="{width - right}" y2="{y:.1f}" stroke="{t["grid"]}" stroke-width="1"/>')
        parts.append(f'<text class="a" x="{left - 8}" y="{y + 4:.1f}" text-anchor="end">{fmt(k)}</text>')
    peak_i = max(range(len(months)), key=lambda i: months[i][2]) if peak else -1
    for i, (yy, mm, n) in enumerate(months):
        cx = left + slot * i + slot / 2
        x = cx - bar_w / 2
        h = plot_h * n / ymax if ymax else 0
        if h > 0:
            r = min(4.0, h, bar_w / 2)
            y = bottom - h
            # Colonne : sommet arrondi, base carrée sur la ligne de base.
            path = (f"M{x:.1f},{bottom} v-{h - r:.1f} a{r},{r} 0 0 1 {r},-{r} "
                    f"h{bar_w - 2 * r:.1f} a{r},{r} 0 0 1 {r},{r} v{h - r:.1f} z")
            parts.append(f'<path d="{path}" fill="{t["accent"]}"><title>{MONTHS[mm - 1]} {yy}: {n}</title></path>')
        if i in (peak_i, len(months) - 1) and n:
            parts.append(f'<text class="a" x="{cx:.1f}" y="{bottom - h - 6:.1f}" text-anchor="middle">{fmt(n)}</text>')
        label = MONTHS[mm - 1] + ("*" if i == len(months) - 1 else "")
        parts.append(f'<text class="a" x="{cx:.1f}" y="{bottom + 18}" text-anchor="middle">{label}</text>')
    first, last = months[0], months[-1]
    subtitle = (f"Contributions per month, {MONTHS[first[1] - 1]} {first[0]} – "
                f"{MONTHS[last[1] - 1]} {last[0]} (* month to date)")
    desc = "; ".join(f"{MONTHS[m - 1]} {y}: {n}" for y, m, n in months)
    return card(width, height, "Activity", subtitle, "\n".join(parts), t, desc)


def nice_step(peak: int) -> int:
    raw = max(peak, 1) / 4
    magnitude = 10 ** (len(str(int(raw))) - 1)
    for m in (1, 2, 2.5, 5, 10):
        if raw <= m * magnitude:
            return max(1, int(m * magnitude))
    return int(10 * magnitude)


# ---------------------------------------------------------------------- main

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--user", default="mawena")
    parser.add_argument("--out", default="dist")
    parser.add_argument("--hide", default="", help="langages à masquer, séparés par des virgules")
    parser.add_argument("--json", action="store_true", help="affiche aussi les données agrégées")
    args = parser.parse_args()

    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if not token:
        sys.exit("GITHUB_TOKEN (ou GH_TOKEN) manquant.")

    today = dt.datetime.now(dt.timezone.utc).date()
    hide = {x.strip() for x in args.hide.split(",") if x.strip()}
    stats = summarize(fetch(token, args.user, today), today, hide)

    os.makedirs(args.out, exist_ok=True)
    for mode, theme in THEMES.items():
        for name, render in (("overview", overview_svg), ("languages", languages_svg),
                             ("activity", activity_svg)):
            with open(os.path.join(args.out, f"{name}-{mode}.svg"), "w", encoding="utf-8") as f:
                f.write(render(stats, theme))
    with open(os.path.join(args.out, "stats.json"), "w", encoding="utf-8") as f:
        json.dump(stats, f, default=str, indent=2)
    if args.json:
        print(json.dumps(stats, default=str, indent=2))


if __name__ == "__main__":
    main()
